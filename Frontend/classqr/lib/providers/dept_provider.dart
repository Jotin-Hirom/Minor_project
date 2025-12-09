import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider for list of departments
final departmentsProvider =
    StateNotifierProvider<DepartmentsNotifier, List<String>>(
      (ref) => DepartmentsNotifier()..loadDepartments(),
    );

/// Provider for selected department
final selectedDepartmentProvider = StateProvider<String?>((ref) => null);

class DepartmentsNotifier extends StateNotifier<List<String>> {
  DepartmentsNotifier() : super([]);

  Future<void> loadDepartments() async {
    try {
      final csv = await rootBundle.loadString(
        'assets/departments/tezpur_departments.csv',
      );

      final rows = csv
          .split('\n')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();

      state = rows;
    } catch (e) {
      throw e.toString();
    }
  }
}
