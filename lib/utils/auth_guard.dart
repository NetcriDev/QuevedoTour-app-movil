import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

/// Utility class for requiring authentication before performing actions
/// Shows a dialog prompting user to login if not authenticated
class AuthGuard {
  /// Checks if user is authenticated, shows login dialog if not
  /// Returns true if authenticated or user chose to login, false if cancelled
  static Future<bool> requireAuth(
    BuildContext context,
    AuthProvider authProvider, {
    String? message,
  }) async {
    // User is already authenticated
    if (authProvider.isAuthenticated) {
      return true;
    }

    // Show login prompt dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Inicio de Sesión Requerido'),
        content: Text(
          message ?? 'Necesitas iniciar sesión para realizar esta acción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Shows a dialog prompting user to login with custom actions
  static Future<bool> showLoginPrompt(
    BuildContext context, {
    String? title,
    String? message,
    String? actionText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Inicio de Sesión'),
        content: Text(
          message ?? '¿Deseas iniciar sesión para acceder a más funciones?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.pushNamed(context, '/login');
            },
            child: Text(actionText ?? 'Iniciar Sesión'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Checks if user has admin role
  /// Shows unauthorized dialog if not admin
  static Future<bool> requireAdmin(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) {
      return await requireAuth(
        context,
        authProvider,
        message: 'Necesitas iniciar sesión como administrador.',
      );
    }

    if (!authProvider.isAdmin) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Acceso Denegado'),
          content: const Text(
            'No tienes permisos de administrador para acceder a esta sección.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }
}
