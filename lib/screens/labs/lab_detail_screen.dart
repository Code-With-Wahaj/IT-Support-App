import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lab_model.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/complaint_detail_screen.dart';
import 'add_edit_labs_screens.dart';

class LabDetailScreen extends StatefulWidget {
  final LabModel lab;

  const LabDetailScreen({super.key, required this.lab});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> {
  String _formatLayout(String layout) {
    final lower = layout.trim().toLowerCase();
    if (lower == 'grid' || lower == 'custom theater') {
      return 'Custom Theater';
    } else if (lower == 'theater') {
      return 'Theater';
    } else if (lower == 'u' || lower == 'u shape') {
      return 'U-Shape';
    }
    return layout.toUpperCase();
  }

  void _showPcInfoDialog(BuildContext context, int row, int col) {
    final pcId = "PC-${(row * widget.lab.columns) + col + 1}";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.computer_rounded, color: AppTheme.accentColor),
            ),
            const SizedBox(width: 12),
            Text(pcId, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogDetailRow("Location", "${widget.lab.name} (Row ${row + 1}, Col ${col + 1})"),
            _dialogDetailRow("Hardware Status", "Operational (All Systems OK)"),
            _dialogDetailRow("Network", "Connected (1000 Mbps LAN)"),
            _dialogDetailRow("Supervised By", widget.lab.assignedTo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.report_problem_outlined, size: 16),
            label: const Text("Report PC Issue"),
            onPressed: () {
              Navigator.pop(ctx);
              _showQuickReportDialog(context, pcId);
            },
          ),
        ],
      ),
    );
  }

  Widget _dialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickReportDialog(BuildContext context, [String? prefilledPc]) {
    final titleController = TextEditingController(
      text: prefilledPc != null ? "Hardware issue on $prefilledPc" : "",
    );
    final msgController = TextEditingController();
    String category = 'Hardware';
    String priority = 'Medium';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Report Issue in ${widget.lab.name}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Issue Title",
                    hintText: "e.g. Mouse not responding, No internet",
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: const [
                    DropdownMenuItem(value: "Hardware", child: Text("Hardware")),
                    DropdownMenuItem(value: "Software", child: Text("Software")),
                    DropdownMenuItem(value: "Network", child: Text("Network")),
                    DropdownMenuItem(value: "Exam", child: Text("Exam / Critical")),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'Hardware'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: "Priority"),
                  items: const [
                    DropdownMenuItem(value: "Low", child: Text("Low")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "High", child: Text("High")),
                  ],
                  onChanged: (v) => setDialogState(() => priority = v ?? 'Medium'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: msgController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    hintText: "Provide details of the problem...",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      setDialogState(() => isSubmitting = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final facultyName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Staff';
                        final facultyId = user?.uid ?? '';

                        final docRef = FirebaseFirestore.instance.collection('complaints').doc();
                        await docRef.set({
                          'complaintId': docRef.id,
                          'issue': title,
                          'issueCategory': category,
                          'message': msgController.text.trim().isNotEmpty
                              ? msgController.text.trim()
                              : title,
                          'lab': widget.lab.name,
                          'status': 'Pending',
                          'priority': priority,
                          'facultyId': facultyId,
                          'facultyName': facultyName,
                          'assignedToId': widget.lab.assignedTechnicianId,
                          'assignedToName': widget.lab.assignedTo,
                          'timestamp': FieldValue.serverTimestamp(),
                          'createdAt': DateTime.now().millisecondsSinceEpoch,
                        });

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Support ticket submitted successfully!"),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error submitting ticket: $e"),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Submit Ticket"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataProvider>(context);
    final isAdmin = appData.isAdmin;
    final totalWorkstations = (widget.lab.rows * widget.lab.columns) + 1;
    final formattedLayout = _formatLayout(widget.lab.layoutType);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.lab.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: "Configure Topology",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditLabScreen(lab: widget.lab),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.developer_board_rounded,
                            color: AppTheme.accentGlow,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lab.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      formattedLayout.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$totalWorkstations Total PCs",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statTile(Icons.table_rows_rounded, "Rows", "${widget.lab.rows}"),
                          Container(width: 1, height: 30, color: AppTheme.borderColor),
                          _statTile(Icons.view_column_rounded, "Columns", "${widget.lab.columns}"),
                          Container(width: 1, height: 30, color: AppTheme.borderColor),
                          _statTile(Icons.support_agent_rounded, "Technician", widget.lab.assignedTo),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section: Visual Floor Plan & PC Layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Workstation Matrix",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  "Tap any PC for details",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual Layout Grid
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Instructor Station at Front
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.co_present_rounded, size: 20, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            "INSTRUCTOR DESK (PC-00)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Student Workstations Matrix
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.lab.rows, (rowIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: List.generate(widget.lab.columns, (colIndex) {
                                final pcNumber = (rowIndex * widget.lab.columns) + colIndex + 1;
                                final pcLabel = pcNumber < 10 ? "PC-0$pcNumber" : "PC-$pcNumber";

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => _showPcInfoDialog(context, rowIndex, colIndex),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 68,
                                      height: 60,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.borderColor),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.computer_rounded,
                                            size: 20,
                                            color: AppTheme.accentColor,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pcLabel,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Active Issues & Tickets for this Lab
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lab Support Tickets",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Report Issue"),
                  onPressed: () => _showQuickReportDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Realtime Stream of Tickets
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('lab', isEqualTo: widget.lab.name)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 40,
                              color: AppTheme.successColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "No Active Issues in this Lab",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "All workstations and network systems are running normally.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final issue = (data['issue'] ?? 'Issue').toString();
                    final status = (data['status'] ?? 'Pending').toString();
                    final faculty = (data['facultyName'] ?? 'Faculty').toString();
                    final complaintId = docs[index].id;

                    Color statusColor = AppTheme.statusPending;
                    if (status.toLowerCase() == 'in progress') {
                      statusColor = AppTheme.statusInProgress;
                    } else if (status.toLowerCase() == 'resolved') {
                      statusColor = AppTheme.statusResolved;
                    }

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderColor),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComplaintDetailScreen(complaintId: complaintId),
                            ),
                          );
                        },
                        leading: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          issue,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          "Reported by $faculty • Status: $status",
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
