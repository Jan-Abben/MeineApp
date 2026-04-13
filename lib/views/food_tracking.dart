import 'package:flutter/material.dart';

class FoodTracking extends StatefulWidget {
  const FoodTracking({super.key});

  @override
  State<FoodTracking> createState() => _FoodTrackingState();
}

class _FoodTrackingState extends State<FoodTracking> {
  @override
  Widget build(BuildContext context) {
    return Text("Lebensmittelverfolgung");
  }
}