import 'package:classqr/models/app_user.dart';
import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  final User? user;
  const TeacherDashboard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'unknown';
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: Center(child: Text('Teacher: $email')),
    );
  }
}

























// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:classqr/core/config/env.dart';

// class TeacherDashboard extends StatefulWidget {
//   const TeacherDashboard({super.key});

//   @override
//   State<TeacherDashboard> createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends State<TeacherDashboard> {
//   late String _token;
//   Map<String, dynamic>? _teacherProfile;
//   List<dynamic>? _courses;
//   Map<String, dynamic>? _attendanceOverview;
//   final bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     // _loadData();
//   }

//   // Future<void> _loadData() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     _token = prefs.getString('token') ?? '';

//   //     if (_token.isEmpty) {
//   //       setState(() {
//   //         _error = 'No authentication token found. Please log in.';
//   //         _isLoading = false;
//   //       });
//   //       return;
//   //     }

//   //     await Future.wait([
//   //       _fetchTeacherProfile(),
//   //       _fetchCourses(),
//   //       _fetchAttendanceOverview(),
//   //     ]);

//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       _error = 'Failed to load data: $e';
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _fetchTeacherProfile() async {
//     final response = await http.get(
//       Uri.parse('${Env.apiBaseUrl}/teacher/profile'),
//       headers: {'Authorization': 'Bearer $_token'},
//     );

//     if (response.statusCode == 200) {
//       _teacherProfile = json.decode(response.body);
//     } else {
//       throw Exception('Failed to load profile');
//     }
//   }

//   Future<void> _fetchCourses() async {
//     final response = await http.get(
//       Uri.parse('${Env.apiBaseUrl}/teacher/courses'),
//       headers: {'Authorization': 'Bearer $_token'},
//     );

//     if (response.statusCode == 200) {
//       _courses = json.decode(response.body);
//     } else {
//       throw Exception('Failed to load courses');
//     }
//   }

//   Future<void> _fetchAttendanceOverview() async {
//     final response = await http.get(
//       Uri.parse('${Env.apiBaseUrl}/teacher/attendance/overview'),
//       headers: {'Authorization': 'Bearer $_token'},
//     );

//     if (response.statusCode == 200) {
//       _attendanceOverview = json.decode(response.body);
//     } else {
//       throw Exception('Failed to load attendance overview');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_error != null) {
//       return Scaffold(body: Center(child: Text(_error!)));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Teacher Dashboard'),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             // Welcome Card
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Welcome, ${_teacherProfile?['name'] ?? 'Teacher'}!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Email: ${_teacherProfile?['email'] ?? ''}'),
//                     Text('Teacher ID: ${_teacherProfile?['teacherId'] ?? ''}'),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Attendance Overview Card
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Attendance Overview',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Total Classes: ${_attendanceOverview?['totalClasses'] ?? 0}',
//                     ),
//                     Text(
//                       'Average Attendance: ${_attendanceOverview?['averageAttendance']?.toStringAsFixed(2) ?? '0.00'}%',
//                     ),
//                     Text(
//                       'Students: ${_attendanceOverview?['totalStudents'] ?? 0}',
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Courses Taught
//             const Text(
//               'Courses Taught',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             if (_courses != null && _courses!.isNotEmpty)
//               ..._courses!.map(
//                 (course) => Card(
//                   elevation: 2,
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   child: ListTile(
//                     title: Text(course['name'] ?? 'Course Name'),
//                     subtitle: Text('Code: ${course['code'] ?? ''}'),
//                     trailing: Text(
//                       '${course['enrolledStudents'] ?? 0} students',
//                     ),
//                   ),
//                 ),
//               )
//             else
//               const Text('No courses assigned.'),

//             const SizedBox(height: 16),

//             // Generate QR Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement QR generation functionality
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('QR Generation feature coming soon!'),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.indigo,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Generate QR for Attendance'),
//             ),
//             const SizedBox(height: 8),

//             // View Reports Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Navigate to reports page
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Reports feature coming soon!')),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('View Attendance Reports'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
