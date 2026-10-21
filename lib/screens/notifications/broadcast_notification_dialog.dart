import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class BroadcastNotificationDialog extends StatefulWidget {
  const BroadcastNotificationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const BroadcastNotificationDialog(),
    );
  }

  @override
  State<BroadcastNotificationDialog> createState() =>
      _BroadcastNotificationDialogState();
}

class _BroadcastNotificationDialogState
    extends State<BroadcastNotificationDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _targetAudience = 'everyone'; // 'everyone', 'faculty', 'it'
  String _priority = 'urgent'; // 'normal', 'urgent', 'critical'
  bool _isSubmitting = false;

  void _applyPreset(String title, String message, String priority) {
    setState(() {
      _titleController.text = title;
      _messageController.text = message;
      _priority = priority;
    });
  }

  Future<void> _handleSend() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a broadcast title"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message description"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appData = Provider.of<AppDataProvider>(context, listen: false);
      final currentUserName =
          appData.userName.isNotEmpty ? appData.userName : 'IT Support';

      final recipientCount =
          await NotificationService().sendBroadcastNotification(
        title: title,
        message: message,
        targetAudience: _targetAudience,
        senderName: currentUserName,
        priority: _priority,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "📢 Broadcast successfully sent to $recipientCount ${_getAudienceLabel(_targetAudience)}!",
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to dispatch broadcast: $e"),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getAudienceLabel(String code) {
    switch (code) {
      case 'faculty':
        return 'faculty members';
      case 'it':
        return 'IT technicians';
      default:
        return 'active users';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: AppTheme.accentGlow,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Broadcast System Alert",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Sends immediate push & in-app alerts to users",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Target Audience Selector
              const Text(
                "Select Recipient Audience",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _audienceChip('everyone', '👥 Everyone (All Users)'),
                  _audienceChip('faculty', '👨‍🏫 Faculty Only'),
                  _audienceChip('it', '🔧 IT Technicians Only'),
                ],
              ),

              const SizedBox(height: 18),

              // Quick Incident Presets
              const Text(
                "Quick Incident Presets",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _presetChip(
                    "🌐 Internet Down",
                    "Internet Connection Offline",
                    "Campus network and internet access are currently disrupted. The IT team is actively investigating the gateway.",
                    "critical",
                  ),
                  _presetChip(
                    "⚡ Power Outage",
                    "Backup Power / Generator Active",
                    "Campus has switched to emergency power. Please save your work and power off high-consumption hardware.",
                    "urgent",
                  ),
                  _presetChip(
                    "🛠️ Maintenance",
                    "Scheduled Lab Maintenance",
                    "Routine system maintenance and software updates are in progress across designated computer labs.",
                    "normal",
                  ),
                  _presetChip(
                    "📢 General Notice",
                    "Notice from IT Support",
                    "Please be advised regarding today's IT schedule and lab availability.",
                    "normal",
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Title Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Alert Title",
                  hintText: "e.g. Internet Connection Offline",
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 14),

              // Message Field
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Alert Message",
                  hintText: "Describe the situation, expected downtime, or instructions...",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.message_rounded, size: 20),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              // Urgency Level Selector
              Row(
                children: [
                  const Text(
                    "Urgency Level:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _priorityRadio('normal', 'Normal', AppTheme.infoColor),
                  const SizedBox(width: 8),
                  _priorityRadio('urgent', 'Urgent', AppTheme.warningColor),
                  const SizedBox(width: 8),
                  _priorityRadio('critical', 'Critical', AppTheme.errorColor),
                ],
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _priority == 'critical'
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isSubmitting ? "Dispatching..." : "Send Broadcast Now"),
                    onPressed: _isSubmitting ? null : _handleSend,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _audienceChip(String value, String label) {
    final selected = _targetAudience == value;
    return ChoiceChip(
      showCheckmark: false,
      selected: selected,
      label: Text(label),
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      onSelected: _isSubmitting ? null : (_) => setState(() => _targetAudience = value),
    );
  }

  Widget _presetChip(String chipLabel, String title, String msg, String priority) {
    return ActionChip(
      label: Text(chipLabel, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceColor,
      side: const BorderSide(color: AppTheme.borderColor),
      onPressed: _isSubmitting ? null : () => _applyPreset(title, msg, priority),
    );
  }

  Widget _priorityRadio(String value, String label, Color color) {
    final selected = _priority == value;
    return InkWell(
      onTap: _isSubmitting ? null : () => setState(() => _priority = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : AppTheme.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
