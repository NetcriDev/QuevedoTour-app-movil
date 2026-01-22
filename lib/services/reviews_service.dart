import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/review_model.dart';

class ReviewsService {
  final Dio _dio = Dio();

  ReviewsService() {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  Future<List<Review>> getReviews(String establishmentId) async {
    try {
      final response = await _dio.get('/reviews/findByEstablishment/$establishmentId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Future<Review?> createReview({
    required String establishmentId,
    required String userId,
    required double rating,
    required String comment,
    required String sessionToken,
    List<String> images = const [],
  }) async {
    try {
      final Map<String, dynamic> reviewData = {
        'id_establishment': establishmentId,
        'id_user': userId,
        'rating': rating,
        'comment': comment,
      };

      final FormData formData = FormData.fromMap({
        'review': jsonEncode(reviewData),
      });

      // Add images if any and if they are local paths
      for (var imagePath in images) {
        if (!imagePath.startsWith('http')) {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(imagePath),
          ));
        }
      }

      final response = await _dio.post(
        '/reviews/create',
        data: formData,
        options: Options(
          headers: {'Authorization': sessionToken},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return Review.fromJson(response.data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating review: $e');
      return null;
    }
  }

  Future<bool> deleteReview(String reviewId, String sessionToken) async {
    try {
      final response = await _dio.delete(
        '/reviews/delete',
        data: {'id': reviewId},
        options: Options(
          headers: {'Authorization': sessionToken},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }
}
