import 'package:budget_tracker/Utils/Helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  // Factory constructor to create a Category from a Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? 'Unnamed',
      // Use the helper to convert hex string to Color, default to grey
      color: ColorHelpers.colorFromHex(data['color'] ?? '808080'),
    );
  }

  // Method to convert a Category object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      // Use the helper to convert Color to hex string
      'color': ColorHelpers.colorToHex(color),
    };
  }
}