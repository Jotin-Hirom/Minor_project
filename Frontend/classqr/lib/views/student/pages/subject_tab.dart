import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectsTab extends ConsumerWidget {
  const SubjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Replace this with actual provider later
    final subjects = [
      {"name": "Data Structures", "code": "CS201", "teacher": "Dr. Sharma"},
      {"name": "Operating Systems", "code": "CS301", "teacher": "Prof. Bora"},
      {"name": "AI & ML", "code": "CS401", "teacher": "Dr. Das"},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Enrolled Subjects",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...subjects.map((c) {
          return Container(
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
                Icon(Icons.book, size: 35, color: Colors.indigo.shade400),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c["name"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Code: ${c["code"]}"),
                      Text("Teacher: ${c["teacher"]}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
