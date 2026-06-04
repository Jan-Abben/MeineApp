import 'package:flutter/material.dart';

class FoodDatabase extends StatefulWidget {
  const FoodDatabase({super.key});

  @override
  State<FoodDatabase> createState() => _FoodDatabaseState();
}

class _FoodDatabaseState extends State<FoodDatabase> {
  @override
  Widget build(BuildContext context) {
    return Text("Lebensmittel-Datenbank");
  }
}