class LabModel {
  final String id;
  final String name;
  final int rows;
  final int columns;
  final String layoutType;

  /// 🔹 NEW: Assigned Technician
  final String assignedTo;
  final String assignedTechnicianId;

  final List<String> disabledPcs;

  LabModel({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.layoutType,
    this.assignedTo = 'Unknown', // default
    this.assignedTechnicianId = '',
    this.disabledPcs = const [],
  });

  /// 🔥 Firestore → Model
  factory LabModel.fromMap(String id, Map<String, dynamic> map) {
    return LabModel(
      id: id,
      name: map['name'] ?? '',
      rows: map['rows'] is int ? map['rows'] : int.tryParse('${map['rows']}') ?? 4,
      columns: map['columns'] is int ? map['columns'] : int.tryParse('${map['columns']}') ?? 5,
      layoutType: map['layoutType'] ?? 'theater',
      assignedTo: map['assignedTo'] ?? 'Unknown',
      assignedTechnicianId: map['assignedTechnicianId'] ?? '',
      disabledPcs: List<String>.from(map['disabledPcs'] ?? map['inactivePcs'] ?? []),
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rows': rows,
      'columns': columns,
      'layoutType': layoutType,
      'assignedTo': assignedTo,
      'assignedTechnicianId': assignedTechnicianId,
      'disabledPcs': disabledPcs,
    };
  }

  /// ✅ Helper for safe updates (used later)
  LabModel copyWith({
    String? id,
    String? name,
    int? rows,
    int? columns,
    String? layoutType,
    String? assignedTo,
    String? assignedTechnicianId,
    List<String>? disabledPcs,
  }) {
    return LabModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      layoutType: layoutType ?? this.layoutType,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      disabledPcs: disabledPcs ?? this.disabledPcs,
    );
  }
}
