import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/connectivity_provider.dart';
import 'tabs/home_tab.dart';
import 'tabs/categories_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final List<Widget> _tabs = [
    const HomeTab(),
    const CategoriesTab(),
    const FavoritesTab(),
    const MapTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          if (!connectivity.isOnline)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              width: double.infinity,
              color: Colors.orange.withOpacity(0.9),
              child: const SafeArea(
                bottom: false,
                child: Text(
                  'Modo Offline - Usando datos locales',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 12, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: provider.currentTabIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.currentTabIndex,
        onDestinationSelected: (index) {
          provider.setTabIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
