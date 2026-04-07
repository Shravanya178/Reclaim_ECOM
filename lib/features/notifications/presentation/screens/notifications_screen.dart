import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(id: '1', type: NotificationType.opportunity, title: 'New Opportunity Match!', message: 'Arduino boards you captured have been matched with a student project.', timestamp: DateTime.now().subtract(const Duration(minutes: 15)), isRead: false),
    NotificationItem(id: '2', type: NotificationType.match, title: 'Material Request Accepted', message: 'Rahul Sharma accepted your copper wire offer for the Home Automation project.', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isRead: false),
    NotificationItem(id: '3', type: NotificationType.approval, title: 'Barter Request Approved', message: 'Your skill exchange request for Lab B Electronics has been approved.', timestamp: DateTime.now().subtract(const Duration(hours: 5)), isRead: true),
    NotificationItem(id: '4', type: NotificationType.reminder, title: 'Pickup Reminder', message: 'Don\'t forget to pick up the acrylic sheets from Workshop today!', timestamp: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    NotificationItem(id: '5', type: NotificationType.impact, title: 'Impact Milestone! 🎉', message: 'Congratulations! You\'ve saved 10kg of CO₂ this month.', timestamp: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
    NotificationItem(id: '6', type: NotificationType.opportunity, title: 'New Materials Nearby', message: '3 new electronic components available in Lab A Chemistry.', timestamp: DateTime.now().subtract(const Duration(days: 3)), isRead: true),
  ];

  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  @override
  void initState() {
    super.initState();
    _injectContextAwareNotifications();
  }

  Future<void> _injectContextAwareNotifications() async {
    final playbook = await ErpCrmIntelligenceService.instance
      .getFlowPlaybook(role: 'customer');
    final campaigns = await ErpCrmIntelligenceService.instance
      .getReactivationCampaigns(refresh: true);
    final messages = await ErpCrmIntelligenceService.instance
        .getContextAwareMessages(lowStock: true);
    if (!mounted || messages.isEmpty) return;

    final now = DateTime.now();
    final dynamicItems = messages.asMap().entries.map((entry) {
      final message = entry.value;
      final isProject = message.toLowerCase().contains('project');
      return NotificationItem(
        id: 'ctx-${now.millisecondsSinceEpoch}-${entry.key}',
        type: isProject ? NotificationType.match : NotificationType.reminder,
        title: isProject ? 'Project Progress Reminder' : 'Inventory Alert',
        message: message,
        timestamp: now,
        isRead: false,
      );
    }).toList();

    setState(() {
      _notifications.insertAll(0, dynamicItems);
      _notifications.insertAll(
        0,
        campaigns.map((c) => NotificationItem(
          id: 'react-${c.id}',
          type: NotificationType.reminder,
          title: c.title,
          message: c.message,
          timestamp: now,
          isRead: false,
          deepLink: c.route,
          campaignId: c.id,
        )),
      );
      _notifications.insertAll(0, [
        NotificationItem(
          id: 'crm-stage-${now.millisecondsSinceEpoch}',
          type: NotificationType.reminder,
          title: 'CRM Stage: ${playbook.crmStage.toUpperCase()}',
          message: playbook.crmNextAction,
          timestamp: now,
          isRead: false,
        ),
        NotificationItem(
          id: 'scm-mode-${now.millisecondsSinceEpoch}',
          type: NotificationType.opportunity,
          title: 'SCM Mode: ${playbook.scmMode}',
          message: playbook.scmNextAction,
          timestamp: now,
          isRead: false,
        ),
        NotificationItem(
          id: 'erp-priority-${now.millisecondsSinceEpoch}',
          type: NotificationType.match,
          title: 'ERP Priority',
          message: playbook.erpPriorityModule,
          timestamp: now,
          isRead: false,
        ),
        NotificationItem(
          id: 'revenue-signal-${now.millisecondsSinceEpoch}',
          type: NotificationType.impact,
          title: 'Revenue Signal',
          message: playbook.revenueInsight,
          timestamp: now,
          isRead: false,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: 'Open flow timeline',
            onPressed: () => context.go('/flow-timeline'),
            icon: const Icon(Icons.timeline_outlined, color: Colors.white),
          ),
          if (unreadCount > 0)
            TextButton(onPressed: _markAllAsRead, child: const Text('Mark all read', style: TextStyle(color: Colors.white))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear') _clearAll();
              if (value == 'settings') {}
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Notification Settings')),
              const PopupMenuItem(value: 'clear', child: Text('Clear All')),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Container(
            margin: _isDesktop ? EdgeInsets.all(24) : EdgeInsets.zero,
            decoration: _isDesktop ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ) : null,
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text('No notifications', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        SizedBox(height: 8),
                        Text('You\'re all caught up!', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final showDateHeader = index == 0 || !_isSameDay(notification.timestamp, _notifications[index - 1].timestamp);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(_formatDateHeader(notification.timestamp), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                          ),
                          _buildNotificationItem(notification),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => setState(() => _notifications.remove(notification)),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Material(
        color: notification.isRead ? Colors.transparent : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _getTypeColor(notification.type).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(_getTypeIcon(notification.type), color: _getTypeColor(notification.type), size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(notification.title, style: TextStyle(fontSize: 14, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold, color: Colors.grey.shade800))),
                          if (!notification.isRead) Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(notification.message, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6),
                      Text(_formatTimestamp(notification.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.opportunity: return Colors.blue;
      case NotificationType.match: return Colors.green;
      case NotificationType.approval: return Colors.purple;
      case NotificationType.reminder: return Colors.orange;
      case NotificationType.impact: return Colors.amber;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.opportunity: return Icons.auto_awesome;
      case NotificationType.match: return Icons.handshake;
      case NotificationType.approval: return Icons.check_circle;
      case NotificationType.reminder: return Icons.alarm;
      case NotificationType.impact: return Icons.emoji_events;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}';
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _handleNotificationTap(NotificationItem notification) async {
    setState(() {
      final index = _notifications.indexOf(notification);
      _notifications[index] = notification.copyWith(isRead: true);
    });

    if (notification.campaignId != null && notification.deepLink != null) {
      await ErpCrmIntelligenceService.instance.recordCampaignOpened(notification.campaignId!);
      await ErpCrmIntelligenceService.instance.recordCampaignConverted(
        notification.campaignId!,
        'notification_click_through',
      );
      if (!mounted) return;
      context.go(notification.deepLink!);
      return;
    }

    final title = notification.title.toLowerCase();
    if (title.contains('crm stage')) {
      context.go('/requests');
      return;
    }
    if (title.contains('scm mode')) {
      context.go('/scm-dashboard');
      return;
    }
    if (title.contains('erp priority')) {
      context.go('/ecom-admin');
      return;
    }
    if (title.contains('revenue signal')) {
      context.go('/orders');
      return;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _clearAll() {
    setState(() => _notifications.clear());
  }
}

enum NotificationType { opportunity, match, approval, reminder, impact }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? deepLink;
  final String? campaignId;

  NotificationItem({required this.id, required this.type, required this.title, required this.message, required this.timestamp, required this.isRead, this.deepLink, this.campaignId});

  NotificationItem copyWith({String? id, NotificationType? type, String? title, String? message, DateTime? timestamp, bool? isRead, String? deepLink, String? campaignId}) {
    return NotificationItem(id: id ?? this.id, type: type ?? this.type, title: title ?? this.title, message: message ?? this.message, timestamp: timestamp ?? this.timestamp, isRead: isRead ?? this.isRead, deepLink: deepLink ?? this.deepLink, campaignId: campaignId ?? this.campaignId);
  }
}