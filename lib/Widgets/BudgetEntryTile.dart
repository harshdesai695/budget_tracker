import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetEntryTile extends StatelessWidget {
  final BudgetEntry entry;
  final Category category;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  const BudgetEntryTile({
    super.key,
    required this.entry,
    required this.category,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDismissed();
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
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: category.color, width: 5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              entry.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
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
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}