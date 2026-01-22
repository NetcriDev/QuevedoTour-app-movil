import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/shared_preferences_service.dart';

/// Provider for managing authentication state
/// Handles user session, login, register, and logout operations
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  User _currentUser = User.anonymous();
  bool _isLoading = false;
  String? _errorMessage;

  User get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser.isAuthenticated;
  bool get isAnonymous => _currentUser.isAnonymous;
  bool get isAdmin => _currentUser.isAdmin;

  /// Initialize authentication state
  /// Checks for saved session on app startup
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to restore user session from SharedPreferences
      final savedUser = await _prefsService.getUser();
      
      if (savedUser.isAuthenticated) {
        // Validate token is still valid
        final isValid = await _authService.validateToken(savedUser.sessionToken);
        
        if (isValid) {
          _currentUser = savedUser;
          debugPrint('User session restored: ${savedUser.email}');
        } else {
          // Token expired, clear session
          await _prefsService.removeUser();
          _currentUser = User.anonymous();
          debugPrint('Session token expired, logged out');
        }
      } else {
        _currentUser = User.anonymous();
        debugPrint('No saved session, starting in guest mode');
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _currentUser = User.anonymous();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.user != null) {
        _currentUser = response.user!;
        await _prefsService.saveUser(_currentUser);
        _errorMessage = null;
        debugPrint('Login successful: ${_currentUser.email}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('Login failed: ${response.message}');
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión';
      debugPrint('Login error: $e');
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    String? cedula,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        lastname: lastname,
        email: email,
        phone: phone,
        password: password,
        cedula: cedula,
      );

      if (response.success) {
        if (response.user != null) {
          // Auto-login after registration
          _currentUser = response.user!;
          await _prefsService.saveUser(_currentUser);
          debugPrint('Registration and auto-login successful: ${_currentUser.email}');
        } else {
          debugPrint('Registration successful, requires manual login');
        }
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('Registration failed: ${response.message}');
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado al registrarse';
      debugPrint('Registration error: $e');
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _prefsService.removeUser();
    _currentUser = User.anonymous();
    _errorMessage = null;
    debugPrint('User logged out, switched to guest mode');
    notifyListeners();
  }

  /// Update notification token for push notifications
  Future<void> updateNotificationToken(String token) async {
    if (_currentUser.isAuthenticated) {
      final success = await _authService.updateNotificationToken(
        _currentUser.id,
        token,
      );
      
      if (success) {
        _currentUser = _currentUser.copyWith(notificationToken: token);
        await _prefsService.saveUser(_currentUser);
        debugPrint('Notification token updated');
      }
    }
  }

  /// Refresh user data from server
  Future<void> refreshUser() async {
    if (_currentUser.isAuthenticated) {
      final user = await _authService.getUserById(
        _currentUser.id,
        _currentUser.sessionToken,
      );
      
      if (user != null) {
        _currentUser = user;
        await _prefsService.saveUser(_currentUser);
        notifyListeners();
        debugPrint('User data refreshed');
      }
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
