import 'package:flutter/services.dart';
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
  final FocusNode _messageFocus = FocusNode();
  final ScrollController scrollController = ScrollController();
  final ComplaintService complaintService = ComplaintService();

  String _selectedStatusFilter = "All";

  // 3-Second Quick Complaint State
  String? _selectedLab;
  String? _selectedIssue;
  String? _selectedCategory;

  static const List<String> floor1Labs = [
    "Lab 101",
    "Lab 102",
    "Lab 103",
    "Lab 104",
  ];

  static final List<String> floor2Labs = List.generate(
    24,
    (i) => "Lab ${201 + i}",
  );

  static const List<String> specialRooms = [
    "JBR Room",
    "Faculty Room",
  ];

  static const List<Map<String, String>> commonIssues = [
    {
      "title": "Internet / Network Down",
      "category": "Network",
      "icon": "wifi_off",
    },
    {
      "title": "PC Won't Boot / Freezing",
      "category": "Hardware",
      "icon": "desktop_access_disabled",
    },
    {
      "title": "Mouse / Keyboard Fault",
      "category": "Hardware",
      "icon": "mouse",
    },
    {
      "title": "Safe Exam Browser / Portal",
      "category": "Exam",
      "icon": "menu_book",
    },
    {
      "title": "Software / Lanschool Crash",
      "category": "Software",
      "icon": "code",
    },
    {
      "title": "Projector / Display Fault",
      "category": "Hardware",
      "icon": "videocam_off",
    },
    {
      "title": "Admin Password / Login Locked",
      "category": "Access",
      "icon": "lock_reset",
    },
    {
      "title": "Other (Custom Description)",
      "category": "Other",
      "icon": "edit_note",
    },
  ];

  @override
  void dispose() {
    messageC.dispose();
    _messageFocus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToNewest() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(AppDataProvider appData) async {
    final text = messageC.text.trim();
    if (text.isEmpty && (_selectedLab == null || _selectedIssue == null)) return;

    String finalMsg = text;
    if (finalMsg.isEmpty && _selectedLab != null && _selectedIssue != null) {
      finalMsg = "[$_selectedLab] $_selectedIssue";
    } else if (_selectedLab != null &&
        !finalMsg.toLowerCase().contains(_selectedLab!.toLowerCase())) {
      finalMsg = "[$_selectedLab] $finalMsg";
    }

    messageC.clear();
    final lab = _selectedLab;
    final issue = _selectedIssue;
    final category = _selectedCategory;

    setState(() {
      _selectedLab = null;
      _selectedIssue = null;
      _selectedCategory = null;
    });

    await complaintService.createComplaint(
      message: finalMsg,
      explicitLab: lab,
      explicitIssue: issue,
      explicitCategory: category,
    );

    _scrollToNewest();
  }

  Future<void> _sendQuickComplaint(AppDataProvider appData) async {
    if (_selectedLab == null || _selectedIssue == null) return;
    final lab = _selectedLab!;
    final issue = _selectedIssue!;
    final category = _selectedCategory ?? "Other";
    final text = "[$lab] $issue";

    setState(() {
      _selectedLab = null;
      _selectedIssue = null;
      _selectedCategory = null;
    });
    messageC.clear();

    await complaintService.createComplaint(
      message: text,
      explicitLab: lab,
      explicitIssue: issue,
      explicitCategory: category,
    );

    _scrollToNewest();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppTheme.accentGlow),
              const SizedBox(width: 8),
              Expanded(
                child: Text("⚡ Dispatched in 3s: $lab • $issue"),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLabPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Lab / Room",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabSectionHeader("1st Floor Labs (101 - 104)"),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: floor1Labs.map((l) => _buildLabChip(l, ctx)).toList(),
                        ),
                        const SizedBox(height: 20),
                        _buildLabSectionHeader("2nd Floor Labs (201 - 224)"),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: floor2Labs.map((l) => _buildLabChip(l, ctx)).toList(),
                        ),
                        const SizedBox(height: 20),
                        _buildLabSectionHeader("Special Rooms & Halls"),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: specialRooms.map((l) => _buildLabChip(l, ctx)).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLabChip(String labName, BuildContext modalContext) {
    final isSelected = _selectedLab == labName;
    return ChoiceChip(
      label: Text(
        labName,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceColor,
      onSelected: (_) {
        setState(() => _selectedLab = labName);
        Navigator.pop(modalContext);
        if (_selectedIssue == null) {
          _showIssuePicker();
        }
      },
    );
  }

  void _showIssuePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Common Issue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: commonIssues.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = commonIssues[i];
                      final title = item['title']!;
                      final cat = item['category']!;
                      final isSelected = _selectedIssue == title;

                      IconData iconData = Icons.build_rounded;
                      if (cat == 'Network') iconData = Icons.wifi_off_rounded;
                      if (cat == 'Exam') iconData = Icons.menu_book_rounded;
                      if (cat == 'Software') iconData = Icons.code_rounded;
                      if (cat == 'Access') iconData = Icons.lock_reset_rounded;
                      if (cat == 'Other') iconData = Icons.edit_note_rounded;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(iconData, color: AppTheme.primaryColor, size: 20),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "Category: $cat",
                          style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                            : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        onTap: () {
                          Navigator.pop(ctx);
                          if (title.contains("Other")) {
                            setState(() {
                              _selectedIssue = null;
                              _selectedCategory = "Other";
                            });
                            if (_selectedLab != null) {
                              messageC.text = "[$_selectedLab] ";
                              messageC.selection = TextSelection.fromPosition(
                                TextPosition(offset: messageC.text.length),
                              );
                            }
                            _messageFocus.requestFocus();
                          } else {
                            setState(() {
                              _selectedIssue = title;
                              _selectedCategory = cat;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

    // Use newest-first order paired with ListView(reverse: true) for WhatsApp bottom alignment!
    final allMessages = appData.complaintsNewestFirst;
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
              "Instant 3s Dispatch • Auto Lab & Issue Recognition",
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
                      label: Text(
                        status,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppTheme.primaryColor,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Cached Chat Stream (reverse: true anchored at bottom like WhatsApp)
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
                      reverse: true, // Index 0 is at bottom (newest message)
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

          // 3-Second Quick Complaint Shortcuts Ribbon + Message Composer Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ResponsiveWrapper(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Dock
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentColor),
                                SizedBox(width: 4),
                                Text(
                                  "3s Dispatch",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Lab Selector Chip
                          ActionChip(
                            avatar: Icon(
                              Icons.meeting_room_rounded,
                              size: 16,
                              color: _selectedLab != null ? Colors.white : AppTheme.primaryColor,
                            ),
                            label: Text(
                              _selectedLab ?? "Select Lab ▾",
                              style: TextStyle(
                                color: _selectedLab != null ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                            backgroundColor: _selectedLab != null
                                ? AppTheme.primaryColor
                                : AppTheme.surfaceColor,
                            onPressed: _showLabPicker,
                          ),
                          const SizedBox(width: 8),

                          // Issue Selector Chip
                          ActionChip(
                            avatar: Icon(
                              Icons.report_problem_rounded,
                              size: 16,
                              color: _selectedIssue != null ? Colors.white : AppTheme.warningColor,
                            ),
                            label: Text(
                              _selectedIssue ?? "Select Issue ▾",
                              style: TextStyle(
                                color: _selectedIssue != null ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                            backgroundColor: _selectedIssue != null
                                ? AppTheme.primaryColor
                                : AppTheme.surfaceColor,
                            onPressed: _showIssuePicker,
                          ),

                          // Ready-to-Send Action Button if both chosen
                          if (_selectedLab != null && _selectedIssue != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _sendQuickComplaint(appData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              icon: const Icon(Icons.send_rounded, size: 14),
                              label: const Text("Send Now", style: TextStyle(fontSize: 12)),
                            ),
                          ],

                          if (_selectedLab != null || _selectedIssue != null) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: "Clear Quick Selection",
                              icon: const Icon(Icons.cancel_rounded, size: 18, color: Colors.grey),
                              onPressed: () => setState(() {
                                _selectedLab = null;
                                _selectedIssue = null;
                                _selectedCategory = null;
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Freeform Chat Input Bar with Enter-to-Send
                    Row(
                      children: [
                        Expanded(
                          child: CallbackShortcuts(
                            bindings: <ShortcutActivator, VoidCallback>{
                              const SingleActivator(LogicalKeyboardKey.enter): () =>
                                  _sendMessage(appData),
                            },
                            child: TextField(
                              controller: messageC,
                              focusNode: _messageFocus,
                              textInputAction: TextInputAction.send,
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(appData),
                              decoration: InputDecoration(
                                hintText: _selectedLab != null
                                    ? "Add notes for $_selectedLab (e.g. 'PC 3')..."
                                    : "Type custom complaint or select shortcuts above...",
                                filled: true,
                                fillColor: AppTheme.surfaceColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
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
