import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetEntry {
  final String id;
  final String itemName;
  final double cost;
  final String categoryId;
  final Timestamp timestamp;

  BudgetEntry({
    required this.id,
    required this.itemName,
    required this.cost,
    required this.categoryId,
    required this.timestamp,
  });

  // Factory to create a BudgetEntry from a Firestore document
  factory BudgetEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BudgetEntry(
      id: doc.id,
      itemName: data['itemName'] ?? 'No Name',
      cost: (data['cost'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert a BudgetEntry to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'cost': cost,
      'categoryId': categoryId,
      'timestamp': timestamp,
    };
  }
}