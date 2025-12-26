import 'dart:async';
import 'dart:convert';
import 'package:classqr/components/action_chip.dart';
import 'package:classqr/components/attendance_row.dart';
import 'package:classqr/components/export_button.dart';
import 'package:classqr/components/section_card.dart';
import 'package:classqr/components/semester_dropdown.dart';
import 'package:classqr/components/programme_dropdown.dart';
import 'package:classqr/components/primary_button.dart';
import 'package:classqr/components/table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../providers/teacher_selected_subject.dart';

class ActivityPage extends ConsumerStatefulWidget {
  final String course_id;
  const ActivityPage({super.key, required this.course_id});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  String? qrData;
  Timer? expiryTimer;

  Future<void> _generateQr() async {
    final auth = ref.read(authStateProvider);

    final res = await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/qr/generate"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"course_id": widget.course_id, "duration_minutes": 10}),
    );

    final data = jsonDecode(res.body);

    setState(() {
      qrData = data["qr_id"]; // RANDOM UUID
    });

    // Auto-expire after 10 minutes
    expiryTimer?.cancel();
    expiryTimer = Timer(const Duration(minutes: 10), () {
      _showExpiredDialog();
    });
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("QR Expired"),
        content: const Text("Attendance window is closed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openApprovalPanel();
            },
            child: const Text("Review Attendance"),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchPendingScans() async {
    final auth = ref.read(authStateProvider);

    final res = await http.get(
      Uri.parse(
        "${Env.apiBaseUrl}/attendance/pending?course_id=${widget.course_id}",
      ),
      headers: {"Authorization": "Bearer ${auth.token}"},
    );

    return jsonDecode(res.body);
  }

  void _openApprovalPanel() async {
    final scans = await _fetchPendingScans();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ListView.builder(
        itemCount: scans.length,
        itemBuilder: (_, i) {
          final s = scans[i];
          return ListTile(
            title: Text(s["student_name"]),
            subtitle: Text(s["roll_no"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approve(s["scan_id"], true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _approve(s["scan_id"], false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _approve(String scanId, bool accepted) async {
    final auth = ref.read(authStateProvider);

    await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/verify"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "scan_id": scanId,
        "result": accepted ? "accepted" : "rejected",
      }),
    );
  }

  Future<void> scanQr(String qrId) async {
    final auth = ref.read(authStateProvider);

    final res = await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/scan"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"qr_id": qrId}),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan submitted for approval")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  @override
  void dispose() {
    expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 900;
        final EdgeInsets padding = EdgeInsets.all(isDesktop ? 24 : 16);
        final selectedDate = ref.watch(selectedAttendanceDateProvider);
        final date =
            "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}";
        return Scaffold(
          appBar: AppBar(
            title: const Text("Activity Page"),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),

          body: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STUDENT ENROLLMENT SECTION
                SectionCard(
                  title: "Add Students",
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: ProgrammeDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: SemesterDropdown()),
                            const SizedBox(width: 16),
                            PrimaryButton(
                              label: "Search Students",
                              course_id: widget.course_id,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            ProgrammeDropdown(),
                            const SizedBox(height: 12),
                            SemesterDropdown(),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: "Search Students",
                              course_id: widget.course_id,
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),
                isDesktop
                    ? Row(
                        children: [
                          // ATTENDANCE TAKING SECTION
                          SectionCard(
                            title: "Take Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CustomActionChip(
                                  icon: Icons.qr_code_scanner,
                                  label: "Generate QR",
                                  onPressed: () async {
                                    // Handle QR code generation here
                                    await _generateQr();
                                  },
                                ),
                                CustomActionChip(
                                  icon: Icons.edit_note,
                                  label: "Manual Entry",
                                  onPressed: () async {
                                    // Handle manual entry here
                                  },
                                ),
                                CustomActionChip(
                                  icon: Icons.refresh,
                                  label: "Reset Attendance",
                                  onPressed: () async {
                                    // Handle attendance reset here
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),
                          // EXPORT ATTENDANCE SECTION
                          SectionCard(
                            title: "Export Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                ExportButton(
                                  icon: Icons.picture_as_pdf,
                                  label: "Export PDF",
                                  color: Colors.red,
                                ),
                                ExportButton(
                                  icon: Icons.table_chart,
                                  label: "Export Excel",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // ATTENDANCE TAKING SECTION
                          SectionCard(
                            title: "Take Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CustomActionChip(
                                  icon: Icons.qr_code_scanner,
                                  label: "Generate QR",
                                  onPressed: () async {
                                    // Handle QR code generation here
                                    await _generateQr();
                                  },
                                ),
                                CustomActionChip(
                                  icon: Icons.edit_note,
                                  label: "Manual Entry",
                                  onPressed: () async {
                                    // Handle manual entry here
                                  },
                                ),
                                CustomActionChip(
                                  icon: Icons.refresh,
                                  label: "Reset Attendance",
                                  onPressed: () async {
                                    // Handle attendance reset here
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          // EXPORT ATTENDANCE SECTION
                          SectionCard(
                            title: "Export Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                ExportButton(
                                  icon: Icons.picture_as_pdf,
                                  label: "Export PDF",
                                  color: Colors.red,
                                ),
                                ExportButton(
                                  icon: Icons.table_chart,
                                  label: "Export Excel",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: 24),

                // ATTENDANCE RECORDS SECTION
                SectionCard(
                  title: "Attendance Records",
                  child: Consumer(
                    builder: (context, ref, _) {
                      final course = ref.watch(selectedCourseProvider);

                      final String? courseId = course?.course_id;
                      if (courseId == null || courseId.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Invalid course selected"),
                        );
                      }

                      final enrolledAsync = ref.watch(
                        enrolledStudentsProvider(widget.course_id),
                      );

                      return enrolledAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            e.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        data: (students) {
                          if (students.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "No students enrolled in this course.",
                              ),
                            );
                          }

                          return Column(
                            children: [
                              TableHeader(),
                              const Divider(height: 1),

                              ...students.map(
                                (s) => AttendanceRow(
                                  roll: s.rollNo,
                                  name: s.name,
                                  present: s.present,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}
