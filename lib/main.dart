import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/admin/admin_panel.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => AppProvider()..initData()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'QuevedoTour',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme, // Optionally use provider.isDarkMode
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // For now system default
            home: const HomeScreen(), // Placeholder until created
            routes: {
              '/admin': (context) => const AdminPanel(),
              // Detail screen usually passed via arguments or constructor, but can have named route
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/detail') {
                 // handle passing arguments
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
