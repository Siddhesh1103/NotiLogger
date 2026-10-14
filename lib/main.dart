
import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_service.dart';

void main() {
  runApp(const NotiLoggerApp());
}

class NotiLoggerApp extends StatelessWidget {
  const NotiLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotiLogger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        useMaterial3: true,
      ),
      home: const NotificationHomePage(),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage({super.key});

  @override
  State<NotificationHomePage> createState() =>
      _NotificationHomePageState();
}

class _NotificationHomePageState
    extends State<NotificationHomePage> {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedApp;
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _service.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {


    final availableApps = _notifications
        .map((notification) => notification.appName)
        .toSet()
        .toList()
      ..sort();

    final filteredNotifications = _notifications.where((notification) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          notification.appName.toLowerCase().contains(query) ||
          (notification.sender ?? '').toLowerCase().contains(query) ||
          (notification.message ?? '').toLowerCase().contains(query);

      final matchesApp = _selectedApp == null ||
          notification.appName == _selectedApp;

      return matchesSearch && matchesApp;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined),
            SizedBox(width: 10),
            Text(
              'NotiLogger',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
                
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Delete all notifications',
            icon: const Icon(Icons.delete_outline),
            onPressed: _notifications.isEmpty
                ? null
                : () async {
                    final dialogContext = context;
                    final confirmed = await showDialog<bool>(
                      context: dialogContext,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete all notifications?'),
                        content: const Text(
                          'This will permanently delete all saved '
                          'notifications from this device.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
                            child: const Text('Delete all'),
                          ),
                        ],
                      ),
                    );

                      if (confirmed != true) return;
                      if (!context.mounted) return;

                    try {
                      await _service.deleteAllNotifications();
                      await _loadNotifications();

                      if (!mounted) return;

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications deleted'),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Delete failed: $e'),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search messages or apps...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),

        
    Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DropdownButtonFormField<String?>(
        initialValue: _selectedApp,
        decoration: InputDecoration(
          labelText: 'Filter by app',
          prefixIcon: const Icon(Icons.filter_list),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All apps'),
          ),
          ...availableApps.map(
            (app) => DropdownMenuItem<String?>(
              value: app,
              child: Text(app),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedApp = value;
          });
        },
      ),
    ),


    Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        const Text('Could not load notifications'),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadNotifications,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : filteredNotifications.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No matching notifications'
                            : 'No notifications yet',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              filteredNotifications[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  notification.appName.isNotEmpty
                                      ? notification.appName[0]
                                          .toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(
                                notification.sender ??
                                    notification.appName,
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message?.isNotEmpty ==
                                            true
                                        ? notification.message!
                                        : '(No message text)',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${notification.appName} · '
                                    '${_formatTime(notification.timestamp)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    ),
  ],
),
);
  }
}