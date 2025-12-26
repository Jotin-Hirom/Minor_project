import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/enrollment_provider.dart';

class AttendanceSearchBar extends ConsumerWidget {
  const AttendanceSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: "Search by roll no or name",
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        ref.read(attendanceSearchQueryProvider.notifier).state = value
            .toLowerCase();
      },
    );
  }
}
