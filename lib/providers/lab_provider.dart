import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lab_model.dart';
import '../models/pc_status_model.dart';

class LabProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LabModel> labs = [];
  Map<String, List<String>> _cachedTechMap = {};
  bool _listening = false;

  /// Fetch labs once per session and cache technician mapping to avoid N+1 reads
  void fetchLabs() {
    if (_listening) return;
    _listening = true;

    // Listen to technicians changes separately if permitted (Admin), guarded against permission denial
    _db
        .collection('users')
        .where('role', isEqualTo: 'IT Technician')
        .snapshots()
        .listen(
      (techSnap) {
        _cachedTechMap = {
          for (var doc in techSnap.docs)
            (doc.data()['name'] ?? 'Unknown').toString():
                List<String>.from(doc.data()['associatedLabs'] ?? [])
        };
        _recomputeLabAssignments();
      },
      onError: (e) {
        debugPrint('Tech map subscription handled non-fatally: $e');
      },
    );

    _db.collection('labs').snapshots().listen(
      (s) {
        labs = s.docs.map((d) => LabModel.fromMap(d.id, d.data())).toList();
        _recomputeLabAssignments();
      },
      onError: (e) {
        debugPrint('Labs stream handled non-fatally: $e');
      },
    );
  }

  void _recomputeLabAssignments() {
    if (_cachedTechMap.isNotEmpty) {
      labs = labs.map((lab) {
        final labNameNormalized = lab.name.trim().toLowerCase();
        for (final entry in _cachedTechMap.entries) {
          final assignedLabsNormalized =
              entry.value.map((e) => e.toString().trim().toLowerCase());
          if (assignedLabsNormalized.contains(labNameNormalized)) {
            return lab.copyWith(assignedTo: entry.key);
          }
        }
        return lab;
      }).toList();
    }
    notifyListeners();
  }

  Future<void> addLab(LabModel lab) async {
    if (labs.any((l) => l.name.toLowerCase() == lab.name.toLowerCase())) {
      throw Exception('Lab already exists');
    }

    final assignedTechnician = _findTechnicianFromCache(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    final labRef = _db.collection('labs').doc(lab.id);
    await labRef.set(labWithTech.toMap());

    final batch = _db.batch();
    batch.set(labRef.collection('pcs').doc('IP'), PcStatusModel(pcId: 'IP').toMap());
    for (int r = 0; r < lab.rows; r++) {
      for (int c = 0; c < lab.columns; c++) {
        final id = 'PC-${r + 1}-${c + 1}';
        batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
      }
    }
    await batch.commit();
  }

  Future<void> updateLabAndSyncPcs(LabModel lab) async {
    final labRef = _db.collection('labs').doc(lab.id);
    final assignedTechnician = _findTechnicianFromCache(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    await labRef.update(labWithTech.toMap());

    final existing = await labRef.collection('pcs').get();
    final existingIds = existing.docs.map((d) => d.id).toSet();

    final batch = _db.batch();
    for (int r = 0; r < lab.rows; r++) {
      for (int c = 0; c < lab.columns; c++) {
        final id = 'PC-${r + 1}-${c + 1}';
        if (!existingIds.contains(id)) {
          batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
        }
        existingIds.remove(id);
      }
    }

    existingIds.remove('IP');
    for (final id in existingIds) {
      batch.delete(labRef.collection('pcs').doc(id));
    }

    await batch.commit();
  }

  Future<void> deleteLab(String id) async {
    final labRef = _db.collection('labs').doc(id);
    final pcs = await labRef.collection('pcs').get();

    final batch = _db.batch();
    for (final p in pcs.docs) {
      batch.delete(p.reference);
    }
    batch.delete(labRef);
    await batch.commit();
  }

  Future<void> updatePcStatus(String labId, String pcId, PcStatusModel s) async {
    await _db
        .collection('labs')
        .doc(labId)
        .collection('pcs')
        .doc(pcId)
        .set(s.toMap(), SetOptions(merge: true));
  }

  Stream<Map<String, PcStatusModel>> streamLabPcStatuses(String labId) {
    return _db.collection('labs').doc(labId).collection('pcs').snapshots().map(
          (s) => {for (final d in s.docs) d.id: PcStatusModel.fromMap(d.id, d.data())},
        );
  }

  Future<void> ensureLabPcsInitialized(LabModel lab) async {
    try {
      final labRef = _db.collection('labs').doc(lab.id);
      final existing = await labRef.collection('pcs').limit(1).get();
      if (existing.docs.isEmpty) {
        final batch = _db.batch();
        batch.set(labRef.collection('pcs').doc('IP'), PcStatusModel(pcId: 'IP').toMap());
        for (int r = 0; r < lab.rows; r++) {
          for (int c = 0; c < lab.columns; c++) {
            final id = 'PC-${r + 1}-${c + 1}';
            batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
          }
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('ensureLabPcsInitialized error: $e');
    }
  }

  String _findTechnicianFromCache(String labName) {
    final norm = labName.trim().toLowerCase();
    for (final entry in _cachedTechMap.entries) {
      if (entry.value.map((e) => e.trim().toLowerCase()).contains(norm)) {
        return entry.key;
      }
    }
    return 'Unassigned';
  }
}
