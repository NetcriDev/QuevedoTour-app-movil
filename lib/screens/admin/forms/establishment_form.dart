import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import 'package:uuid/uuid.dart';

class EstablishmentForm extends StatefulWidget {
  final Establishment? establishment;

  const EstablishmentForm({super.key, this.establishment});

  @override
  State<EstablishmentForm> createState() => _EstablishmentFormState();
}

class _EstablishmentFormState extends State<EstablishmentForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _imageController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String _priceRange = '\$';

  @override
  void initState() {
    super.initState();
    final e = widget.establishment;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _addressController = TextEditingController(text: e?.address ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _imageController = TextEditingController(text: e?.mainImage ?? '');
    _latController = TextEditingController(text: e?.lat.toString() ?? '');
    _lngController = TextEditingController(text: e?.lng.toString() ?? '');
    
    _selectedCategoryId = e?.categoryId;
    _selectedSubCategoryId = e?.subCategoryId;
    if (e != null) _priceRange = e.priceRange;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
       if (_selectedCategoryId == null || _selectedSubCategoryId == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione Categoría y Subcategoría')));
         return;
       }

      final provider = Provider.of<AppProvider>(context, listen: false);
      final double lat = double.tryParse(_latController.text) ?? 0.0;
      final double lng = double.tryParse(_lngController.text) ?? 0.0;

      final establishment = Establishment(
        id: widget.establishment?.id ?? const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        lat: lat,
        lng: lng,
        rating: widget.establishment?.rating ?? 0.0, // Default 0 or keep existing
        mainImage: _imageController.text,
        galleryImages: widget.establishment?.galleryImages ?? [_imageController.text], // Simple default
        categoryId: _selectedCategoryId!,
        subCategoryId: _selectedSubCategoryId!,
        phone: _phoneController.text,
        priceRange: _priceRange,
        hours: widget.establishment?.hours ?? {}, // Empty for now
        isFeatured: widget.establishment?.isFeatured ?? false,
      );

      if (widget.establishment == null) {
        provider.addEstablishment(establishment);
      } else {
        provider.updateEstablishment(establishment);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = provider.categories;
    
    // Filter subcategories based on selected category
    List<SubCategory> subCategories = [];
    if (_selectedCategoryId != null) {
      final cat = categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => categories.first);
      subCategories = cat.subCategories;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.establishment == null ? 'Nuevo Establecimiento' : 'Editar Establecimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                   Expanded(
                     child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                          _selectedSubCategoryId = null; // Reset sub
                        });
                      },
                  ),
                   ),
                   const SizedBox(width: 10),
                   Expanded(
                     child: DropdownButtonFormField<String>(
                      value: _selectedSubCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Subcategoría'),
                      items: subCategories.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (value) {
                         setState(() {
                           _selectedSubCategoryId = value;
                         });
                      },
                  ),
                   ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'URL Imagen Principal'),
              ),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitud'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitud'))),
                ],
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              DropdownButtonFormField<String>(
                value: _priceRange,
                decoration: const InputDecoration(labelText: 'Rango de Precios'),
                items: ['\$', '\$\$', '\$\$\$'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _priceRange = v!),
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
