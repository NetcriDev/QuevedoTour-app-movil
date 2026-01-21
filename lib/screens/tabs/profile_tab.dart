import 'package:flutter/material.dart';
import '../admin/admin_panel.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text("Usuario Invitado", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
          const Divider(),
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
          const Divider(),
          // Admin Access Entry
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
            title: const Text("Panel Administrativo"),
            subtitle: const Text("Solo personal autorizado"),
            onTap: () {
              // Simulate Auth check
              _showLoginDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Acceso Admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock Auth
              if (emailController.text == 'admin' && passController.text == 'admin') {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanel()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales incorrectas (admin/admin)')));
              }
            },
            child: const Text("Ingresar"),
          ),
        ],
      ),
    );
  }
}
