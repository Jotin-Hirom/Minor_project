import 'package:flutter_riverpod/legacy.dart';
import '../models/subject.dart';

final teacherSelectedSubjectsProvider =
    StateNotifierProvider<SelectedSubjectsNotifier, List<Subject>>(
      (ref) => SelectedSubjectsNotifier(),
    );

class SelectedSubjectsNotifier extends StateNotifier<List<Subject>> {
  SelectedSubjectsNotifier() : super([]);

  void toggle(Subject subject) {
    if (state.any((s) => s.code == subject.code)) {
      state = state.where((s) => s.code != subject.code).toList();
    } else {
      state = [...state, subject];
    }
  }

  void clear() => state = [];
}
