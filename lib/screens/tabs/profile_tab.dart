import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_guard.dart';
import '../admin/admin_panel.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAnonymous) {
            return _buildGuestMode(context);
          } else {
            return _buildAuthenticatedMode(context, authProvider);
          }
        },
      ),
    );
  }

  /// UI for guest (unauthenticated) users
  Widget _buildGuestMode(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        
        // Guest avatar
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person_outline, size: 50, color: Colors.white),
        ),
        
        const SizedBox(height: 16),
        
        // Guest title
        const Center(
          child: Text(
            "Modo Invitado",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Center(
          child: Text(
            "Inicia sesión para acceder a más funciones",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Login button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Iniciar Sesión'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Register button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Crear Cuenta'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        const Divider(),
        
        // Guest features info
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: const Text("Explorar establecimientos"),
          subtitle: const Text("Disponible sin cuenta"),
        ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: const Text("Ver detalles y ubicaciones"),
          subtitle: const Text("Disponible sin cuenta"),
        ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: const Text("Favoritos locales"),
          subtitle: const Text("Guardados solo en este dispositivo"),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline, color: Colors.orange),
          title: const Text("Escribir reseñas"),
          subtitle: const Text("Requiere iniciar sesión"),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline, color: Colors.orange),
          title: const Text("Sincronizar favoritos"),
          subtitle: const Text("Requiere iniciar sesión"),
        ),
        
        const Divider(),
        
        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Configuración"),
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
        
        // About
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Acerca de QuevedoTour"),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'QuevedoTour',
              applicationVersion: '1.0.0',
              children: [
                const Text('Guía turística completa de la ciudad de Quevedo.'),
              ],
            );
          },
        ),
      ],
    );
  }

  /// UI for authenticated users
  Widget _buildAuthenticatedMode(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        
        // User avatar
        CircleAvatar(
          radius: 50,
          backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
          child: user.image == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        
        const SizedBox(height: 16),
        
        // User name
        Center(
          child: Text(
            user.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // User email
        Center(
          child: Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // My Reviews
        Card(
          child: ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text("Mis Reseñas"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to user reviews
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Mis Reseñas')),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // My Favorites
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Mis Favoritos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to favorites tab
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.setTabIndex(2); // Favorites tab index
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Edit Profile
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Editar Perfil"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Editar Perfil')),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        
        // Admin Panel (if user is admin)
        if (user.isAdmin)
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
            title: const Text("Panel Administrativo"),
            subtitle: const Text("Gestionar contenido"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPanel()),
              );
            },
          ),
        
        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Configuración"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
        
        // About
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Acerca de QuevedoTour"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'QuevedoTour',
              applicationVersion: '1.0.0',
              children: [
                const Text('Guía turística completa de la ciudad de Quevedo.'),
              ],
            );
          },
        ),
        
        const Divider(),
        
        // Logout button
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Cerrar Sesión",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            );
            
            if (confirm == true && context.mounted) {
              await authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesión cerrada. Continuando en modo invitado.'),
                ),
              );
            }
          },
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}
