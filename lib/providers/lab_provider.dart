import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lab_model.dart';
import '../models/pc_status_model.dart';

class LabProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LabModel> labs = [];

  /// Fetch labs from Firestore and assign technician automatically
  void fetchLabs() {
    _db.collection('labs').snapshots().listen((s) async {
      final fetchedLabs = s.docs.map((d) => LabModel.fromMap(d.id, d.data())).toList();

      // Fetch all IT Technicians
      final techSnapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'IT Technician')
          .get();

      final techMap = {
        for (var doc in techSnapshot.docs)
          doc.data()['name']: List<String>.from(doc.data()['associatedLabs'] ?? [])
      };

      // Assign technician automatically based on lab name
      final labsWithTech = await Future.wait(fetchedLabs.map((lab) async {
        final labNameNormalized = lab.name.trim().toLowerCase();
        for (final entry in techMap.entries) {
          final assignedLabsNormalized =
          entry.value.map((e) => e.toString().trim().toLowerCase());
          if (assignedLabsNormalized.contains(labNameNormalized)) {
            return lab.copyWith(assignedTo: entry.key);
          }
        }
        return lab.copyWith(assignedTo: 'Unknown');
      }));

      labs = labsWithTech;
      notifyListeners();
    });
  }

  /// Add Lab and assign technician automatically
  Future<void> addLab(LabModel lab) async {
    if (labs.any((l) => l.name.toLowerCase() == lab.name.toLowerCase())) {
      throw Exception('Lab already exists');
    }

    // Determine assigned technician
    final assignedTechnician = await _getAssignedTechnician(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    final labRef = _db.collection('labs').doc(lab.id);
    await labRef.set(labWithTech.toMap());

    final batch = _db.batch();

    // Add default PCs
    batch.set(labRef.collection('pcs').doc('IP'), PcStatusModel(pcId: 'IP').toMap());
    for (int r = 0; r < lab.rows; r++) {
      for (int c = 0; c < lab.columns; c++) {
        final id = 'PC-${r + 1}-${c + 1}';
        batch.set(labRef.collection('pcs').doc(id), PcStatusModel(pcId: id).toMap());
      }
    }
    await batch.commit();
  }

  /// Update Lab and sync PCs
  Future<void> updateLabAndSyncPcs(LabModel lab) async {
    final labRef = _db.collection('labs').doc(lab.id);

    // Determine assigned technician
    final assignedTechnician = await _getAssignedTechnician(lab.name);
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

  /// Delete Lab
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

  /// Update a single PC status
  Future<void> updatePcStatus(String labId, String pcId, PcStatusModel s) async {
    await _db
        .collection('labs')
        .doc(labId)
        .collection('pcs')
        .doc(pcId)
        .set(s.toMap(), SetOptions(merge: true));
  }

  /// Stream PC statuses
  Stream<Map<String, PcStatusModel>> streamLabPcStatuses(String labId) {
    return _db.collection('labs').doc(labId).collection('pcs').snapshots().map(
          (s) => {for (final d in s.docs) d.id: PcStatusModel.fromMap(d.id, d.data())},
    );
  }

  /// Helper: Get assigned technician for a lab name
  Future<String> _getAssignedTechnician(String labName) async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'IT Technician')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final List<String> assignedLabs = List<String>.from(data['associatedLabs'] ?? []);
      if (assignedLabs.map((e) => e.toString().trim().toLowerCase()).contains(labName.trim().toLowerCase())) {
        return data['name'] ?? 'Unknown';
      }
    }
    return 'Unknown';
  }
}
