import 'dart:convert';
import 'package:classqr/models/subject.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Loads subject list
final allSubjectsProvider = FutureProvider<List<Course>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/subjects/subject.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final List items = data['subjects'];

  return items.map((e) => Course.fromJson(e)).toList();
});

// Holds search text
final subjectSearchProvider = StateProvider<String>((ref) => "");

// Holds sort option
final subjectSortProvider = StateProvider<String>((ref) => "A-Z");



// Future<void> loadSub() async {
//   // 1. Load JSON from Flutter assets
//   final jsonString = await rootBundle.loadString(
//     'assets/subjects/subject.json',
//   );

//   // 2. Decode JSON
//   final jsonData = jsonDecode(jsonString);

//   // 3. Parse into Subject model list
//   final subjects = (jsonData['subjects'] as List)
//       .map((item) => Subject.fromJson(item))
//       .toList();

//   // 4. Print for debugging
//   print('Tezpur University Subjects:');
//   for (var subject in subjects) {
//     print('${subject.code} - ${subject.courseName}');
//   }

//   // 5. Example search
//   final searchCode = 'MS101';
//   final found = subjects.firstWhere(
//     (s) => s.code == searchCode,
//     orElse: () => Subject(code: 'N/A', courseName: 'Not Found'),
//   );

//   print('Search "$searchCode": ${found.courseName}');
// }

