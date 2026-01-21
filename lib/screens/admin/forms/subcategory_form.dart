import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import 'package:uuid/uuid.dart';

class SubCategoryForm extends StatefulWidget {
  final SubCategory? subCategory;

  const SubCategoryForm({super.key, this.subCategory});

  @override
  State<SubCategoryForm> createState() => _SubCategoryFormState();
}

class _SubCategoryFormState extends State<SubCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subCategory?.name ?? '');
    _selectedParentId = widget.subCategory?.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (widget.subCategory == null) {
        // Create
        final newSub = SubCategory(
          id: const Uuid().v4(),
          name: _nameController.text,
          parentId: _selectedParentId!,
        );
        provider.addSubCategory(newSub);
      } else {
        // Update
        // Note: If parent changed, we need to remove from old parent and add to new. 
        // For simplicity, we assume parent change handled by delete/add or just update within same parent for now if logic allows.
        // My simple provider logic for updateSubCategory assumes parentId matches the one in list.
        // Changing parent is complex with current provider logic (nested list).
        // Let's stick to update same parent or warn.
        
        final updatedSub = SubCategory(
          id: widget.subCategory!.id,
          name: _nameController.text,
          parentId: _selectedParentId!,
        );
        
        if (widget.subCategory!.parentId != _selectedParentId) {
             // Handle move: Remove from old, Add to new
             provider.deleteSubCategory(widget.subCategory!.id, widget.subCategory!.parentId);
             provider.addSubCategory(updatedSub);
        } else {
             provider.updateSubCategory(updatedSub);
        }
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<AppProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(title: Text(widget.subCategory == null ? 'Nueva Subcategoría' : 'Editar Subcategoría')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedParentId,
                decoration: const InputDecoration(labelText: 'Categoría Padre'),
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                  });
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
