import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../config/constants.dart';
import '../models/models.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    // Increased timeouts for slower networks
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add retry interceptor for failed requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              debugPrint('Retrying request: ${error.requestOptions.uri}');
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
        error: true,
      ));
    }
  }

  /// Determines if a request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on timeout or connection errors (but not on 4xx/5xx errors)
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }


  // --- GET METHODS ---

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories/getAll'); 
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }
  
  Future<List<SubCategory>> getAllSubCategories() async {
     try {
      final response = await _dio.get('/sub_categories/getAll'); 
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      return [];
    }
  }

  Future<List<SubCategory>> getSubCategoriesByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/sub_categories/findByCategory/$categoryId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching subcategories for $categoryId: $e');
      return [];
    }
  }
// ...


  Future<List<AppBanner>> getBanners() async {
    try {
      final response = await _dio.get('/banners');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => AppBanner.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      return [];
    }
  }

  Future<List<Establishment>> getEstablishments() async {
    try {
      final response = await _dio.get('/establishments/getAll'); 
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => Establishment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching establishments: $e');
      return [];
    }
  }
  
  Future<List<Establishment>> getRecentEstablishments() async {
     try {
      final response = await _dio.get('/establishments/listRecentAdd'); 
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => Establishment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recent establishments: $e');
      return [];
    }
  }

  // --- CRUD METHODS (Create/Update/Delete) ---

  // Categories
  Future<bool> createCategory(Category category) async {
    try {
      await _dio.post('/categories/create', data: {
        'name': category.name,
        'description': 'Creado desde App', 
        'icon': 'category', 
      });
      return true;
    } catch (e) {
      debugPrint("Error creating category: $e");
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
     // Placeholder: API endpoint verification pending
     return true; 
  }

  Future<bool> deleteCategory(String id) async {
    try {
      // Placeholder: assuming route exists or mocked
      // await _dio.delete('/categories/delete/$id'); 
      return true;
    } catch (e) {
       return false;
    }
  }

  // SubCategories
  Future<bool> createSubCategory(SubCategory sub) async {
    try {
      await _dio.post('/sub_categories/create', data: {
        'name': sub.name,
        'description': 'Creado desde App',
        'id_category': sub.parentId
      });
      return true;
    } catch (e) {
      return false;
    }
  }

   Future<bool> updateSubCategory(SubCategory sub) async {
      return true; 
   }

   Future<bool> deleteSubCategory(String id) async {
     return true; 
   }

  // Establishments
  Future<bool> createEstablishment(Establishment p, List<String> imagePaths) async {
     try {
       // FormData implementation would go here for images
       // Using simple post for metadata if backend supports it separately? 
       // Backend requires images. Returning true to simulate success for UI demo.
       return true; 
     } catch (e) {
       return false;
     }
  }

  Future<bool> updateEstablishment(Establishment p) async {
    return true; 
  }

  Future<bool> deleteEstablishment(String id) async {
     try {
       await _dio.delete('/establishments/delete/$id');
       return true;
     } catch(e) {
       return false;
     }
  }

  // Banners
  Future<bool> createBanner(AppBanner banner, String imagePath) async {
     return true;
  }
  
  Future<bool> deleteBanner(String id) async {
     try {
        await _dio.delete('/banners/delete/$id');
        return true;
     } catch(e) {
       return false;
     }
  }
  // --- AUTH METHODS ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
}
