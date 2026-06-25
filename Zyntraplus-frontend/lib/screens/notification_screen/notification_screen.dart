import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _page = 1;
  final int _limit = 6;

  final ScrollController _scrollController = ScrollController();

  // Replace with your API data source
  final List<Map<String, dynamic>> _allNotifications = [
    {
      "notification_uid": "1",
      "type": "like",
      "message": "liked your post",
      "is_read": false,
      "created_at": "2m ago",
      "section": "New",
      "actor": {"name": "Aman"}
    },
    {
      "notification_uid": "2",
      "type": "comment",
      "message": "commented: Nice pic!",
      "is_read": false,
      "created_at": "5m ago",
      "section": "New",
      "actor": {"name": "Riya"}
    },
    {
      "notification_uid": "3",
      "type": "follow",
      "message": "started following you",
      "is_read": true,
      "created_at": "10m ago",
      "section": "New",
      "actor": {"name": "Rahul"}
    },
    {
      "notification_uid": "4",
      "type": "message",
      "message": "sent you a message",
      "is_read": true,
      "created_at": "1h ago",
      "section": "Earlier",
      "actor": {"name": "Priya"}
    },
    {
      "notification_uid": "5",
      "type": "nearby",
      "message": "is near you",
      "is_read": true,
      "created_at": "3h ago",
      "section": "Earlier",
      "actor": {"name": "Dev"}
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _hasMore) {
        fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _notifications =
      List<Map<String, dynamic>>.from(_allNotifications.take(_limit));
      _hasMore = _allNotifications.length > _limit;
      _loading = false;
      _page = 1;
    });
  }

  Future<void> fetchMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final start = _page * _limit;
    final end = (start + _limit).clamp(0, _allNotifications.length);
    final more =
    List<Map<String, dynamic>>.from(_allNotifications.sublist(start, end));
    setState(() {
      _page++;
      _notifications.addAll(more);
      _hasMore = _notifications.length < _allNotifications.length;
      _loadingMore = false;
    });
  }

  Future<void> markAllRead() async {
    setState(() {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    });
  }

  void markOneRead(String uid) {
    setState(() {
      final n =
      _notifications.firstWhere((n) => n['notification_uid'] == uid);
      n['is_read'] = true;
    });
  }

  void dismissNotification(String uid) {
    setState(() {
      _notifications.removeWhere((n) => n['notification_uid'] == uid);
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "like":
        return Iconsax.heart5;
      case "comment":
        return Iconsax.message_text;
      case "follow":
        return Iconsax.user_add;
      case "message":
        return Iconsax.sms;
      case "nearby":
        return Iconsax.location;
      default:
        return Iconsax.notification;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case "like":
        return const Color(0xFFD4537E);
      case "comment":
        return const Color(0xFF185FA5);
      case "follow":
        return const Color(0xFF3B6D11);
      case "message":
        return const Color(0xFFBA7517);
      case "nearby":
        return const Color(0xFF0F6E56);
      default:
        return Colors.grey;
    }
  }

  Color _getBgColor(String type) {
    switch (type) {
      case "like":
        return const Color(0xFFFBEAF0);
      case "comment":
        return const Color(0xFFE6F1FB);
      case "follow":
        return const Color(0xFFEAF3DE);
      case "message":
        return const Color(0xFFFAEEDA);
      case "nearby":
        return const Color(0xFFE1F5EE);
      default:
        return Colors.grey.shade100;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupBySections() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final n in _notifications) {
      final section = n['section'] as String? ?? 'Earlier';
      grouped.putIfAbsent(section, () => []).add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['is_read'] ?? false)).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadBg = isDark
        ? AppColors.primaryBackground(context).withOpacity(0.06)
        : Colors.blue.withOpacity(0.04);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE24B4A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllRead,
              child: Text(
                "Mark all read",
                style: TextStyle(
                  color: AppColors.buttonColor(context),
                  fontSize: 13,
                ),
              ),
            )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: fetchNotifications,
        child: _buildList(context, unreadBg),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondaryText(context).withOpacity(0.15),
              ),
            ),
            child: Icon(
              Iconsax.notification,
              color: AppColors.secondaryText(context),
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "You're all caught up",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No new notifications right now",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, Color unreadBg) {
    final sections = _groupBySections();
    final sectionKeys = sections.keys.toList();

    // Build a flat list of section headers + items for the ListView
    final List<Widget> rows = [];
    for (final key in sectionKeys) {
      rows.add(_buildSectionHeader(context, key));
      final items = sections[key]!;
      for (int i = 0; i < items.length; i++) {
        rows.add(_buildNotificationTile(context, items[i], unreadBg));
        if (i < items.length - 1) {
          rows.add(Divider(
            height: 1,
            thickness: 0.5,
            indent: 70,
            color: AppColors.secondaryText(context).withOpacity(0.15),
          ));
        }
      }
      rows.add(const SizedBox(height: 8));
    }

    if (_loadingMore) {
      rows.add(const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ));
    }

    return ListView(
      controller: _scrollController,
      children: rows,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText(context).withOpacity(0.6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context,
      Map<String, dynamic> notif,
      Color unreadBg,
      ) {
    final isRead = notif['is_read'] ?? false;
    final actor = notif['actor'] as Map;
    final type = notif['type'] as String;
    final uid = notif['notification_uid'] as String;

    return Dismissible(
      key: Key(uid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => dismissNotification(uid),
      child: InkWell(
        onTap: () => markOneRead(uid),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isRead
              ? Colors.transparent
              : unreadBg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getBgColor(type),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getIcon(type),
                    color: _getColor(type),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryText(context),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: "${actor['name']} ",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: notif['message']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif['created_at'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText(context).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF378ADD),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}