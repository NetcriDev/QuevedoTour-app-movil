import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Could not check connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // connectivity_plus 6.0+ returns a list
    final bool currentlyOnline = !results.contains(ConnectivityResult.none);
    
    if (_isOnline != currentlyOnline) {
      _isOnline = currentlyOnline;
      notifyListeners();
      
      if (_isOnline) {
        debugPrint('--- DEVICE IS ONLINE ---');
      } else {
        debugPrint('--- DEVICE IS OFFLINE ---');
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
