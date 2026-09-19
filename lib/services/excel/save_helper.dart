// 📄 File: lib/services/excel/save_helper.dart

// 1. Define the stub (fallback)
import 'save_helper_mobile.dart' // Default to mobile
if (dart.library.html) 'save_helper_web.dart'; // Switch to web if on HTML

// 2. Expose a single function that both files must implement
Future<String?> saveExcelFile(List<int> bytes, String fileName) {
  return saveHelper(bytes, fileName);
}