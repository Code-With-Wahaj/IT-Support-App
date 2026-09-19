import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import '../../services/complains_servcie.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageC = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ComplaintService complaintService = ComplaintService();

  User? user;
  String userName = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  fetchUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userName = doc['name'] ?? '';
        role = doc['role'] ?? '';
      });
    }
  }

  sendMessage() async {
    final message = messageC.text.trim();
    if (message.isEmpty) return;

    // Clear the text field IMMEDIATELY for responsive UI
    messageC.clear();

    await complaintService.createComplaint(message: message);

    // Scroll after message is sent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  updateStatus(String complaintId, String newStatus) async {
    if (user == null) return;
    await complaintService.updateStatus(
      complaintId: complaintId,
      newStatus: newStatus,
      updaterId: user!.uid,
      updaterName: userName,
      resolverId: newStatus.toLowerCase() == 'resolved' ? user!.uid : null,
      resolverName: newStatus.toLowerCase() == 'resolved' ? userName : null,
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.errorColor;
      case 'in progress':
        return AppTheme.warningColor;
      case 'resolved':
        return AppTheme.successColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("IT Hub Group Chat")),
        // CHANGED: Moved ResponsiveWrapper inside the Column so it only affects the list
        body: Column(
          children: [
            Expanded(
              child: ResponsiveWrapper(
                child: StreamBuilder<QuerySnapshot>(
                  stream: complaintService.getComplaintsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: AppTheme.textTertiary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Scroll to bottom once list is built
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasClients) {
                        scrollController.jumpTo(
                          scrollController.position.maxScrollExtent,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: ResponsiveUtils.getResponsivePadding(
                          context,
                        ),
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];
                        final isMe = data['facultyId'] == user?.uid;

                        return Container(
                          margin: EdgeInsets.only(bottom: 1.5.h),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Message bubble
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      ResponsiveUtils.isDesktop(context)
                                          ? 500
                                          : 75.w,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 1.5.h,
                                        horizontal: 4.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? AppTheme.primaryColor
                                            : AppTheme.cardColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(
                                            isMe ? 16 : 4,
                                          ),
                                          bottomRight: Radius.circular(
                                            isMe ? 4 : 16,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            data['facultyName'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isMe
                                                  ? Colors.white70
                                                  : AppTheme.accentColor,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            data['message'] ?? '',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: isMe
                                                  ? Colors.white
                                                  : AppTheme.textPrimary,
                                              height: 1.3,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              formatTimestamp(
                                                data['timestamp'],
                                              ),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: isMe
                                                    ? Colors.white60
                                                    : AppTheme.textTertiary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Status chip
                                  Positioned(
                                    top: -8,
                                    right: 0,
                                    child: GestureDetector(
                                      onTapDown: (details) async {
                                        if (role.toLowerCase() !=
                                            'it technician')
                                          return;

                                        final selected = await showMenu<String>(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                            details.globalPosition.dx,
                                            details.globalPosition.dy,
                                            details.globalPosition.dx,
                                            details.globalPosition.dy,
                                          ),
                                          items: [
                                            const PopupMenuItem(
                                              value: 'Pending',
                                              child: Text('Pending'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'In Progress',
                                              child: Text('In Progress'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'Resolved',
                                              child: Text('Resolved'),
                                            ),
                                          ],
                                        );
                                        if (selected != null) {
                                          updateStatus(
                                            data['complaintId'],
                                            selected,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(
                                            data['status'] ?? 'Pending',
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          data['status'] ?? 'Pending',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // CHANGED: Input Container is now outside ResponsiveWrapper to take full width
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsivePadding(context),
                    vertical: 1.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: messageC,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(
                                color: AppTheme.textTertiary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: sendMessage,
                          icon: Icon(Icons.send, color: Colors.white),
                          iconSize: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}