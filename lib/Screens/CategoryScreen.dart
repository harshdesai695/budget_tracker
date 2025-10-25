import 'package:budget_tracker/Models/Category.dart';
import 'package:budget_tracker/Services/FireBase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue; // Default color

  void _showAddEditCategoryDialog({Category? categoryToEdit}) {
    final bool isEditing = categoryToEdit != null;

    if (isEditing) {
      _nameController.text = categoryToEdit.name;
      _selectedColor = categoryToEdit.color;
    } else {
      _nameController.clear();
      _selectedColor = Colors.blue;
    }

    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to manage the dialog's internal state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),

                    ColorPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setDialogState(() => _selectedColor = color);
                      },
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      if (isEditing) {
                        await FireBaseMethods().updateCategory(
                          categoryToEdit.id,
                          _nameController.text,
                          _selectedColor,
                        );
                      } else {
                        await FireBaseMethods().addNewCategory(
                          _nameController.text,
                          _selectedColor,
                        );
                      }
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'Are you sure you want to delete the "${category.name}" category?\n\n'
            'This will also delete ALL budget entries associated with it.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FireBaseMethods().deleteCategory(category.id);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: StreamBuilder<List<Category>>(
        stream: FireBaseMethods().getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: Icon(Icons.circle, color: category.color),
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        _showAddEditCategoryDialog(categoryToEdit: category);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _showDeleteConfirmDialog(category);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEditCategoryDialog, // Calls in "Add" mode
        child: const Icon(Icons.add),
      ),
    );
  }
}
