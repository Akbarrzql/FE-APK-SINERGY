import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/notification/bloc/notification_bloc.dart';
import 'package:gabungyuk/feature/notification/bloc/notification_event.dart';
import 'package:gabungyuk/feature/notification/bloc/notification_state.dart';
import 'package:gabungyuk/feature/notification/model/notification_model.dart';
import 'package:gabungyuk/feature/notification/presentation/notification_detail_screen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  /// Group notifications by date label: "Hari Ini", "Kemarin", or formatted date
  Map<String, List<NotificationData>> _groupByDate(List<NotificationData> notifications) {
    final Map<String, List<NotificationData>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final n in notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String label;
      if (d == today) {
        label = 'Hari Ini';
      } else if (d == yesterday) {
        label = 'Kemarin';
      } else {
        label = DateFormat('dd MMMM yyyy').format(n.createdAt);
      }
      grouped.putIfAbsent(label, () => []).add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading && state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (state.status == NotificationStatus.error && state.notifications.isEmpty) {
            return _buildErrorState(state.errorMessage);
          }

          final notifications = state.notifications;

          if (notifications.isEmpty && state.status == NotificationStatus.loaded) {
            return _buildEmptyState();
          }

          final grouped = _groupByDate(notifications);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(FetchNotifications());
            },
            color: ColorValue.primaryColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final entry in grouped.entries) ...[
                  _buildDateHeader(entry.key),
                  ...entry.value.map((n) => _buildNotificationItem(n)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Notifikasi',
        style: TextStyle(
          color: Color(0xFF1A1D2E),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D2E), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
          },
          style: TextButton.styleFrom(
            foregroundColor: ColorValue.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text(
            'Tandai Semua',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9DA3B4),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationData notification) {
    final bool isUnread = !notification.isRead;
    final iconData = _getIcon(notification.type);
    final iconColor = _getIconColor(notification.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.notificationId));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(notification: notification),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread
                    ? ColorValue.primaryColor.withOpacity(0.15)
                    : const Color(0xFFEEEFF4),
                width: 1,
              ),
              boxShadow: isUnread
                  ? [
                BoxShadow(
                  color: ColorValue.primaryColor.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                color: isUnread
                                    ? const Color(0xFF1A1D2E)
                                    : const Color(0xFF6B7280),
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: ColorValue.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread
                              ? const Color(0xFF4B5563)
                              : const Color(0xFF9DA3B4),
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Time
                      Text(
                        _formatDateTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isUnread
                              ? ColorValue.primaryColor.withOpacity(0.7)
                              : const Color(0xFFB0B7C3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEFF4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: const Color(0xFFB0B7C3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aktivitas terbaru akan muncul di sini',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9DA3B4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Periksa koneksi internet kamu',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9DA3B4)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<NotificationBloc>().add(FetchNotifications()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValue.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'COLLABORATION_REQUEST':
        return Icons.person_add_rounded;
      case 'COLLABORATION_ACCEPT':
        return Icons.check_circle_rounded;
      case 'PROJECT_UPDATE':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'COLLABORATION_REQUEST':
        return const Color(0xFFF97316); // orange
      case 'COLLABORATION_ACCEPT':
        return const Color(0xFF22C55E); // green
      case 'PROJECT_UPDATE':
        return ColorValue.primaryColor;
      default:
        return const Color(0xFF8B5CF6); // purple
    }
  }
}