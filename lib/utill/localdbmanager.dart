import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalDBManager {
  final String fileName;

  LocalDBManager({required this.fileName});

  Future<void> saveObject(Map<String,dynamic> myObject) async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${documentsDirectory.path}/$fileName';

    final file = File(filePath);
    final jsonData = jsonEncode(myObject);
    await file.writeAsString(jsonData);
  }

  Future<Map<String,dynamic>?> readObject() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/$fileName';

      final file = File(filePath);
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap;
    } catch (e) {
      print("Error reading file: $e");
      return null;
    }
  }

  Future<void> deleteFile() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print("File deleted successfully");
      } else {
        print("File does not exist");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

}

