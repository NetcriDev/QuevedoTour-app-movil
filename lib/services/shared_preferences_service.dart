import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Service for managing app data persistence using SharedPreferences
/// Handles user session, app preferences, and simple key-value storage
class SharedPreferencesService {
  static const String _keyUser = 'user';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  /// Saves a value to SharedPreferences
  Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  /// Reads a value from SharedPreferences
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.getString(key) == null) return null;
    
    return json.decode(prefs.getString(key)!);
  }

  /// Checks if a key exists in SharedPreferences
  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  /// Removes a value from SharedPreferences
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  /// Clears all data from SharedPreferences
  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  // --- USER SESSION METHODS ---

  /// Saves user session
  Future<void> saveUser(User user) async {
    await save(_keyUser, user.toJson());
  }

  /// Reads user session
  /// Returns User.anonymous() if no session exists
  Future<User> getUser() async {
    try {
      final userData = await read(_keyUser);
      if (userData == null) return User.anonymous();
      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Error reading user from SharedPreferences: $e');
      return User.anonymous();
    }
  }

  /// Checks if user session exists
  Future<bool> hasUserSession() async {
    return await contains(_keyUser);
  }

  /// Removes user session (logout)
  Future<void> removeUser() async {
    await remove(_keyUser);
  }

  /// Logout user and optionally navigate to login screen
  Future<void> logout(BuildContext context, {bool navigateToLogin = false}) async {
    await removeUser();
    
    if (navigateToLogin && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  // --- APP PREFERENCES METHODS ---

  /// Saves theme mode preference
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.toString());
  }

  /// Gets theme mode preference
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_keyThemeMode);
    
    if (modeString == null) return ThemeMode.system;
    
    switch (modeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Saves language preference
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }

  /// Gets language preference
  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  /// Marks onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  /// Checks if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Saves a simple string value
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Gets a simple string value
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Saves a simple boolean value
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Gets a simple boolean value
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Saves a simple integer value
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Gets a simple integer value
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Saves a simple double value
  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  /// Gets a simple double value
  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }
}
