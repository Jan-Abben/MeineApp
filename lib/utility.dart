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
  final Map<String, dynamic> ingredients; // Map von Lebensmittelname zu Menge
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
  final Map<String, dynamic> food; // Map von Lebensmittelname zu Menge
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

  Future<void> createTrackingToday(String name) async {
    final documentSnapshot = await _db
        .collection('Lebensmittelverfolgung')
        .doc(name)
        .get();
    if (!documentSnapshot.exists) {
      await _db.collection('Lebensmittelverfolgung').doc(name).set({
        'calories': 0,
        'protein': 0,
        'food': {},
      });
    }
  }

  Stream<TrackingItem> getTrackingItemStream(String name) {
    return FirebaseFirestore.instance
        .collection('Lebensmittelverfolgung')
        .doc(name)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data()!;

          return TrackingItem(
            name: data['name'],
            food: (data['food'] as Map<String, dynamic>),
            calories: data['calories'],
            protein: data['protein'],
          );
        });
  }

  Future<TrackingItem> addEntryToTrackingItem(
    TrackingItem trackingItem,
    String name,
    double amount,
  ) async {
    // Update the food map
    Map<String, dynamic> food = {...trackingItem.food, name: amount};
    int calories = trackingItem.calories;
    int protein = trackingItem.protein;

    // Get the food item to calculate calories and protein
    try {
      FoodItem foodItem = await getFoodItem(name);
      calories += (foodItem.calories * amount / 10).round() * 10;
      protein += (foodItem.protein * amount).round();
    } catch (e) {
      try {
        RecipeItem recipeItem = await getRecipeItem(name);
        calories += (recipeItem.calories * amount / 10).round() * 10;
        protein += (recipeItem.protein * amount).round();
      } catch (e) {
        print("Food or Recipe item not found");
      }
    }
    TrackingItem updatedTrackingItem = TrackingItem(
      name: trackingItem.name,
      food: food,
      calories: calories,
      protein: protein,
    );

    return updatedTrackingItem;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTrackingItems() {
    return FirebaseFirestore.instance
        .collection('Lebensmittelverfolgung')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getTrackedValues(
    TrackingItem trackingItem,
  ) async {
    List<Map<String, dynamic>> result = [];

    //print("documentSnapshot.exists: ${documentSnapshot.exists}");
    //print("documentSnapshot.data(): ${documentSnapshot.data()!['food']}")

    for (final entry in trackingItem.food.entries) {
      final name = entry.key;
      final amount = entry.value;
      try {
        FoodItem item = await getFoodItem(name);
        result.add({
          'protein': (item.protein * amount).round(),
          'calories': (item.calories * amount / 10).round() * 10,
          'name': name,
          'amount': amount,
        });
      } catch (e) {
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
    }
    return result;
  }

  Stream<List<Map<String, dynamic>>> getTrackedValuesStream(String name) {
    return getTrackingItemStream(name).asyncMap((item) async {
      return await getTrackedValues(item);
    });
  }
}
