// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:classqr/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import '../../../core/config/env.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_selected_subject.dart';

class SubjectsTab extends ConsumerStatefulWidget {
  const SubjectsTab({super.key});

  @override
  ConsumerState<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends ConsumerState<SubjectsTab> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subCodeController = TextEditingController();
  final TextEditingController subNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  @override
  void dispose() {
    subCodeController.dispose();
    subNameController.dispose();
    super.dispose();
  }

  void errorMsg(String msg) {
    toastification.show(
      type: ToastificationType.error,
      context: context,
      alignment: Alignment.topCenter,
      title: Text(msg),
    );
  }

  Future<void> createSubject() async {
    final auth = ref.read(authStateProvider);
    final user = auth.user;
    try {
      final body = {
        "code": subCodeController.text.trim(),
        "course_name": subNameController.text.trim(),
        "teacher_id": user?.id,
        "role": auth.role,
      };
      final response = await http.post(
        Uri.parse("${Env.apiBaseUrl}/api/subject/create"),
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        subCodeController.clear();
        subNameController.clear();
        toastification.show(
          type: ToastificationType.success,
          context: context,
          alignment: Alignment.topCenter,
          title: const Text("Subject created successfully"),
        );
        await fetchSubjects(); // Refresh subjects after creation
      } else if (response.statusCode == 409) {
        errorMsg("Subject code already exists.");
      } else {
        errorMsg("Failed to create subject.");
      }
    } catch (e) {
      errorMsg("Something went wrong.");
    }
    try {
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      errorMsg("Something went wrong: $e");
    }
  }

  Future<void> deleteCourse(String code) async {
    final auth = ref.read(authStateProvider);
    try {
      final response = await http.delete(
        Uri.parse("${Env.apiBaseUrl}/api/subject/$code"),
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"role": auth.role}),
      );

      if (response.statusCode == 200) {
        toastification.show(
          type: ToastificationType.success,
          context: context,
          alignment: Alignment.topCenter,
          title: const Text("Course deleted successfully"),
        );
      } else {
        errorMsg("Failed to delete course.");
      }
    } catch (e) {
      errorMsg("Something went wrong.");
    }
  }

  Future<void> fetchSubjects() async {
    final auth = ref.read(authStateProvider);
    final user = auth.user;
    try {
      final uri = Uri.parse(
        "${Env.apiBaseUrl}/api/subject/${user?.id}/subjects",
      );
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "Content-Type": "application/json",
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 304) &&
          response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Course> subjects = data
            .map((e) => Course.fromJson(e))
            .toList();
        // Update the subjects provider with fetched data
        // assign to the notifier's state directly since setSubjects isn't defined
        (ref.read(teacherSelectedSubjectsProvider.notifier) as dynamic).state =
            subjects;
      } else {
        errorMsg("Failed to fetch subjects.");
      }
    } catch (e) {
      errorMsg("Something went wrong.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(teacherSelectedSubjectsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          width: 120, // your desired width
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // required for strict width
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Create Course"),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: subCodeController,
                          decoration: const InputDecoration(
                            labelText: "Course Code",
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: subNameController,
                          decoration: const InputDecoration(
                            labelText: "Course Name",
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Required" : null,
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
                      onPressed: createSubject,
                      child: const Text("Create"),
                    ),
                  ],
                ),
              );
            },

            child: const Text("Create Course", textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Teaching Courses",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ...(subjects.isEmpty
            ? [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "No course to be taught.\nPlease create a course first.",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]
            : subjects.map((c) {
                return InkWell(
                  onTap: () {
                    context.go("/teacher/activity/", extra: c.course_id);
                    ref.read(selectedCourseProvider.notifier).setCourse(c);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 35,
                          color: Colors.indigo.shade400,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.courseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Code: ${c.code}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('${c.courseName} Options'),
                                content: const Text(
                                  'What would you like to do with this course?',
                                ),
                                actions: [
                                  // DELETE BUTTON
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop(); // close first dialog

                                      // CONFIRMATION DIALOG
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text(
                                            'Are you sure you want to delete "${c.courseName}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              onPressed: () async {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // close confirm dialog
                                                await deleteCourse(c.code);
                                                await fetchSubjects();
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),

                                  // CLOSE BUTTON
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),
        const SizedBox(height: 12),
      ],
    );
  }
}
