import 'dart:async'; // Added for Completer

import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:budget_tracker/Utils/Helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

class FireBaseMethods {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? get _userID => auth.currentUser?.uid;

  DocumentReference? get _userDocRef {
    final id = _userID;
    if (id == null) return null;
    return firestore.collection("users").doc(id);
  }

  Future<User?> get currentUser async {
    return auth.currentUser;
  }

  Future<void> addUserdata({
    required String email,
    required String username,
    required String profileUrl,
  }) async {
    if (_userDocRef == null) return;
    // Check if the document already exists before setting default budgets
    final docSnap = await _userDocRef!.get();
    if (!docSnap.exists) {
      await _userDocRef!.set({
        "email": email,
        "username": username,
        "imgUrl": profileUrl,
        // Initialize the budgets map only for new users
        "monthlyBudgets": {},
      });
    } else {
      // If user exists, just update basic info (optional, depending on desired behavior)
       await _userDocRef!.set({
        "email": email,
        "username": username,
        "imgUrl": profileUrl,
      }, SetOptions(merge: true)); // Use merge to avoid overwriting budgets
    }
  }

  // --- MONTHLY BUDGET LOGIC ---

  /// Sets the budget for a specific month (YYYY-MM).
  Future<void> setMonthlyBudget(String yearMonth, double budget) async {
    if (_userDocRef == null) return;
    // Update the map field, using dot notation for nested fields
    // Ensure the monthlyBudgets field exists before trying to update a subfield
    await _userDocRef!.set({'monthlyBudgets': {}}, SetOptions(merge: true)); // Ensure map exists
    await _userDocRef!.update({
      'monthlyBudgets.$yearMonth': budget,
    });
  }

  /// Gets the budget for a specific month (YYYY-MM). Returns null if not set.
  Future<double?> getMonthlyBudget(String yearMonth) async {
    if (_userDocRef == null) return null;
    try {
      final docSnapshot = await _userDocRef!.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        // Access the nested map value
        final budgets = data?['monthlyBudgets'] as Map<String, dynamic>?;
        // Handle potential null or incorrect type
        final budgetValue = budgets?[yearMonth];
        if (budgetValue is num) {
          return budgetValue.toDouble();
        }
      }
    } catch (e) {
      print("Error getting monthly budget: $e");
    }
    return null; // Return null if not found or error occurs
  }

  /// Gets a stream of budget entries ONLY for a specific month.
  Stream<List<BudgetEntry>> getBudgetEntriesForMonth(int year, int month) {
    if (_userDocRef == null) {
      return Stream.value(<BudgetEntry>[]).asBroadcastStream();
    }

    // Calculate start and end timestamps for the month
    final DateTime startDate = DateTime(year, month, 1);
    // Ensure endDate calculation handles month rollovers correctly
    final DateTime endDate = (month == 12)
        ? DateTime(year + 1, 1, 1) // Next year, first month
        : DateTime(year, month + 1, 1); // Same year, next month

    return _userDocRef!
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThan: Timestamp.fromDate(endDate))
        // No orderBy needed for calculation, removed to avoid index requirement
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetEntry.fromFirestore(doc))
            .toList())
        .asBroadcastStream();
  }

  // --- CATEGORY LOGIC ---
  Future<void> addDefaultCategories() async {
    if (_userDocRef == null) return;

    final categoriesCollection = _userDocRef!.collection('categories');
    // Check if categories already exist to prevent duplicates on re-login
    final existingCategories = await categoriesCollection.limit(1).get();
    if (existingCategories.docs.isNotEmpty) {
      print("Default categories already exist.");
      return;
    }

    WriteBatch batch = firestore.batch();
    final defaultCategories = {
      "General": Colors.grey,
      "Food": Colors.red,
      "Travel": Colors.blue,
      "Shopping": Colors.amber,
      "Others": Colors.purple,
    };

    defaultCategories.forEach((name, color) {
      final docRef = categoriesCollection.doc();
      batch.set(docRef, {
        'name': name,
        'color': ColorHelpers.colorToHex(color),
      });
    });

    await batch.commit();
    print("Default categories added.");
  }

  Future<void> addNewCategory(String name, Color color) async {
    if (_userDocRef == null) return;
    final query = await _userDocRef!
        .collection('categories')
        .where('name', isEqualTo: name) // Consider case-insensitivity if needed
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      if (kDebugMode) {
        print("Category '$name' already exists.");
      }
      return; // Or throw an error/show message to user
    }
    await _userDocRef!.collection('categories').add({
      'name': name,
      'color': ColorHelpers.colorToHex(color),
    });
  }

  Stream<List<Category>> getCategories() {
    if (_userDocRef == null) {
      return Stream.value(<Category>[]).asBroadcastStream();
    }
    return _userDocRef!
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList())
        .asBroadcastStream();
  }

  Future<void> updateCategory(
      String categoryId, String newName, Color newColor) async {
    if (_userDocRef == null) return;
    // Optional: Add check here if newName already exists (excluding the current categoryId)
    await _userDocRef!.collection('categories').doc(categoryId).update({
      'name': newName,
      'color': ColorHelpers.colorToHex(newColor),
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_userDocRef == null) return;

    WriteBatch batch = firestore.batch();
    final categoryRef = _userDocRef!.collection('categories').doc(categoryId);
    final entriesQuery = await _userDocRef!
        .collection('entries')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    for (var doc in entriesQuery.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(categoryRef);
    await batch.commit();
  }

  // --- BUDGET ENTRY LOGIC ---
  Future<void> addBudgetEntry({
    required String itemName,
    required double cost,
    required String categoryId,
  }) async {
    if (_userDocRef == null) return;
    // Ensure categoryId exists before adding (optional but good practice)
    // final categoryExists = await _userDocRef!.collection('categories').doc(categoryId).get().then((doc) => doc.exists);
    // if (!categoryExists) {
    //   print("Error: Category $categoryId does not exist.");
    //   return; // Or handle appropriately
    // }

    await _userDocRef!.collection('entries').add({
      'itemName': itemName,
      'cost': cost,
      'categoryId': categoryId,
      'timestamp': Timestamp.now(),
    });
  }

  /// Gets a real-time stream of *ALL* budget entries, ordered by date.
  Stream<List<BudgetEntry>> getBudgetEntries() {
     if (_userDocRef == null) {
      return Stream.value(<BudgetEntry>[]).asBroadcastStream();
    }
    return _userDocRef!
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BudgetEntry.fromFirestore(doc)).toList())
        .asBroadcastStream();
  }

  Future<void> updateBudgetEntry(
      String entryId, Map<String, dynamic> dataToUpdate) async {
    if (_userDocRef == null) return;
    // You might want to validate dataToUpdate here
    await _userDocRef!.collection('entries').doc(entryId).update(dataToUpdate);
  }

  Future<void> deleteBudgetEntry(String entryId) async {
    if (_userDocRef == null) return;
    await _userDocRef!.collection('entries').doc(entryId).delete();
  }
}