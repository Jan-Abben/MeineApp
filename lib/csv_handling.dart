import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


class Meals {
  final String name;
  final int calories;
  final int protein;
  final List<Map<String, dynamic>> ingredients;

  Meals({required this.name, required this.calories, required this.protein, required this.ingredients});

  factory Meals.fromJson(Map<String, dynamic> json) {
    return Meals(
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'],
      ingredients: List<Map<String, dynamic>>.from(json['ingredients']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'ingredients': ingredients,
      };
}

const decoder = JsonDecoder();
const encoder = JsonEncoder();



Future<String> _localPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<File> _localFile(String filename) async {
  final path = await _localPath();
  return File('$path/$filename');
}


//Handling JSON-Files
Future<void> writeMealsFile(String filename, Meals meals) async {
  final json = meals.toJson();
  final file = await _localFile(filename);
  await file.writeAsString(encoder.convert(json));
}

Future<Meals> readMeals(String filename) async {
  final file = await _localFile(filename);
  if (!await file.exists()) return Meals(name: "NotFound", calories: 0, protein: 0, ingredients: []);

  final contents = decoder.convert(await file.readAsString());
  return Meals.fromJson(contents);
}


  

  void main() async {
    
    final rawData = await rootBundle.loadString('assets/data/sample.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
    print(csvTable);
    //habe System für Entwickler auf dem PC wieder deaktiviert
  }
