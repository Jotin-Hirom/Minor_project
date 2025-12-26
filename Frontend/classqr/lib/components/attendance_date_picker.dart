import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/enrollment_provider.dart';

class AttendanceDatePicker extends ConsumerWidget {
  const AttendanceDatePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedAttendanceDateProvider);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2025),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          ref.read(selectedAttendanceDateProvider.notifier).state = picked;
        }
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 6),
          Text(
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
 
  }
}
