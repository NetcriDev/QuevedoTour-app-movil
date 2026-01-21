import 'package:flutter/material.dart';

// Helper to map string icons from backend to IconData
IconData getIconData(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'restaurant': return Icons.restaurant;
    case 'restaurantv': return Icons.restaurant; // Typo in backend seed?
    case 'hotel': return Icons.hotel;
    case 'museum': return Icons.museum;
    case 'park': return Icons.park;
    case 'shopping_bag': return Icons.shopping_bag;
    case 'directions_bus': return Icons.directions_bus;
    case 'map': return Icons.map;
    case 'contact_phone': return Icons.contact_phone;
    default: return Icons.category;
  }
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.subCategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      icon: getIconData(json['icon'] ?? ''),
      subCategories: [], // Subcategories usually fetched separately or mapped if nested
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String parentId;

  SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      parentId: json['id_category']?.toString() ?? '',
    );
  }
}

class Establishment {
  final String id;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final String mainImage;
  final List<String> galleryImages;
  final String categoryId;
  final String subCategoryId;
  final String phone;
  final String? website;
  final String priceRange; 
  final Map<String, String> hours; 
  final bool isFeatured;

  Establishment({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.mainImage,
    required this.galleryImages,
    required this.categoryId,
    required this.subCategoryId,
    required this.phone,
    this.website,
    required this.priceRange,
    required this.hours,
    this.isFeatured = false,
  });

  factory Establishment.fromJson(Map<String, dynamic> json) {
    // Parse location "lat,lng" string if available
    double lat = 0.0;
    double lng = 0.0;
    if (json['location'] != null && json['location'].toString().contains(',')) {
      final parts = json['location'].toString().split(',');
      lat = double.tryParse(parts[0]) ?? 0.0;
      lng = double.tryParse(parts[1]) ?? 0.0;
    }

    // Parse images
    // Backend returns "images": ["url1", "url2"]
    List<String> images = [];
    if (json['images'] != null) {
      images = List<String>.from(json['images']);
    } else {
      // Fallback to image1, image2 fields if present (backward compatibility)
      if (json['image1'] != null) images.add(json['image1']);
      if (json['image2'] != null) images.add(json['image2']);
      if (json['image3'] != null) images.add(json['image3']);
    }
    
    String mainImg = images.isNotEmpty ? images[0] : 'https://via.placeholder.com/300';
    
    // Parse price to range
    String priceRange = '\$';
    if (json['price'] != null) {
      double price = double.tryParse(json['price'].toString()) ?? 0.0;
      if (price > 20) priceRange = '\$\$\$';
      else if (price > 10) priceRange = '\$\$';
    }

    return Establishment(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: lat,
      lng: lng,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      mainImage: mainImg,
      galleryImages: images,
      categoryId: json['id_category']?.toString() ?? '',
      subCategoryId: json['id_sub_category']?.toString() ?? '',
      phone: json['phone'] ?? '',
      website: json['website'],
      priceRange: priceRange,
      hours: {'Lunes-Domingo': '09:00 - 20:00'}, // Default as backend doesn't have hours yet
      isFeatured: false, // Default
    );
  }
}

class AppBanner {
  final String id;
  final String imageUrl;
  final String? link;
  final String title;

  AppBanner({
    required this.id,
    required this.imageUrl,
    this.link,
    required this.title,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['id'].toString(),
      imageUrl: json['image'] ?? '',
      title: json['title'] ?? '',
      link: null, 
    );
  }
}
