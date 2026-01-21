import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, provider, child) => AlertDialog(
          title: const Text("Acceso Admin"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                enabled: !provider.isLoading,
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                enabled: !provider.isLoading,
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: provider.isLoading ? null : () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      final pass = passController.text.trim();

                      if (email.isEmpty || pass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor ingrese credenciales')),
                        );
                        return;
                      }

                      final success = await provider.login(email, pass);

                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminPanel()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Credenciales incorrectas o error de conexión')),
                          );
                        }
                      }
                    },
              child: const Text("Ingresar"),
            ),
          ],
        ),
      ),
    );
  }
}
