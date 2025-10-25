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

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? 'Unnamed',
      color: ColorHelpers.colorFromHex(data['color'] ?? '808080'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': ColorHelpers.colorToHex(color),
    };
  }
}