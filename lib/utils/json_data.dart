import 'dart:convert';

import 'package:flutter/services.dart';

class JsonDataParser {
  static const TAG = "LocalDataParser:";

  static Future<String> getTaskIconPath(String iconId) async {
    print("$TAG getTaskImagePath called..");
    final result = await rootBundle.loadString('assets/data/task_icons.json');

    final Map<String, dynamic> decodedPaths = jsonDecode(result);
    print("$TAG decodedPath ${decodedPaths[iconId]}");
    return decodedPaths[iconId] ?? "";
  }

  static Future<Map<String, dynamic>> getTasksIcons() async {
    print("$TAG getTasksIcons called..");
    final result = await rootBundle.loadString('assets/data/task_icons.json');

    final decodedPaths = jsonDecode(result);
    return decodedPaths;
  }
}
