import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import '../../constant/console.dart';
import '../../core/config/env.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_selected_subject.dart';
import 'package:go_router/go_router.dart';

import '../student/pages/attendance_tab.dart';
import '../student/pages/profile_tab.dart';
import '../student/pages/subject_tab.dart';

class TeacherDashboard extends ConsumerWidget {
  final String? token;
  final User? user;
  const TeacherDashboard({super.key, this.token, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ClassQR - Teacher Dashboard"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.subject), text: 'Subjects'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse('${Env.apiBaseUrl}/api/auth/logout');
                dynamic response;
                try {
                  //to be fixed
                  var token = auth.token;
                  final result = await http.post(
                    url,
                    headers: {
                      "Authorization": "Bearer $token",
                      "Content-Type": "application/json",
                    },
                    body: jsonEncode({"email": user?.email.toLowerCase()}),
                  );
                  response = result;
                } catch (e) {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Server error."),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }
                if (response.statusCode == 200) {
                  toastification.show(
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Logged out successfully."),
                  );
                  await ref.read(authStateProvider.notifier).logout();
                  context.go('/auth');
                } else {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Can't logout."),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }
              },
              child: Icon(
                CupertinoIcons.square_arrow_right,
                size: 30.0,
                color: CupertinoColors.white, // Or any other color
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ProfileTab(user: user),
            SubjectsTab(),
          ],
        ),
      ),
    );
  }
}




// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:classqr/models/app_user.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:uuid/uuid.dart';
// import '../../models/attendance.dart';
// import '../../models/subject.dart';
// import '../../providers/teacher_provider.dart';
// import 'package:toastification/toastification.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import '../../services/teacher_services.dart';

// class TeacherDashboard extends ConsumerStatefulWidget {
//   final String? token;
//   final User? user;
//   const TeacherDashboard({super.key, this.token, this.user});

//   @override
//   ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
//   Subject? selectedSubject;
//   String filterSemester = '';
//   String filterProgramme = '';

//   Timer? _qrTimer;
//   String? _qrToken;
//   DateTime? _qrExpiresAt;
//   List<AttendanceRecord> _scannedBuffer =
//       []; // local collected scans before accept

//   @override
//   void initState() {
//     super.initState();
//     // load subjects
//     ref.read(subjectsProvider.notifier).load();
//   }

//   @override
//   void dispose() {
//     _qrTimer?.cancel();
//     super.dispose();
//   }

//   void _selectSubject(Subject s) {
//     selectedSubject = s;
//     // load students for subject
//     ref.read(studentsProvider.notifier).loadForSubject(s.code);
//     // load attendance summary
//     ref.read(attendanceProvider.notifier).load(s.code);
//     setState(() {}); // only for local selection
//   }

//   Future<void> _openSubjectDetails(Subject s) async {
//     _selectSubject(s);
//     // show bottom sheet with details
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (ctx) {
//         return SubjectDetailsSheet(subject: s);
//       },
//     );
//   }

//   // Take attendance: generate token (server or client)
//   Future<void> _startTakeAttendance(Subject s) async {
//     // generate token locally for demo; prefer server issued token
//     final token = const Uuid().v4();
//     _qrToken = token;
//     _qrExpiresAt = DateTime.now().add(const Duration(minutes: 10));

//     // optionally tell server that a token is active
//     // await TeacherService.generateQrToken(s.id);

//     // clear buffer
//     _scannedBuffer = [];

//     // start timer
//     _qrTimer?.cancel();
//     _qrTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (_qrExpiresAt != null && DateTime.now().isAfter(_qrExpiresAt!)) {
//         t.cancel();
//         setState(() {
//           _qrToken = null;
//           _qrExpiresAt = null;
//         });
//       } else {
//         setState(() {}); // update countdown
//       }
//     });

//     // Show the QR dialog/sheet
//     await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Scan QR for ${s.code}'),
//         content: SizedBox(
//           width: 300,
//           height: 360,
//           child: Column(
//             children: [
//               if (_qrToken != null) ...[
//                 // QrImage(data: _qrToken!, size: 220),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Expires at: ${_qrExpiresAt?.toLocal().toIso8601String() ?? ""}',
//                 ),
//                 const SizedBox(height: 12),
//                 Text('Scanned: ${_scannedBuffer.length} (simulated)'),
//               ] else
//                 const Text('QR expired'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // reject -> go back to course details
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('Reject'),
//           ),
//           TextButton(
//             onPressed: () async {
//               // Accept -> open confirmation page to persist
//               Navigator.of(ctx).pop();
//               await _confirmAndSubmitScans(s);
//             },
//             child: const Text('Accept'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Simulate scan append (in real app, students' devices call server with token; teacher can poll)
//   void _simulateStudentScan(String studentId) {
//     if (selectedSubject == null) return;
//     final record = AttendanceRecord(
//       id: const Uuid().v4(),
//       subjectCode: selectedSubject!.code,
//       studentId: studentId,
//       date: DateTime.now(),
//       present: true,
//     );
//     _scannedBuffer.add(record);
//     setState(() {});
//   }

//   Future<void> _confirmAndSubmitScans(Subject s) async {
//     if (_scannedBuffer.isEmpty) {
//       toastification.show(
//         type: ToastificationType.error,
//         context: context,
//         title: const Text('No scans'),
//       );
//       return;
//     }

//     final ok = await ref
//         .read(attendanceProvider.notifier)
//         .submitBulk(s.code, _scannedBuffer);
//     if (ok) {
//       toastification.show(
//         type: ToastificationType.success,
//         context: context,
//         title: const Text('Attendance saved'),
//       );
//       // reload
//       await ref.read(attendanceProvider.notifier).load(s.code);
//     } else {
//       toastification.show(
//         type: ToastificationType.error,
//         context: context,
//         title: const Text('Failed to save'),
//       );
//     }
//     _scannedBuffer = [];
//   }


//   @override
//   Widget build(BuildContext context) {
//     final subjects = ref.watch(subjectsProvider);
//     final students = ref.watch(studentsProvider);
//     final attendance = ref.watch(attendanceProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Teacher Dashboard')),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // Subject selector
//             Row(
//               children: [
//                 Text('Subject: '),
//                 Expanded(
//                   child: DropdownButton<Subject>(
//                     isExpanded: true,
//                     value: selectedSubject,
//                     hint: const Text('Select subject'),
//                     items: subjects
//                         .map(
//                           (s) => DropdownMenuItem(
//                             value: s,
//                             child: Text('${s.courseName} (${s.code})'),
//                           ),
//                         )
//                         .toList(),
//                     onChanged: (s) {
//                       if (s != null) _openSubjectDetails(s);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: selectedSubject == null
//                       ? null
//                       : () => _startTakeAttendance(selectedSubject!),
//                   child: const Text('Take Attendance'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Course rows (quick overview)
//             Expanded(
//               child: ListView.separated(
//                 itemCount: subjects.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 8),
//                 itemBuilder: (ctx, idx) {
//                   final s = subjects[idx];
//                   // compute attendance summary from provider
//                   final records = attendance
//                       .where((r) => r.subjectCode == s.code)
//                       .toList();
//                   final total = records.length;
//                   final present = records.where((r) => r.present).length;
//                   final percent = total == 0 ? 0.0 : (present / total) * 100.0;

//                   return Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       title: Text('${s.courseName} • ${s.code}'),
//                       // subtitle: Text('${s.programme} • Sem ${s.semester}'),
//                       trailing: SizedBox(
//                         width: 220,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   'Attendance: ${percent.toStringAsFixed(1)}%',
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: () => _openSubjectDetails(s),
//                                       child: const Text('Details'),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     ElevatedButton(
//                                       onPressed: () => _startTakeAttendance(s),
//                                       child: const Text('Take'),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Bottom sheet for subject details
// class SubjectDetailsSheet extends ConsumerWidget {
//   final Subject subject;
//   const SubjectDetailsSheet({super.key, required this.subject});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final students = ref.watch(studentsProvider);
//     final attendance = ref.watch(attendanceProvider);

//     // build attendance stats by student
//     final Map<String, List<AttendanceRecord>> byStudent = {};
//     for (final a in attendance.where((e) => e.subjectCode == subject.code)) {
//       byStudent.putIfAbsent(a.studentId, () => []).add(a);
//     }

//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.8,
//       maxChildSize: 0.98,
//       builder: (ctx, sc) {
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             color: Colors.white,
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '${subject.courseName} • ${subject.code}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () async {
//                       // export CSV (server recommended)
//                       final resp = await TeacherService.downloadAttendanceCsv(
//                         subject.code,
//                       );
//                       if (resp != null) {
//                         // Save or open response.bodyBytes in real app
//                         toastification.show(
//                           type: ToastificationType.success,
//                           context: context,
//                           title: const Text('Downloaded CSV (simulate)'),
//                         );
//                       } else {
//                         toastification.show(
//                           type: ToastificationType.error,
//                           context: context,
//                           title: const Text('Export failed'),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.download),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Filters
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: const InputDecoration(
//                         labelText: 'Semester',
//                         border: OutlineInputBorder(),
//                       ),
//                       onFieldSubmitted: (v) async {
//                         await ref
//                             .read(studentsProvider.notifier)
//                             .loadForSubject(subject.code, semester: v);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: const InputDecoration(
//                         labelText: 'Programme',
//                         border: OutlineInputBorder(),
//                       ),
//                       onFieldSubmitted: (v) async {
//                         await ref
//                             .read(studentsProvider.notifier)
//                             .loadForSubject(subject.code, programme: v);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Student list with attendance percent
//               Expanded(
//                 child: ListView.separated(
//                   controller: sc,
//                   itemCount: students.length,
//                   separatorBuilder: (_, __) => const Divider(),
//                   itemBuilder: (ctx, idx) {
//                     final st = students[idx];
//                     final recs = byStudent[st.id] ?? [];
//                     final total = recs.length;
//                     final present = recs.where((r) => r.present).length;
//                     final percent = total == 0
//                         ? 0.0
//                         : (present / total) * 100.0;
//                     final color = percent >= 75.0 ? Colors.green : Colors.red;

//                     return ListTile(
//                       title: Text('${st.name} • ${st.roll}'),
//                       subtitle: Text('$st.email'),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '${percent.toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               color: color,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           PopupMenuButton<String>(
//                             onSelected: (v) async {
//                               if (v == 'enroll') {
//                                 final ok = await ref
//                                     .read(studentsProvider.notifier)
//                                     .enroll(subject.code, st.id);
//                                 toastification.show(
//                                   type: ok
//                                       ? ToastificationType.success
//                                       : ToastificationType.error,
//                                   context: context,
//                                   title: Text(
//                                     ok ? 'Enrolled' : 'Enroll failed',
//                                   ),
//                                 );
//                               } else if (v == 'unenroll') {
//                                 final ok = await ref
//                                     .read(studentsProvider.notifier)
//                                     .unenroll(subject.code, st.id);
//                                 toastification.show(
//                                   type: ok
//                                       ? ToastificationType.success
//                                       : ToastificationType.error,
//                                   context: context,
//                                   title: Text(
//                                     ok ? 'Unenrolled' : 'Unenroll failed',
//                                   ),
//                                 );
//                               } else if (v == 'edit') {
//                                 showDialog(
//                                   context: context,
//                                   builder: (_) => AlertDialog(
//                                     title: const Text('Edit attendance'),
//                                     content: const Text('TODO: edit UI'),
//                                   ),
//                                 );
//                               }
//                             },
//                             itemBuilder: (_) => [
//                               const PopupMenuItem(
//                                 value: 'enroll',
//                                 child: Text('Enroll'),
//                               ),
//                               const PopupMenuItem(
//                                 value: 'unenroll',
//                                 child: Text('Unenroll'),
//                               ),
//                               const PopupMenuItem(
//                                 value: 'edit',
//                                 child: Text('Edit attendance'),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
