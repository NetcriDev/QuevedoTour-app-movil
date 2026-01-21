import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import 'package:uuid/uuid.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;

  const CategoryForm({super.key, this.category});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  IconData _selectedIcon = Icons.category;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.hotel,
    Icons.museum,
    Icons.park,
    Icons.shopping_bag,
    Icons.directions_bus,
    Icons.map,
    Icons.contact_phone,
    Icons.local_hospital,
    Icons.school,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) {
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (widget.category == null) {
        // Create
        final newCategory = Category(
          id: const Uuid().v4(),
          name: _nameController.text,
          icon: _selectedIcon,
        );
        provider.addCategory(newCategory);
      } else {
        // Update
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _nameController.text,
          icon: _selectedIcon,
          subCategories: widget.category!.subCategories,
        );
        provider.updateCategory(updatedCategory);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category == null ? 'Nueva Categoría' : 'Editar Categoría')),
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
              const Text('Icono'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableIcons.map((icon) {
                  return ChoiceChip(
                    label: Icon(icon),
                    selected: _selectedIcon == icon,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                  );
                }).toList(),
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
