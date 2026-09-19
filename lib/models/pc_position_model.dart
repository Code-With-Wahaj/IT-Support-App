class PcPosition {
  final String pcId;
  final int row;
  final int column;
  bool isActive;

  PcPosition({
    required this.pcId,
    required this.row,
    required this.column,
    this.isActive = true,
  });

  /// Firestore → Model
  factory PcPosition.fromMap(Map<String, dynamic> map) {
    return PcPosition(
      pcId: map['pcId'],
      row: map['row'] ?? 0,
      column: map['column'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'pcId': pcId,
      'row': row,
      'column': column,
      'isActive': isActive,
    };
  }
}
