import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:budget_tracker/Services/FireBase.dart';
import 'package:flutter/material.dart';

class AddEntryDialog extends StatefulWidget {
  final List<Category> categories;
  final BudgetEntry? entryToEdit;

  const AddEntryDialog({super.key, required this.categories, this.entryToEdit});

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _costController = TextEditingController();
  Category? _selectedCategory;
  bool _isLoading = false;
  bool get _isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final entry = widget.entryToEdit!;
      _itemController.text = entry.itemName;
      _costController.text = entry.cost.toString();
      _selectedCategory = widget.categories.firstWhere(
        (c) => c.id == entry.categoryId,
        orElse: () => widget.categories.first,
      );
    } else {
      if (widget.categories.isNotEmpty) {
        _selectedCategory = widget.categories.first;
      }
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isLoading = true);

      final itemName = _itemController.text;
      final cost = double.tryParse(_costController.text) ?? 0.0;
      final categoryId = _selectedCategory!.id;

      try {
        if (_isEditing) {
          Map<String, dynamic> updatedData = {
            'itemName': itemName,
            'cost': cost,
            'categoryId': categoryId,
          };
          await FireBaseMethods().updateBudgetEntry(
            widget.entryToEdit!.id,
            updatedData,
          );
        } else {
          await FireBaseMethods().addBudgetEntry(
            itemName: itemName,
            cost: cost,
            categoryId: categoryId,
          );
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save entry: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Budget Entry' : 'Add Budget Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an item name'
                    : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  prefixText: '₹',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: category.color, size: 16),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() => _selectedCategory = category);
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
            ],
          ),
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
