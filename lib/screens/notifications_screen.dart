import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(context),
            tooltip: 'Limpiar todo',
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes notificaciones aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _NotificationItem(notification: notification);
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Estás seguro de que quieres borrar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationsProvider>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('LIMPIAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead 
            ? Colors.grey.withOpacity(0.1) 
            : AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(
          notification.isRead ? Icons.notifications_none : Icons.notifications_active,
          color: notification.isRead ? Colors.grey : AppTheme.primaryColor,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          color: notification.isRead ? Colors.grey[700] : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.body,
            style: TextStyle(color: notification.isRead ? Colors.grey : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM HH:mm').format(notification.timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsProvider>().markAsRead(notification.id);
        }
        // Handle deep linking payload here if needed
      },
      tileColor: notification.isRead ? null : AppTheme.primaryColor.withOpacity(0.02),
    );
  }
}
