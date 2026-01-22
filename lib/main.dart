import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/reviews_provider.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_panel.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/notifications_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Only if not web or if web config is provided later)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const QuevedoTourApp());
}

class QuevedoTourApp extends StatelessWidget {
  const QuevedoTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
      ],
      child: MaterialApp(
        title: 'QuevedoTour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminPanel(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}
