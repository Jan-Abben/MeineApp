import 'package:flutter/material.dart';

//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

//Hilfsklassen und Methoden
class PageItem {
  final String title;
  final Widget page;
  final IconData icon;

  const PageItem({required this.title, required this.page, required this.icon});
}

class FoodItem {
  final String name;
  final int calories;
  final int protein;

  FoodItem({required this.name, required this.calories, required this.protein});
}

class RecipeItem {
  final String name;
  final Map<String, double> ingredients; // Map von Lebensmittelname zu Menge
  final int calories;
  final int protein;

  RecipeItem({
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.protein,
  });
}

class TrackingItem {
  final String name;
  final Map<String, double> food; // Map von Lebensmittelname zu Menge
  final int calories;
  final int protein;

  TrackingItem({
    required this.name,
    required this.food,
    required this.calories,
    required this.protein,
  });
}

class IngredientInput {
  String name = "";
  String amount = "";
  //String unit = "";
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<FoodItem> getFoodItem(String name) async {
    final documentSnapshot = await _db
        .collection('Lebensmittel')
        .doc(name)
        .get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data()!;
      return FoodItem(
        name: name,
        calories: data['calories'],
        protein: data['protein'],
      );
    } else {
      throw Exception('Food item not found');
    }
  }

  Future<void> addFoodItem(FoodItem foodItem) async {
    await _db.collection('Lebensmittel').doc(foodItem.name).set({
      'calories': foodItem.calories,
      'protein': foodItem.protein,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllFoodItems() {
    return FirebaseFirestore.instance.collection('Lebensmittel').snapshots();
  }

  Future<RecipeItem> getRecipeItem(String name) async {
    final documentSnapshot = await _db.collection('Rezepte').doc(name).get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data()!;
      return RecipeItem(
        name: name,
        ingredients: data['ingredients'],
        calories: data['calories'],
        protein: data['protein'],
      );
    } else {
      throw Exception('Recipe item not found');
    }
  }

  Future<void> addRecipeItem(RecipeItem recipeItem) async {
    await _db.collection('Rezepte').doc(recipeItem.name).set({
      'ingredients': recipeItem.ingredients,
      'calories': recipeItem.calories,
      'protein': recipeItem.protein,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllRecipeItems() {
    return FirebaseFirestore.instance.collection('Rezepte').snapshots();
  }

  Future<TrackingItem> getTrackingItem(String name) async {
    final documentSnapshot = await _db
        .collection('Lebensmittelverfolgung')
        .doc(name)
        .get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data()!;
      return TrackingItem(
        name: name,
        food: data['food'],
        calories: data['calories'],
        protein: data['protein'],
      );
    } else {
      throw Exception('Tracking item not found');
    }
  }

  Future<void> addTrackingItem(TrackingItem trackingItem) async {
    await _db.collection('Lebensmittelverfolgung').doc(trackingItem.name).set({
      'food': trackingItem.food,
      'calories': trackingItem.calories,
      'protein': trackingItem.protein,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTrackingItems() {
    return FirebaseFirestore.instance
        .collection('Lebensmittelverfolgung')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getTrackedValues(String name) async {
    List<Map<String, dynamic>> result = [];

    final documentSnapshot = await _db
        .collection('Lebensmittelverfolgung')
        .doc(name)
        .get();
    if (documentSnapshot.exists) {
      final food = documentSnapshot.data()!['food'] as Map<String, double>;

      food.forEach((name, amount) async {
        try {
          FoodItem item = await getFoodItem(name);
          result.add({
            'protein': (item.protein * amount).round(),
            'calories': (item.calories * amount / 10).round() * 10,
            'name': name,
            'amount': amount,
          });

        } catch (e) {
          print("Food item not found");
          try {
            RecipeItem item = await getRecipeItem(name);
            result.add({
              'protein': (item.protein * amount).round(),
              'calories': (item.calories * amount / 10).round() * 10,
              'name': name,
              'amount': amount,
            });

          } catch (e) {
            print("Recipe item not found");
          }
        }
      });
    } else {
      throw Exception('Tracking data not found');
    }

    return result;
  }
}
