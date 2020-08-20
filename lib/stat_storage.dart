import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sudoku_free/statistics.dart';

class StatsStorage {
  final String fileName;

  StatsStorage(this.fileName);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/files/$fileName.json');
  }

  Future<Statistics> readFile() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        String contents = await file.readAsString();
        Map statMap = jsonDecode(contents);
        print(contents);
        return Statistics.fromJson(statMap);
      } else {
        return new Statistics(0, 0, 0, "--:--");
      }

      // Read the file

    } catch (e) {
      // If encountering an error, return 0
      return new Statistics(0, 0, 0, "--:--");
    }
  }

  Future<File> writeUpdate(Statistics stats) async {
    print('writeUpdate 1');
    final file = await _localFile;
    print('writeUpdate 2');
    // Write the file
    return file.writeAsString(stats.toJson().toString());
  }

  static Future<Statistics> readFileName(String fileName, int diff) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    try {
      final file = File('$path/files/$fileName.json');

      if (await file.exists()) {
        print('$fileName exists reading.');
        // Read the file
        String contents = await file.readAsString();
        Map statMap = jsonDecode(contents);
        print('readFileName $fileName $contents');
        return Statistics.fromJson(statMap);
      } else {
        print('$fileName create.');
        await file.create(recursive: true);
        await file.writeAsString(defaultContent(diff));
        print('$fileName created successfully.');
        return new Statistics(0, 0, 0, "--:--");
      }
    } catch (e) {
      print(e.toString());
      // If encountering an error, return 0
      return new Statistics(0, 0, 0, "0:00");
    }
  }

  static String defaultContent(int diff) => '''{
    "difficulty": $diff,
    "totalgames": 0,
    "gameswon": 0,
    "besttime": "--:--"
  }''';
}
