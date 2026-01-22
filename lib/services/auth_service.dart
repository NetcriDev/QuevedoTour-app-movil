import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

/// Service for handling authentication operations
/// Communicates with backend API for login, register, and token management
class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
      ));
    }
  }

  /// Login with email and password
  /// Returns User object with session token on success, null on failure
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final user = User.fromJson(data['data']);
          return AuthResponse(
            success: true,
            user: user,
            message: data['message'] ?? 'Login exitoso',
          );
        } else {
          return AuthResponse(
            success: false,
            message: data['message'] ?? 'Credenciales inválidas',
          );
        }
      }

      return AuthResponse(
        success: false,
        message: 'Error en el servidor',
      );
    } on DioException catch (e) {
      debugPrint('Login error: $e');
      return AuthResponse(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      return AuthResponse(
        success: false,
        message: 'Error inesperado al iniciar sesión',
      );
    }
  }

  /// Register a new user
  /// Returns User object with session token on success, null on failure
  Future<AuthResponse> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    String? cedula,
  }) async {
    try {
      final response = await _dio.post('/users/create', data: {
        'name': name,
        'lastname': lastname,
        'email': email,
        'phone': phone,
        'password': password,
        if (cedula != null) 'cedula': cedula,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['success'] == true) {
          // Some backends return user data immediately, others require login
          if (data['data'] != null && data['data']['session_token'] != null) {
            final user = User.fromJson(data['data']);
            return AuthResponse(
              success: true,
              user: user,
              message: data['message'] ?? 'Registro exitoso',
            );
          } else {
            // Registration successful but need to login
            return AuthResponse(
              success: true,
              message: data['message'] ?? 'Registro exitoso. Por favor inicia sesión.',
              requiresLogin: true,
            );
          }
        } else {
          return AuthResponse(
            success: false,
            message: data['message'] ?? 'Error en el registro',
          );
        }
      }

      return AuthResponse(
        success: false,
        message: 'Error en el servidor',
      );
    } on DioException catch (e) {
      debugPrint('Register error: $e');
      return AuthResponse(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      debugPrint('Unexpected register error: $e');
      return AuthResponse(
        success: false,
        message: 'Error inesperado al registrarse',
      );
    }
  }

  /// Validates if a session token is still valid
  /// Returns true if valid, false otherwise
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/users/validate',
        options: Options(
          headers: {'Authorization': token},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  /// Updates user's notification token (FCM token)
  Future<bool> updateNotificationToken(String userId, String notificationToken) async {
    try {
      final response = await _dio.put('/users/updateNotificationToken', data: {
        'id': userId,
        'notification_token': notificationToken,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error updating notification token: $e');
      return false;
    }
  }

  /// Gets user by ID (requires authentication)
  Future<User?> getUserById(String userId, String sessionToken) async {
    try {
      final response = await _dio.get(
        '/users/findById/$userId',
        options: Options(
          headers: {'Authorization': sessionToken},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Handles Dio errors and returns user-friendly messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Credenciales inválidas';
        } else if (error.response?.statusCode == 404) {
          return 'Servicio no encontrado';
        } else if (error.response?.data != null && error.response?.data['message'] != null) {
          return error.response!.data['message'];
        }
        return 'Error del servidor (${error.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Solicitud cancelada';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu internet.';
      default:
        return 'Error de red. Intenta nuevamente.';
    }
  }
}

/// Response object for authentication operations
class AuthResponse {
  final bool success;
  final User? user;
  final String message;
  final bool requiresLogin; // For registration that doesn't auto-login

  AuthResponse({
    required this.success,
    this.user,
    required this.message,
    this.requiresLogin = false,
  });
}
