import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/complains_servcie.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final ComplaintService _complaintService = ComplaintService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (mounted) {
        setState(() {
          _userRole = userDoc.data()?['role'] ?? '';
        });
      }
    }
  }

  Future<void> _updateStatus(
    String complaintId,
    String currentStatus,
    Map<String, dynamic> data,
  ) async {
    if (currentUser == null || _userRole == null) return;

    // Only IT Technician and Admin can update status
    if (_userRole != 'IT Technician' && _userRole != 'Admin') {
      _showSnackBar(
        'Only IT Technicians and Admins can update complaint status',
        isError: true,
      );
      return;
    }

    // Get available status options based on current status
    List<String> statusOptions = _getAvailableStatuses(currentStatus);

    if (statusOptions.isEmpty) {
      _showSnackBar('This complaint is already resolved', isError: true);
      return;
    }

    // Show dialog to select new status
    String? selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Complaint Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status: $currentStatus',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            const Text('Select New Status:'),
            SizedBox(height: 1.h),
            ...statusOptions.map(
              (status) => RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedStatus == null || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Unknown';

      await _complaintService.updateStatus(
        complaintId: complaintId,
        newStatus: selectedStatus,
        updaterId: currentUser!.uid,
        updaterName: userName,
        resolverId: selectedStatus.toLowerCase() == 'resolved'
            ? currentUser!.uid
            : null,
        resolverName: selectedStatus.toLowerCase() == 'resolved'
            ? userName
            : null,
      );

      if (mounted) {
        _showSnackBar('Status updated to $selectedStatus successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update status: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['In Progress', 'Resolved'];
      case 'in progress':
      case 'inprogress':
        return ['Resolved'];
      case 'resolved':
        return [];
      default:
        return ['Pending', 'In Progress', 'Resolved'];
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ResponsiveWrapper(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complaints')
              .doc(widget.complaintId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Error loading complaint',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Complaint not found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Unknown';
            final message = data['message'] ?? 'No message';
            final lab = data['lab'] ?? 'Unknown Lab';
            final issue = data['issue'] ?? 'Unknown';
            final issueCategory = data['issueCategory'] ?? 'Other';
            final facultyName = data['facultyName'] ?? 'Unknown Faculty';
            final assignedToName = data['assignedToName'] ?? 'Not Assigned';
            final createdAt = data['timestamp'] as Timestamp?;
            final resolutionTimestamp =
                data['resolutionTimestamp'] as Timestamp?;
            final timeTaken = data['timeTaken'];
            final statusUpdatedByName = data['statusUpdatedByName'] ?? 'N/A';
            final resolvedByName = data['resolvedByName'] ?? 'N/A';

            return ResponsiveWrapper(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsivePadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Card(
                      elevation: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w), // Reduced from 4.w
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.getStatusColor(status).withOpacity(0.1),
                              AppTheme.getStatusColor(status).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 13.sp, // Reduced from 14.sp
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.5.w, // Reduced from 3.w
                                    vertical: 0.6.h, // Reduced from 0.8.h
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getStatusColor(status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp, // Reduced from 13.sp
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_userRole == 'IT Technician' ||
                                _userRole == 'Admin') ...[
                              SizedBox(height: 1.5.h), // Reduced from 2.h
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.update),
                                  label: const Text('Update Status'),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _updateStatus(
                                          widget.complaintId,
                                          status,
                                          data,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.2.h, // Reduced from 1.5.h
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h), // Reduced from 2.h
                    // Complaint Message
                    _buildSectionCard(
                      title: 'Complaint Message',
                      icon: Icons.message,
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 14.sp, height: 1.5),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Issue Details
                    _buildSectionCard(
                      title: 'Issue Details',
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _buildInfoRow('Lab:', lab),
                          Divider(height: 1.5.h), // Reduced from 2.h
                          _buildInfoRow('Issue:', issue),
                          Divider(height: 1.5.h), // Reduced from 2.h
                          _buildInfoRow(
                            'Category:',
                            issueCategory,
                            valueColor: _getCategoryColor(issueCategory),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // People Involved
                    _buildSectionCard(
                      title: 'People Involved',
                      icon: Icons.people,
                      child: Column(
                        children: [
                          _buildInfoRow('Reported By:', facultyName),
                          Divider(height: 1.5.h), // Reduced from 2.h
                          _buildInfoRow('Assigned To:', assignedToName),
                          if (statusUpdatedByName != 'N/A') ...[
                            Divider(height: 1.5.h), // Reduced from 2.h
                            _buildInfoRow(
                              'Last Updated By:',
                              statusUpdatedByName,
                            ),
                          ],
                          if (resolvedByName != 'N/A') ...[
                            Divider(height: 1.5.h), // Reduced from 2.h
                            _buildInfoRow('Resolved By:', resolvedByName),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Timeline
                    _buildSectionCard(
                      title: 'Timeline',
                      icon: Icons.schedule,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Created At:',
                            createdAt != null
                                ? _formatTimestamp(createdAt)
                                : 'N/A',
                          ),
                          if (resolutionTimestamp != null) ...[
                            Divider(height: 1.5.h), // Reduced from 2.h
                            _buildInfoRow(
                              'Resolved At:',
                              _formatTimestamp(resolutionTimestamp),
                            ),
                          ],
                          if (timeTaken != null) ...[
                            Divider(height: 1.5.h), // Reduced from 2.h
                            _buildInfoRow(
                              'Time Taken:',
                              _formatDuration(timeTaken),
                              valueColor: AppTheme.successColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Complaint ID
                    _buildSectionCard(
                      title: 'Complaint ID',
                      icon: Icons.fingerprint,
                      child: SelectableText(
                        widget.complaintId,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(3.w), // Reduced from 4.w
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AppTheme.accentColor,
                ), // Reduced from 20
                SizedBox(width: 1.5.w), // Reduced from 2.w
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp, // Reduced from 16.sp
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h), // Reduced from 2.h
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w, // Reduced from 35.w
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp, // Reduced from 13.sp
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'software':
        return AppTheme.infoColor;
      case 'hardware':
        return AppTheme.errorColor;
      case 'network':
        return AppTheme.warningColor;
      case 'access':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).floor();
      final mins = minutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins min' : ''}';
    } else {
      final days = (minutes / 1440).floor();
      final hours = ((minutes % 1440) / 60).floor();
      return '$days day${days > 1 ? 's' : ''} ${hours > 0 ? '$hours hr' : ''}';
    }
  }
}
