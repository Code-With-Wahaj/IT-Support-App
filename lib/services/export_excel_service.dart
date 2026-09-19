import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import '../models/lab_model.dart';
import '../models/pc_status_model.dart';
import 'excel/save_helper.dart';

class ExportExcelService {
  /* ───────────────────────────────────────────────
   * 🎨 STYLES
   * ─────────────────────────────────────────────── */
  static final CellStyle greenStyle = CellStyle(
    fontColorHex: ExcelColor.green,
    bold: true,
  );

  static final CellStyle redStyle = CellStyle(
    fontColorHex: ExcelColor.red,
    bold: true,
  );

  /* ───────────────────────────────────────────────
   * 📌 SINGLE LAB EXPORT
   * ─────────────────────────────────────────────── */
  static Future<String?> exportLabReport({
    required LabModel lab,
    required List<PcStatusModel> pcs,
  }) async {
    if (pcs.isEmpty) {
      throw Exception('No PC data to export');
    }

    final excel = Excel.createExcel();
    final sheetName = lab.name;
    excel.rename(excel.getDefaultSheet()!, sheetName);

    final sheet = excel[sheetName];
    _buildLabSheet(sheet, lab, pcs);

    return _encodeAndSave(excel, '${lab.name}_report.xlsx');
  }

  /* ───────────────────────────────────────────────
   * 📌 ALL LABS EXPORT (MULTI SHEET) ✅ FIXED
   * ─────────────────────────────────────────────── */
  static Future<String?> exportAllLabs({
    required List<LabModel> labs,
    required Map<String, List<PcStatusModel>> labPcMap,
  }) async {
    if (labs.isEmpty) return null;

    final excel = Excel.createExcel();

    // ✅ Rename default sheet instead of deleting it
    excel.rename(excel.getDefaultSheet()!, labs.first.name);

    _buildLabSheet(
      excel[labs.first.name],
      labs.first,
      labPcMap[labs.first.id] ?? [],
    );

    // ✅ Add remaining labs as new sheets
    for (int i = 1; i < labs.length; i++) {
      final lab = labs[i];
      final sheet = excel[lab.name];
      _buildLabSheet(sheet, lab, labPcMap[lab.id] ?? []);
    }

    return _encodeAndSave(excel, 'all_labs_report.xlsx');
  }

  /* ───────────────────────────────────────────────
   * 🧱 LAB SHEET BUILDER
   * ─────────────────────────────────────────────── */
  static void _buildLabSheet(
    Sheet sheet,
    LabModel lab,
    List<PcStatusModel> pcs,
  ) {
    sheet.appendRow([TextCellValue('Lab Name'), TextCellValue(lab.name)]);
    sheet.appendRow([
      TextCellValue('Assigned To'),
      TextCellValue(lab.assignedTo),
    ]);
    sheet.appendRow([TextCellValue('Rows'), IntCellValue(lab.rows)]);
    sheet.appendRow([TextCellValue('Columns'), IntCellValue(lab.columns)]);
    sheet.appendRow([TextCellValue('Layout'), TextCellValue(lab.layoutType)]);
    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue('S.No'),
      TextCellValue('PC ID'),
      TextCellValue('Keyboard'),
      TextCellValue('Mouse'),
      TextCellValue('LED'),
      TextCellValue('VGA'),
      TextCellValue('Power'),
      TextCellValue('Internet'),
      TextCellValue('CPU'),
      TextCellValue('RAM'),
      TextCellValue('SSD'),
      TextCellValue('OS'),
      TextCellValue('Notes'),
    ]);

    for (int i = 0; i < pcs.length; i++) {
      final rowIndex = sheet.maxRows;
      final pc = pcs[i];

      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(pc.pcId),
        TextCellValue(pc.keyboardOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.mouseOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.ledOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.vgaCableOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.powerCableOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.internetCableOk ? 'OK' : 'Faulty'),
        TextCellValue(pc.cpuWorking ? 'Working' : 'Faulty'),
        TextCellValue(pc.ram),
        TextCellValue(pc.ssd),
        TextCellValue(pc.os),
        TextCellValue(pc.notes),
      ]);

      _applyOkStyle(sheet, rowIndex, 2, pc.keyboardOk);
      _applyOkStyle(sheet, rowIndex, 3, pc.mouseOk);
      _applyOkStyle(sheet, rowIndex, 4, pc.ledOk);
      _applyOkStyle(sheet, rowIndex, 5, pc.vgaCableOk);
      _applyOkStyle(sheet, rowIndex, 6, pc.powerCableOk);
      _applyOkStyle(sheet, rowIndex, 7, pc.internetCableOk);
      _applyWorkingStyle(sheet, rowIndex, 8, pc.cpuWorking);

      // ✅ SPECS ARE NOT STATUSES → ALWAYS GREEN IF PRESENT
      _applySpecStyle(sheet, rowIndex, 9, pc.ram);
      _applySpecStyle(sheet, rowIndex, 10, pc.ssd);
      _applySpecStyle(sheet, rowIndex, 11, pc.os);
    }
  }

  /* ───────────────────────────────────────────────
   * 📌 COMPLAINTS EXPORT (UNCHANGED)
   * ─────────────────────────────────────────────── */
  static Future<String?> exportToExcel(
    List<DocumentSnapshot> loadedComplaints,
  ) async {
    final excel = Excel.createExcel();

    // ✅ Rename default sheet instead of creating a new one
    final defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, 'Complaints');

    final sheet = excel['Complaints'];

    if (loadedComplaints.isEmpty) {
      sheet.appendRow([
        TextCellValue('S.No'),
        TextCellValue('ID'),
        TextCellValue('Message'),
        TextCellValue('Status'),
        TextCellValue('Lab'),
        TextCellValue('Issue Category'),
        TextCellValue('Assigned To'),
        TextCellValue('Resolved By'),
        TextCellValue('Created At'),
      ]);
    } else {
      final first = loadedComplaints.first.data() as Map<String, dynamic>;
      final headers = ['S.No', 'ID', ...first.keys];
      sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < loadedComplaints.length; i++) {
        final rowIndex = sheet.maxRows;
        final doc = loadedComplaints[i];
        final data = doc.data() as Map<String, dynamic>;

        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(doc.id),
          ...first.keys.map((k) => TextCellValue('${data[k] ?? ''}')),
        ]);

        final statusIndex = first.keys.toList().indexOf('status') + 2;

        if (statusIndex > 1) {
          final status = data['status'].toString().toLowerCase();
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: statusIndex,
                  rowIndex: rowIndex,
                ),
              )
              .cellStyle = status == 'resolved'
              ? greenStyle
              : redStyle;
        }
      }
    }

    return _encodeAndSave(excel, 'complaints_export.xlsx');
  }

  /* ───────────────────────────────────────────────
   * 🎨 STYLE HELPERS
   * ─────────────────────────────────────────────── */
  static void _applyOkStyle(Sheet sheet, int row, int col, bool ok) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .cellStyle = ok
        ? greenStyle
        : redStyle;
  }

  static void _applyWorkingStyle(Sheet sheet, int row, int col, bool ok) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .cellStyle = ok
        ? greenStyle
        : redStyle;
  }

  // ✅ NEW: Spec-safe styling
  static void _applySpecStyle(Sheet sheet, int row, int col, String value) {
    if (value.trim().isEmpty) return;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .cellStyle =
        greenStyle;
  }

  /* ───────────────────────────────────────────────
   * 🔒 SAVE
   * ─────────────────────────────────────────────── */
  static Future<String?> _encodeAndSave(Excel excel, String fileName) async {
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Excel encoding failed');
    }
    return saveExcelFile(bytes, fileName);
  }
}
