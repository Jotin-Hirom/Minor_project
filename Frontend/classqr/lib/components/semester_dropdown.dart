import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedSemesterProvider = StateProvider<int?>((ref) => null);

class SemesterDropdown extends ConsumerWidget {
  const SemesterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: "Semester",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      isExpanded: true,

      items: List.generate(
        10,
        (i) => DropdownMenuItem(value: i + 1, child: Text("Semester ${i + 1}")),
      ),
      onChanged: (value) {
        ref.read(selectedSemesterProvider.notifier).state = value;
      },
    );
  }
}
