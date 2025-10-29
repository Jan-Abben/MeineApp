import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> _localPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<File> _localFile(String filename) async {
  final path = await _localPath();
  return File('$path/$filename');
}


//Handling CSV-Files with Lists
Future<void> writeCsvFile(String filename, List<List<dynamic>> rows) async {
  final csv = const ListToCsvConverter().convert(rows);
  final file = await _localFile(filename);
  await file.writeAsString(csv, encoding: utf8);
}

Future<List<List<dynamic>>> readCsvFile(String filename) async {
  final file = await _localFile(filename);
  if (!await file.exists()) return <List<dynamic>>[];
  final contents = await file.readAsString(encoding: utf8);
  // CsvToListConverter converts CSV string into List<List<dynamic>>
  final rows = const CsvToListConverter().convert(contents);
  return rows;
}


//Handling CSV-Files with Maps
Future<void> writeObjectsAsCsv(String filename, List<Map<String, dynamic>> items) async {
  if (items.isEmpty) return;
  final headers = items.first.keys.toList();
  final rows = <List<dynamic>>[headers];
  for (final item in items) {
    rows.add(headers.map((h) => item[h] ?? '').toList());
  }
  final csv = const ListToCsvConverter().convert(rows);
  final file = await _localFile(filename);
  await file.writeAsString(csv, encoding: utf8);
}

Future<List<Map<String, dynamic>>> readCsvAsObjects(String filename) async {

  final lists = await readCsvFile(filename);

  if (lists.isEmpty) return [];
  
  List<String> keys = lists[0].cast<String>();

  List<Map<String, dynamic>> items = [];

  for (final list in lists.skip(1)) {
    items.add(Map.fromIterables(keys, list));
    }

    return items;
  }
  

  Future<String> getPath() async {
  return await _localPath(); // example: returns Future<String>
}

  void main() async {
    // Example usage:
    List<List<dynamic>> rows = [
      ['Name', 'Age', 'City'],
      ['Alice', 30, 'New York'],
      ['Bob', 25, 'Los Angeles'],
    ];

    await writeCsvFile("test.csv", rows);
    //print(await readCsvFile("test.csv"));

    List<Map<String, dynamic>> objects = [
      {'Name': 'Alice', 'Age': 30, 'City': 'New York'},
      {'Name': 'Bob', 'Age': 25, 'City': 'Los Angeles'},
    ];

    await writeObjectsAsCsv("test2.csv", objects);
    //print(await readCsvAsObjects("test2.csv"));
    //print('---');
    
    final rawData = await rootBundle.loadString('assets/data/sample.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
    print(csvTable);
    //habe System für Entwickler auf dem PC wieder deaktiviert
  }
