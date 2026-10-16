import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../services/complains_servcie.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

/// Offline-Cached & Chip-Filtered IT Hub Group Chat.
/// Reads directly from AppDataProvider's local cache + single delta listener
/// so opening or chatting NEVER re-fetches the whole Firestore collection!
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageC = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ComplaintService complaintService = ComplaintService();

  String _selectedStatusFilter = "All";

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(AppDataProvider appData) async {
    final text = messageC.text.trim();
    if (text.isEmpty) return;
    messageC.clear();

    await complaintService.createComplaint(message: text);
    _scrollToBottom();
  }

  Future<void> _updateStatus(
    AppDataProvider appData,
    String complaintId,
    String newStatus,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await complaintService.updateStatus(
      complaintId: complaintId,
      newStatus: newStatus,
      updaterId: uid,
      updaterName: appData.userName,
      resolverId: newStatus.toLowerCase() == 'resolved' ? uid : null,
      resolverName:
          newStatus.toLowerCase() == 'resolved' ? appData.userName : null,
    );
  }

  String _formatTime(dynamic tsMs) {
    if (tsMs == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(
      tsMs is int ? tsMs : DateTime.now().millisecondsSinceEpoch,
    );
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final canUpdateStatus =
        appData.userRole.toLowerCase() == 'it technician' || appData.isAdmin;

    final allMessages = appData.complaintsOldestFirst;
    final messages = _selectedStatusFilter == "All"
        ? allMessages
        : allMessages
            .where(
              (m) =>
                  (m['status'] ?? 'Pending').toString().toLowerCase() ==
                  _selectedStatusFilter.toLowerCase(),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IT Hub Dispatch Chat", style: TextStyle(fontSize: 17)),
            Text(
              "Local Delta-Cache Active • Auto Lab & Issue Detection",
              style: TextStyle(fontSize: 11, color: AppTheme.accentGlow),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Filter Chips Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Pending", "In Progress", "Resolved"]
                    .map((status) {
                  final selected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Cached Chat Stream
          Expanded(
            child: ResponsiveWrapper(
              child: messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No messages in this filter view",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index];
                        final isMe = data['facultyId'] == currentUid;
                        final status = (data['status'] ?? 'Pending').toString();
                        final statusColor = AppTheme.getStatusColor(status);
                        final lab = (data['lab'] ?? 'Unknown Lab').toString();
                        final category =
                            (data['issueCategory'] ?? 'Other').toString();

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: ResponsiveUtils.isDesktop(context)
                                  ? 520
                                  : MediaQuery.of(context).size.width * 0.82,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 18),
                                ),
                                border: Border.all(
                                  color: isMe
                                      ? AppTheme.primaryLight
                                      : AppTheme.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (data['facultyName'] ?? 'User')
                                              .toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: isMe
                                                ? AppTheme.accentGlow
                                                : AppTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTapDown: (details) async {
                                          if (!canUpdateStatus) return;
                                          final selected =
                                              await showMenu<String>(
                                            context: context,
                                            position: RelativeRect.fromLTRB(
                                              details.globalPosition.dx,
                                              details.globalPosition.dy,
                                              details.globalPosition.dx,
                                              details.globalPosition.dy,
                                            ),
                                            items: const [
                                              PopupMenuItem(
                                                value: 'Pending',
                                                child: Text('Mark Pending'),
                                              ),
                                              PopupMenuItem(
                                                value: 'In Progress',
                                                child: Text('Mark In Progress'),
                                              ),
                                              PopupMenuItem(
                                                value: 'Resolved',
                                                child: Text('Mark Resolved'),
                                              ),
                                            ],
                                          );
                                          if (selected != null &&
                                              data['complaintId'] != null) {
                                            _updateStatus(
                                              appData,
                                              data['complaintId'].toString(),
                                              selected,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                status,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (canUpdateStatus) ...[
                                                const SizedBox(width: 2),
                                                const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    (data['message'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      height: 1.4,
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          _miniTag(lab, isMe),
                                          _miniTag(category, isMe),
                                        ],
                                      ),
                                      Text(
                                        _formatTime(data['timestampMs']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isMe
                                              ? Colors.white60
                                              : AppTheme.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Message Composer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SafeArea(
              child: ResponsiveWrapper(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageC,
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(appData),
                        decoration: InputDecoration(
                          hintText:
                              "Describe issue & lab (e.g. 'Lab 103 PC-1-2 internet down')...",
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      onPressed: () => _sendMessage(appData),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isMe ? Colors.white12 : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isMe ? Colors.white70 : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
