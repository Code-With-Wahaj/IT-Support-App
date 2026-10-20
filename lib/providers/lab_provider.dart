import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lab_model.dart';

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
  }

  Future<void> updateLabAndSyncPcs(LabModel lab) async {
    final labRef = _db.collection('labs').doc(lab.id);
    final assignedTechnician = _findTechnicianFromCache(lab.name);
    final labWithTech = lab.copyWith(assignedTo: assignedTechnician);

    await labRef.update(labWithTech.toMap());
  }

  Future<void> deleteLab(String id) async {
    final labRef = _db.collection('labs').doc(id);
    await labRef.delete();
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
