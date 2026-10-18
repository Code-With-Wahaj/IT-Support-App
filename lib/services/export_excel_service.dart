import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'excel/save_helper.dart';

class ExportExcelService {
  static final CellStyle greenStyle = CellStyle(
    fontColorHex: ExcelColor.green,
    bold: true,
  );

  static final CellStyle redStyle = CellStyle(
    fontColorHex: ExcelColor.red,
    bold: true,
  );

  /// Complaints & Analytics Excel (.xlsx) export
  static Future<String?> exportToExcel(
    List<DocumentSnapshot> loadedComplaints,
  ) async {
    final excel = Excel.createExcel();

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
              .cellStyle = status == 'resolved' ? greenStyle : redStyle;
        }
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Excel encoding failed');
    }
    return saveExcelFile(bytes, 'complaints_export.xlsx');
  }
}
