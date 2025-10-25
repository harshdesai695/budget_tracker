import 'dart:async';

import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:budget_tracker/Utils/Helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final docSnap = await _userDocRef!.get();
    if (!docSnap.exists) {
      await _userDocRef!.set({
        "email": email,
        "username": username,
        "imgUrl": profileUrl,
        "monthlyBudgets": {},
      });
    } else {
       await _userDocRef!.set({
        "email": email,
        "username": username,
        "imgUrl": profileUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<void> setMonthlyBudget(String yearMonth, double budget) async {
    if (_userDocRef == null) return;
    await _userDocRef!.set({'monthlyBudgets': {}}, SetOptions(merge: true));
    await _userDocRef!.update({
      'monthlyBudgets.$yearMonth': budget,
    });
  }

  Future<double?> getMonthlyBudget(String yearMonth) async {
    if (_userDocRef == null) return null;
    try {
      final docSnapshot = await _userDocRef!.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        final budgets = data?['monthlyBudgets'] as Map<String, dynamic>?;
        final budgetValue = budgets?[yearMonth];
        if (budgetValue is num) {
          return budgetValue.toDouble();
        }
      }
    } catch (e) {
      print("Error getting monthly budget: $e");
    }
    return null;
  }

  Stream<List<BudgetEntry>> getBudgetEntriesForMonth(int year, int month) {
    if (_userDocRef == null) {
      return Stream.value(<BudgetEntry>[]).asBroadcastStream();
    }

    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return _userDocRef!
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThan: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetEntry.fromFirestore(doc))
            .toList())
        .asBroadcastStream();
  }

  Future<void> addDefaultCategories() async {
    if (_userDocRef == null) return;

    final categoriesCollection = _userDocRef!.collection('categories');
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
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      if (kDebugMode) {
        print("Category '$name' already exists.");
      }
      return;
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

  Future<void> addBudgetEntry({
    required String itemName,
    required double cost,
    required String categoryId,
  }) async {
    if (_userDocRef == null) return;

    await _userDocRef!.collection('entries').add({
      'itemName': itemName,
      'cost': cost,
      'categoryId': categoryId,
      'timestamp': Timestamp.now(),
    });
  }

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
    await _userDocRef!.collection('entries').doc(entryId).update(dataToUpdate);
  }

  Future<void> deleteBudgetEntry(String entryId) async {
    if (_userDocRef == null) return;
    await _userDocRef!.collection('entries').doc(entryId).delete();
  }
}