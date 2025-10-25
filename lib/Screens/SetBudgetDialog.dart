import 'package:budget_tracker/Services/FireBase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SetBudgetDialog extends StatefulWidget {
  final String currentYearMonth; // Format "YYYY-MM"
  final double initialBudget;

  const SetBudgetDialog({
    super.key,
    required this.currentYearMonth,
    required this.initialBudget,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the current budget if it exists
    if (widget.initialBudget > 0) {
      _budgetController.text = widget.initialBudget.toStringAsFixed(0); // Show as whole number
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final budget = double.tryParse(_budgetController.text) ?? 0.0;

      try {
        await FireBaseMethods().setMonthlyBudget(widget.currentYearMonth, budget);
        if (mounted) Navigator.of(context).pop(); // Close dialog on success
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set budget: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format month name (e.g., "October 2025")
    final monthName = DateFormat('MMMM yyyy').format(
      DateFormat('yyyy-MM').parse(widget.currentYearMonth)
    );

    return AlertDialog(
      title: Text('Set Budget for $monthName'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _budgetController,
          decoration: const InputDecoration(labelText: 'Monthly Budget', prefixText: '₹'),
          keyboardType: const TextInputType.numberWithOptions(decimal: false), // Allow only whole numbers
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget amount';
            }
            if (double.tryParse(value) == null || double.parse(value) < 0) {
              return 'Please enter a valid positive number';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}