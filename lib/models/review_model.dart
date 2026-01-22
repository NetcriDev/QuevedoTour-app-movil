import 'dart:convert';

class Review {
  final String id;
  final String establishmentId;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;
  final bool isSynced;

  Review({
    required this.id,
    required this.establishmentId,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
    this.isSynced = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Handle images which could be a JSON string or a List
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is String) {
        try {
          imagesList = List<String>.from(jsonDecode(json['images']));
        } catch (e) {
          imagesList = [];
        }
      } else if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      }
    }

    return Review(
      id: json['id']?.toString() ?? '',
      establishmentId: json['id_establishment']?.toString() ?? json['establishment_id']?.toString() ?? '',
      userId: json['id_user']?.toString() ?? json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? 'Usuario',
      userEmail: json['user_email'],
      userImage: json['user_image'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null 
          ? (json['created_at'] is int 
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at']) 
              : DateTime.tryParse(json['created_at']) ?? DateTime.now())
          : DateTime.now(),
      images: imagesList,
      isSynced: json['is_synced'] == 1 || json['is_synced'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_establishment': establishmentId,
      'id_user': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_image': userImage,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'images': jsonEncode(images),
      'is_synced': isSynced ? 1 : 0,
    };
  }
}
