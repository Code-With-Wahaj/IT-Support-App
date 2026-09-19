class LabModel {
  final String id;
  final String name;
  final int rows;
  final int columns;
  final String layoutType;

  /// 🔹 NEW: Assigned Technician
  final String assignedTo;

  LabModel({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.layoutType,
    this.assignedTo = 'Unknown', // default
  });

  /// 🔥 Firestore → Model
  factory LabModel.fromMap(String id, Map<String, dynamic> map) {
    return LabModel(
      id: id,
      name: map['name'],
      rows: map['rows'],
      columns: map['columns'],
      layoutType: map['layoutType'],
      assignedTo: map['assignedTo'] ?? 'Unknown',
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
  }) {
    return LabModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      layoutType: layoutType ?? this.layoutType,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
