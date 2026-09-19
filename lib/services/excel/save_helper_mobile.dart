import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> saveHelper(List<int> bytes, String fileName) async {
  Directory? dir;

  if (Platform.isAndroid) {
    // ✅ Request proper permission (Android 11+)
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }

    // ✅ PUBLIC DOWNLOADS DIRECTORY
    dir = Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  } else {
    dir = await getDownloadsDirectory();
  }

  // Fallback safety
  dir ??= await getApplicationDocumentsDirectory();

  // Ensure directory exists
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final String path = '${dir.path}/$fileName';
  final File file = File(path);

  await file.writeAsBytes(bytes, flush: true);

  print('File saved at: $path');

  return path;
}
