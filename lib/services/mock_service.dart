import 'package:flutter/material.dart';
import '../models/models.dart';

class MockService {
  // Categories
  static final List<Category> categories = [
    Category(id: 'c1', name: 'Alimentos y Bebidas', icon: Icons.restaurant),
    Category(id: 'c2', name: 'Alojamientos', icon: Icons.hotel),
    Category(id: 'c3', name: 'Atractivos Culturales', icon: Icons.museum),
    Category(id: 'c4', name: 'Esparcimientos', icon: Icons.park),
    Category(id: 'c5', name: 'Compras', icon: Icons.shopping_bag),
    Category(id: 'c6', name: 'Transportes', icon: Icons.directions_bus),
    Category(id: 'c7', name: 'Rutas', icon: Icons.map),
    Category(id: 'c8', name: 'Directorio', icon: Icons.contact_phone),
  ];

  // SubCategories
  static final List<SubCategory> subCategories = [
    // Alimentos
    SubCategory(id: 'sc1', name: 'Restaurantes', parentId: 'c1'),
    SubCategory(id: 'sc2', name: 'Comida Rápida', parentId: 'c1'),
    SubCategory(id: 'sc3', name: 'Asaderos', parentId: 'c1'),
    SubCategory(id: 'sc4', name: 'Bares', parentId: 'c1'),
    // Alojamientos
    SubCategory(id: 'sc5', name: 'Hoteles', parentId: 'c2'),
    SubCategory(id: 'sc6', name: 'Moteles', parentId: 'c2'),
    SubCategory(id: 'sc7', name: 'Hostales', parentId: 'c2'),
    SubCategory(id: 'sc8', name: 'Airbnb', parentId: 'c2'),
    // Culture
    SubCategory(id: 'sc9', name: 'Museos', parentId: 'c3'),
    SubCategory(id: 'sc10', name: 'Monumentos', parentId: 'c3'),
    // Leisure
    SubCategory(id: 'sc11', name: 'Parques', parentId: 'c4'),
    SubCategory(id: 'sc12', name: 'Discotecas', parentId: 'c4'),
  ];

  // Banners
  static final List<AppBanner> banners = [
    AppBanner(id: 'b1', imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1000&q=80', title: 'Festival Gastronómico'),
    AppBanner(id: 'b2', imageUrl: 'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?auto=format&fit=crop&w=1000&q=80', title: 'Ruta del Río'),
    AppBanner(id: 'b3', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80', title: 'Hoteles de Lujo'),
  ];

  // Establishments (25 Mock Items)
  static final List<Establishment> establishments = List.generate(25, (index) {
    // Generate varied data based on index
    String catId = 'c1'; // Default food
    String subCatId = 'sc1'; // Default restaurant
    IconData icon = Icons.restaurant;
    String image = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=60';
    String name = 'Restaurante El Buen Sabor ${index + 1}';

    if (index >= 5 && index < 10) {
      catId = 'c2'; // Hotel
      subCatId = 'sc5';
      icon = Icons.hotel;
      image = 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=60';
      name = 'Hotel Plaza ${index + 1}';
    } else if (index >= 10 && index < 15) {
      catId = 'c3'; // Culture
      subCatId = 'sc9';
      icon = Icons.museum;
      image = 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?auto=format&fit=crop&w=800&q=60';
      name = 'Museo de la Ciudad ${index + 1}';
    } else if (index >= 15 && index < 20) {
      catId = 'c4'; // Park
      subCatId = 'sc11';
      icon = Icons.park;
      image = 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=800&q=60';
      name = 'Parque Central ${index + 1}';
    } else if (index >= 20) {
       catId = 'c5'; // Shopping
       subCatId = 'sc1'; // Just map to something
       image = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=60';
       name = 'Centro Comercial Quevedo ${index + 1}';
    }

    return Establishment(
      id: 'e$index',
      name: name,
      description: 'Un lugar increíble para disfrutar con familia y amigos. Ofrecemos los mejores servicios de la ciudad de Quevedo.',
      address: 'Calle $index, Quevedo, Ecuador',
      lat: -1.0286 + (index * 0.001), 
      lng: -79.4635 + (index * 0.001),
      rating: 4.0 + (index % 5) * 0.2, // Random rating 4.0 - 5.0
      mainImage: image,
      galleryImages: [
        image,
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=60',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=60',
      ],
      categoryId: catId,
      subCategoryId: subCatId,
      phone: '099123456$index',
      website: 'https://ejemplo.com',
      priceRange: (index % 3 == 0) ? '\$\$\$' : (index % 2 == 0) ? '\$\$' : '\$',
      hours: {'Lunes-Viernes': '9:00 - 20:00', 'Sábado': '10:00 - 22:00'},
      isFeatured: index < 4, // First 4 featured
    );
  });

  // Simulation Methods
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return categories.map((cat) {
      final subs = subCategories.where((s) => s.parentId == cat.id).toList();
      return Category(
        id: cat.id,
        name: cat.name,
        icon: cat.icon,
        subCategories: subs,
      );
    }).toList();
  }

  Future<List<SubCategory>> getSubCategories(String catId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return subCategories.where((s) => s.parentId == catId).toList();
  }

  Future<List<Establishment>> getEstablishments({String? categoryId, String? subCategoryId, String? query, bool featured = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return establishments.where((e) {
      if (featured && !e.isFeatured) return false;
      if (categoryId != null && e.categoryId != categoryId) return false;
      if (subCategoryId != null && e.subCategoryId != subCategoryId) return false;
      if (query != null && !e.name.toLowerCase().contains(query.toLowerCase())) return false;
      return true;
    }).toList();
  }

   Future<List<AppBanner>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return banners;
  }
}
