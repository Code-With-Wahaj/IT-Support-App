// 📄 File: lib/services/excel/save_helper_web.dart

import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> saveHelper(List<int> bytes, String fileName) async {
  // 1. Create a Blob (Web specific)
  final blob = html.Blob([Uint8List.fromList(bytes)]);

  // 2. Create an Object URL
  final url = html.Url.createObjectUrlFromBlob(blob);

  // 3. Create an Anchor (<a>) tag to trigger download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click(); // Simulate click

  // 4. Cleanup
  html.Url.revokeObjectUrl(url);

  return 'Downloaded via Browser';
}
