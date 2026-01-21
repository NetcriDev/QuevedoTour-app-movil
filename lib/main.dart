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
      child: MaterialApp(
        title: 'QuevedoTour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/admin': (context) => const AdminPanel(),
        },
      ),
    );
  }
}
