class PcStatusModel {
  final String pcId;

  // Hardware
  bool keyboardOk;
  bool mouseOk;
  bool ledOk;

  // Cables
  bool vgaCableOk;
  bool powerCableOk;
  bool internetCableOk;

  // CPU
  bool cpuWorking;

  // Specs (DEFAULT VALUES)
  String ram;
  String ssd;
  String os;

  // Notes
  String notes;

  PcStatusModel({
    required this.pcId,

    // Hardware
    this.keyboardOk = true,
    this.mouseOk = true,
    this.ledOk = true,

    // Cables
    this.vgaCableOk = true,
    this.powerCableOk = true,
    this.internetCableOk = true,

    // CPU
    this.cpuWorking = true,

    // ✅ DEFAULT SPECS
    this.ram = '16 GB',
    this.ssd = '512 GB',
    this.os = 'Windows 11',

    // Notes
    this.notes = '',
  });

  /// 🔥 Firestore → Model
  factory PcStatusModel.fromMap(
      String pcId,
      Map<String, dynamic> map,
      ) {
    return PcStatusModel(
      pcId: pcId,

      // Hardware
      keyboardOk: map['keyboardOk'] ?? true,
      mouseOk: map['mouseOk'] ?? true,
      ledOk: map['ledOk'] ?? true,

      // Cables
      vgaCableOk: map['vgaCableOk'] ?? true,
      powerCableOk: map['powerCableOk'] ?? true,
      internetCableOk: map['internetCableOk'] ?? true,

      // CPU (backward compatibility)
      cpuWorking: map['cpuWorking'] ?? map['isWorking'] ?? true,

      // ✅ Specs (fallback to defaults)
      ram: map['ram'] ?? '16 GB',
      ssd: map['ssd'] ?? '512 GB',
      os: map['os'] ?? 'Windows 11',

      // Notes
      notes: map['notes'] ?? '',
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() => {
    'keyboardOk': keyboardOk,
    'mouseOk': mouseOk,
    'ledOk': ledOk,
    'vgaCableOk': vgaCableOk,
    'powerCableOk': powerCableOk,
    'internetCableOk': internetCableOk,
    'cpuWorking': cpuWorking,
    'ram': ram,
    'ssd': ssd,
    'os': os,
    'notes': notes,
  };

  /// ✅ Deep copy (FIXES dialog edit bug)
  PcStatusModel copy() {
    return PcStatusModel(
      pcId: pcId,
      keyboardOk: keyboardOk,
      mouseOk: mouseOk,
      ledOk: ledOk,
      vgaCableOk: vgaCableOk,
      powerCableOk: powerCableOk,
      internetCableOk: internetCableOk,
      cpuWorking: cpuWorking,
      ram: ram,
      ssd: ssd,
      os: os,
      notes: notes,
    );
  }
}
