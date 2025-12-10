// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constant/console.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_selected_subject.dart';

class SubjectsTab extends ConsumerWidget {
  const SubjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(teacherSelectedSubjectsProvider);
    final auth = ref.watch(authStateProvider);
    log(auth.token.toString());
    final user = auth.user;
    // Replace this with actual provider later
    // final subjects = [
    //   {"name": "Data Structures", "code": "CS201", "teacher": "Dr. Sharma"},
    //   {"name": "Operating Systems", "code": "CS301", "teacher": "Prof. Bora"},
    //   {"name": "AI & ML", "code": "CS401", "teacher": "Dr. Das"},
    // ];

    return
    // subjects.isEmpty
    //     ? const Center(
    //         child: Text("No subjects selected.\nPlease choose subjects first."),
    //       )
    //     : ListView.builder(
    //         padding: const EdgeInsets.all(12),
    //         itemCount: subjects.length,
    //         itemBuilder: (context, index) {
    //           final s = subjects[index];
    //           return Card(
    //             margin: const EdgeInsets.only(bottom: 10),
    //             child: ListTile(
    //               title: Text("${s.courseName} (${s.code})"),
    //               subtitle: const Text("Tap to open"),
    //               onTap: () {
    //                 context.push("/teacher/course/${s.code}");
    //               },
    //             ),
    //           );
    //         },
    //       );
    ListView(
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
            onPressed: () => context.go("/teacher/select-subjects"),
            child: const Text("Create Subject", textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Teaching Subjects",
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
                  child: const Center(
                    child: Text(
                      "No subjects to be taught.\nPlease choose subjects first.",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]
            : subjects.map((c) {
                return InkWell(
                  onTap: () {
                    // context.push("/teacher/course/${c.code}");
                    print("pressed");
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
                                content: const Text('More options can be added here.'),
                                actions: [
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
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         // item.name,
                    //         "Instructor: ${user!.name}",
                    //         style: const TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 4),
                    //       // Text(item.description),
                    //     ],
                    //   ),
                    // ),
                    // Edit side
                  ),
                );
              }).toList()),

        const SizedBox(height: 12),
      ],
    );
  }
}
