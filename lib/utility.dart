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
  final Map<String, int> ingredients; // Map von Lebensmittelname zu Menge
  final int calories;
  final int protein;

  RecipeItem({required this.name, required this.ingredients, required this.calories, required this.protein});
}



class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addFoodItem(FoodItem foodItem) async {
    await _db.collection('Lebensmittel').doc(foodItem.name).set({
      'calories': foodItem.calories,
      'protein': foodItem.protein,
    });
    
  }

  Future<FoodItem> getFoodItem(String name) async {
    final documentSnapshot = await _db.collection('Lebensmittel').doc(name).get();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllFoodItems() {
    return FirebaseFirestore.instance
      .collection('Lebensmittel')
      .snapshots();
  }


  Future<void> addRecipeItem(RecipeItem recipeItem) async {
    await _db.collection('Rezepte').doc(recipeItem.name).set({
      'ingredients': recipeItem.ingredients,
      'calories': recipeItem.calories,
      'protein': recipeItem.protein,
    });
    
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllRecipeItems() {
    return FirebaseFirestore.instance
      .collection('Rezepte')
      .snapshots();
    }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllTrackingItems() {
    return FirebaseFirestore.instance
      .collection('Lebensmittelverfolgung')
      .orderBy(FieldPath.documentId, descending: true)
      .snapshots();
    }

}