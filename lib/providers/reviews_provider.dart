import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/reviews_service.dart';
import '../services/local_storage.dart';

class ReviewsProvider with ChangeNotifier {
  final ReviewsService _reviewsService = ReviewsService();
  final LocalStorage _localStorage = LocalStorage();

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    double sum = _reviews.fold(0, (prev, element) => prev + element.rating);
    return sum / _reviews.length;
  }

  Future<void> loadReviews(String establishmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to load from local first (for offline support)
      final localReviewsData = await _localStorage.getReviewsByEstablishment(establishmentId);
      if (localReviewsData.isNotEmpty) {
        _reviews = localReviewsData.map((json) => Review.fromJson(json)).toList();
        notifyListeners();
      }

      // Then fetch from API
      final apiReviews = await _reviewsService.getReviews(establishmentId);
      
      if (apiReviews.isNotEmpty) {
        _reviews = apiReviews;
        
        // Update local cache
        for (var review in apiReviews) {
          await _localStorage.saveReview(review.toJson());
        }
      }
      
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      _errorMessage = 'Error al cargar las reseñas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview({
    required String establishmentId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    required String sessionToken,
    List<String> images = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newReview = await _reviewsService.createReview(
        establishmentId: establishmentId,
        userId: userId,
        rating: rating,
        comment: comment,
        sessionToken: sessionToken,
        images: images,
      );

      if (newReview != null) {
        _reviews.insert(0, newReview);
        await _localStorage.saveReview(newReview.toJson());
        _errorMessage = null;
        return true;
      } else {
        // If API fails, save locally as unsynced
        final offlineReview = Review(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
          establishmentId: establishmentId,
          userId: userId,
          userName: userName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
          images: images,
          isSynced: false,
        );
        _reviews.insert(0, offlineReview);
        await _localStorage.saveReview(offlineReview.toJson());
        _errorMessage = 'Guardado localmente (sin conexión)';
        return true; // Return true because it's saved locally
      }
    } catch (e) {
      debugPrint('Error adding review: $e');
      // Save locally as unsynced on network error
      final offlineReview = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        establishmentId: establishmentId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        images: images,
        isSynced: false,
      );
      _reviews.insert(0, offlineReview);
      await _localStorage.saveReview(offlineReview.toJson());
      _errorMessage = 'Guardado localmente (sin conexión)';
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncUnsyncedReviews(String sessionToken) async {
    final unsynced = await _localStorage.getUnsyncedReviews();
    if (unsynced.isEmpty) return;

    for (var reviewMap in unsynced) {
      final review = Review.fromJson(reviewMap);
      try {
        final syncedReview = await _reviewsService.createReview(
          establishmentId: review.establishmentId,
          userId: review.userId,
          rating: review.rating,
          comment: review.comment,
          sessionToken: sessionToken,
          images: review.images,
        );

        if (syncedReview != null) {
          // Delete temporary local review and save synced one
          await _localStorage.deleteReview(review.id);
          await _localStorage.saveReview(syncedReview.toJson());
          
          // Update in-memory list if it contains the offline version
          final index = _reviews.indexWhere((r) => r.id == review.id);
          if (index != -1) {
            _reviews[index] = syncedReview;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Failed to sync review ${review.id}: $e');
      }
    }
  }

  Future<bool> deleteReview(String reviewId, String sessionToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _reviewsService.deleteReview(reviewId, sessionToken);
      
      if (success) {
        _reviews.removeWhere((r) => r.id == reviewId);
        await _localStorage.deleteReview(reviewId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearReviews() {
    _reviews = [];
    notifyListeners();
  }
}
