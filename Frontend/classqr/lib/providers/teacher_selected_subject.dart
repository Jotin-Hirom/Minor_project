import 'package:flutter_riverpod/legacy.dart';
import '../models/subject.dart';

final teacherSelectedSubjectsProvider =
    StateNotifierProvider<SelectedSubjectsNotifier, List<Course>>(
      (ref) => SelectedSubjectsNotifier(),
    );

class SelectedSubjectsNotifier extends StateNotifier<List<Course>> {
  SelectedSubjectsNotifier() : super([]);

  void toggle(Course subject) {
    if (state.any((s) => s.code == subject.code)) {
      state = state.where((s) => s.code != subject.code).toList();
    } else {
      state = [...state, subject];
    }
  }

  void clear() => state = [];
}


final selectedCourseProvider =
    StateNotifierProvider<SelectedCourseNotifier, Course?>(
      (ref) => SelectedCourseNotifier(),
    );

class SelectedCourseNotifier extends StateNotifier<Course?> {
  SelectedCourseNotifier() : super(null);

  void setCourse(Course course) { 
    state = course;
  }

  void clear() {
    state = null;
  }
}
