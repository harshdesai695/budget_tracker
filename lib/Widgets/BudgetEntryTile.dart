import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetEntryTile extends StatelessWidget {
  final BudgetEntry entry;
  final Category category;
  final VoidCallback onDismissed; // <-- ADDED: For swipe-to-delete
  final VoidCallback onTap; // <-- ADDED: For editing

  const BudgetEntryTile({
    super.key,
    required this.entry,
    required this.category,
    required this.onDismissed, // <-- ADDED
    required this.onTap, // <-- ADDED
  });

  @override
  Widget build(BuildContext context) {
    // --- WRAPPED with Dismissible ---
    return Dismissible(
      key: Key(entry.id), // Unique key for the dismissible
      direction: DismissDirection.endToStart, // Swipe from right-to-left
      onDismissed: (direction) {
        onDismissed(); // Call the delete callback
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          // This container adds the colored border on the left
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: category.color, width: 5),
            ),
            borderRadius: BorderRadius.circular(12), // Card's default is 12
          ),
          // --- UPDATED ListTile ---
          child: ListTile(
            title: Text(
              entry.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              // Format the date nicely
              DateFormat.yMMMd().format(entry.timestamp.toDate()),
            ),
            trailing: Text(
              '₹${entry.cost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
            onTap: onTap, // Call the edit callback when tapped
          ),
          // --- END OF UPDATED ListTile ---
        ),
      ),
    );
    // --- END OF Dismissible ---
  }
}