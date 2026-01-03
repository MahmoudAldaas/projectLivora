import 'package:flutter/material.dart';
import 'package:livora/core/api/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getNotifications(token: ApiService.getAuthToken());

      if (!response['error']) {
        if (mounted) {
          setState(() {
            notifications = response['data'] ?? [];
          });
        }
      } else {
        if (mounted) _showError(response['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      if (mounted) _showError('Connection error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await ApiService.markAllNotificationsRead(token: ApiService.getAuthToken());

      if (!response['error']) {
        _loadNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'All marked as read')),
          );
        }
      } else {
        if (mounted) _showError(response['message'] ?? 'Failed to mark as read');
      }
    } catch (e) {
      if (mounted) _showError('Failed to update notifications');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined, color: Colors.brown),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: Colors.brown,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = Map<String, dynamic>.from(notifications[index]);
                      return _buildNotificationCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final data = item['data'] ?? {};
    final bool isRead = item['read_at'] != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isRead
          ? Theme.of(context).cardColor
          : Colors.orange.shade50.withOpacity(0.3),
      elevation: isRead ? 0 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey[200] : Colors.brown.withOpacity(0.1),
          child: Icon(
            Icons.notifications,
            color: isRead ? Colors.grey : Colors.brown,
          ),
        ),
        title: Text(
          data['message'] ?? 'Alert',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: item['created_at'] != null
            ? Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  item['created_at'].toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            : null,
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text(
            'No notifications',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
