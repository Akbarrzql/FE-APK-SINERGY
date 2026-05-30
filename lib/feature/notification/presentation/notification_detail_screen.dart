import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/notification/model/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationData notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final CollaborationService _collaborationService = CollaborationService();
  bool _isLoadingProject = false;
  String? _projectTitle;
  String? _projectDescription;

  @override
  void initState() {
    super.initState();
    if (widget.notification.projectId != null) {
      _fetchProjectDetail();
    }
  }

  Future<void> _fetchProjectDetail() async {
    setState(() => _isLoadingProject = true);
    try {
      final detail = await _collaborationService.getProjectDetail(widget.notification.projectId!);
      setState(() {
        _projectTitle = detail.data.project.title;
        _projectDescription = detail.data.project.description;
        _isLoadingProject = false;
      });
    } catch (e) {
      setState(() => _isLoadingProject = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy • HH:mm').format(widget.notification.createdAt);
    final typeLabel = _getTypeLabel(widget.notification.type);
    final typeColor = _getTypeColor(widget.notification.type);
    final typeIcon = _getTypeIcon(widget.notification.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(
            color: Color(0xFF1A1D2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main notification card ──────────────────────────────────
            _buildMainCard(typeLabel, typeColor, typeIcon, formattedDate),

            // ── Related info card ───────────────────────────────────────
            if (widget.notification.projectId != null || widget.notification.collaborationId != null) ...[
              const SizedBox(height: 20),
              _buildSectionLabel('Informasi Terkait'),
              const SizedBox(height: 10),
              _buildRelatedCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildMainCard(String typeLabel, Color typeColor, IconData typeIcon, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge + date row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 13, color: typeColor),
                    const SizedBox(width: 5),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB0B7C3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF0F1F5), height: 1),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.notification.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Message body
          Text(
            widget.notification.message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: _isLoadingProject
          ? const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.notification.projectId != null) ...[
            _buildRelatedRow(
              icon: Icons.folder_rounded,
              iconColor: ColorValue.primaryColor,
              label: 'Proyek',
              value: '#${widget.notification.projectId}',
            ),
            if (_projectTitle != null) ...[
              const SizedBox(height: 10),
              Text(
                _projectTitle!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E),
                ),
              ),
            ],
            if (_projectDescription != null) ...[
              const SizedBox(height: 4),
              Text(
                _projectDescription!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9DA3B4),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],

          if (widget.notification.collaborationId != null) ...[
            if (widget.notification.projectId != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFF0F1F5), height: 1),
              ),
            _buildRelatedRow(
              icon: Icons.people_rounded,
              iconColor: const Color(0xFF22C55E),
              label: 'Kolaborasi',
              value: '#${widget.notification.collaborationId}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9DA3B4),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1D2E),
        letterSpacing: 0.1,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEFF4), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'COLLABORATION_REQUEST':
        return 'Permintaan Kolaborasi';
      case 'COLLABORATION_ACCEPT':
        return 'Kolaborasi Diterima';
      case 'PROJECT_UPDATE':
        return 'Pembaruan Proyek';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'COLLABORATION_REQUEST':
        return const Color(0xFFF97316);
      case 'COLLABORATION_ACCEPT':
        return const Color(0xFF22C55E);
      case 'PROJECT_UPDATE':
        return ColorValue.primaryColor;
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getTypeIcon(String type) {
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
}