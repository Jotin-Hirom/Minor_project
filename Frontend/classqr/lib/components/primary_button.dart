import 'dart:convert';
import 'package:classqr/components/programme_dropdown.dart';
import 'package:classqr/components/semester_dropdown.dart';
import 'package:classqr/components/student_card.dart';
import 'package:classqr/core/config/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

import '../models/student.dart';
import '../providers/auth_provider.dart';

enum SelectionMode { single, multiple, all }

class PrimaryButton extends ConsumerWidget {
  final String label;
  final String course_id;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.course_id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authStateProvider);
    Future<void> bulkEnrollStudents({
      required String courseId,
      required List<String> studentIds,
    }) async {
      final url = Uri.parse('${Env.apiBaseUrl}/api/enrollment/bulk-enroll');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({
          'course_id': courseId,
          'student_ids': studentIds,
          'role': auth.role,
        }),
      );

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Bulk enrollment failed');
      }
    }

    void errorMsg(String msg) {
      toastification.show(
        type: ToastificationType.error,
        context: context,
        alignment: Alignment.topCenter,
        title: Text(msg),
      );
    }

    void successMsg(String msg) {
      toastification.show(
        type: ToastificationType.success,
        context: context,
        alignment: Alignment.topCenter,
        title: Text(msg),
      );
    }

    void showStudentsDialog(
      BuildContext context,
      WidgetRef ref,
      List<StudentModel> students,
      String courseId,
    ) {
      SelectionMode mode = SelectionMode.multiple;
      final Set<String> selectedIds = {};

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final media = MediaQuery.of(context);
              final isDesktop = media.size.width > 900;

              final dialogWidth = isDesktop
                  ? media.size.width * 0.65
                  : media.size.width * 0.9;
              final dialogHeight = media.size.height * 0.8;

              void toggle(StudentModel s) {
                setState(() {
                  if (mode == SelectionMode.single) {
                    selectedIds
                      ..clear()
                      ..add(s.userId);
                  } else {
                    selectedIds.contains(s.userId)
                        ? selectedIds.remove(s.userId)
                        : selectedIds.add(s.userId);
                  }
                });
              }

              return AlertDialog(
                title: const Text("Students Found"),
                content: SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: Column(
                    children: [
                      // Selection mode (fixed)
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("Single"),
                            selected: mode == SelectionMode.single,
                            onSelected: (_) =>
                                setState(() => mode = SelectionMode.single),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text("Multiple"),
                            selected: mode == SelectionMode.multiple,
                            onSelected: (_) =>
                                setState(() => mode = SelectionMode.multiple),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text("Select All"),
                            selected: mode == SelectionMode.all,
                            onSelected: (_) {
                              setState(() {
                                mode = SelectionMode.all;
                                selectedIds
                                  ..clear()
                                  ..addAll(students.map((e) => e.userId));
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      if (students.isEmpty)
                        Center(
                          child: const Text(
                            "No students found for the selected programme and semester.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final s = students[index];
                            return StudentCard(
                              student: s,
                              selected: selectedIds.contains(s.userId),
                              onTap: () => toggle(s),
                            );
                          },
                        ),
                      ),

                      const Divider(),

                      // Selected students (horizontal scroll only)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Selected Students (${selectedIds.length})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: students
                              .where((s) => selectedIds.contains(s.userId))
                              .map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Chip(
                                    label: Text("${s.rollNo} – ${s.name}"),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: selectedIds.isEmpty
                        ? null
                        : () async {
                            try {
                              final selectedStudents = students
                                  .where((s) => selectedIds.contains(s.userId))
                                  .toList();

                              final studentIds = selectedStudents
                                  .map((s) => s.userId)
                                  .toList();

                              await bulkEnrollStudents(
                                courseId: courseId,
                                studentIds: studentIds,
                              );

                              Navigator.pop(context);

                              toastification.show(
                                type: ToastificationType.success,
                                context: context,
                                alignment: Alignment.topCenter,
                                title: Text(
                                  "Enrolled ${studentIds.length} students successfully",
                                ),
                              );
                            } catch (e) {
                              toastification.show(
                                type: ToastificationType.error,
                                context: context,
                                alignment: Alignment.topCenter,
                                title: Text(e.toString()),
                              );
                            }
                          },

                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return ElevatedButton(
      onPressed: () async {
        final programme = ref.read(selectedProgrammeProvider);
        final semester = ref.read(selectedSemesterProvider);
        final auth = ref.read(authStateProvider);
        if (programme == null || semester == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select a programme and semester."),
            ),
          );
          return;
        }
        final url = Uri.parse(
          '${Env.apiBaseUrl}/api/student/filter?programme=$programme&semester=$semester',
        );
        final dynamic response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${auth.token}',
          },
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final List<StudentModel> students = data
              .map((e) => StudentModel.fromJson(e))
              .toList();
          showStudentsDialog(context, ref, students, course_id);
        } else {
          errorMsg("Failed to fetch students. Please try again.");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(label),
    );
  }
}
