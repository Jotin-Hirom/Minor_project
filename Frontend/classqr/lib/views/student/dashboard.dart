import 'dart:convert';
import 'package:classqr/constant/console.dart';
import 'package:classqr/models/app_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import '../../core/config/env.dart';
import '../../providers/auth_provider.dart';
import 'pages/pages.dart';

class StudentDashboard extends ConsumerWidget {
  final String? token;
  final User? user;

  const StudentDashboard({super.key, this.token, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    log(token.toString());

    final user = auth.user;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("Student Dashboard"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.subject), text: 'Subjects'),
              Tab(icon: Icon(Icons.check_circle), text: 'Attendance'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse('${Env.apiBaseUrl}/api/auth/logout');
                dynamic response;
                try {
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
                color: CupertinoColors.systemRed, // Or any other color
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ProfileTab(user: user),
            SubjectsTab(),
            AttendanceTab(),
          ],
        ),
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:classqr/core/config/env.dart';
// import 'package:classqr/models/app_user.dart';
// import 'package:classqr/views/auth/auth_page.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart'; 
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:table_calendar/table_calendar.dart';
// import 'package:toastification/toastification.dart';

// class StudentDashboard extends StatefulWidget {
//   final String token;
//   final User? user;

//   const StudentDashboard({super.key, required this.token, required this.user});

//   @override 
//   State<StudentDashboard> createState() => _StudentDashboardState();
// }

// class _StudentDashboardState extends State<StudentDashboard> {
//   Map<String, dynamic>? _studentProfile;
//   List<dynamic>? _courses;
//   Map<String, dynamic>? _attendanceSummary;

//   bool _isLoading = false;
//   String? _error;
//   String? _token;

//   @override 
//   void initState() {
//     super.initState();

//     // Use the token passed from the previous screen
//     _token = widget.token;

//     // Redirect if no token
//     if (widget.token.isEmpty) {
//       Future.microtask(() {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const AuthPage()),
//         );
//       });
//     }

//     // If you want to load data from API, uncomment:
//     // _isLoading = true;
//     // _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _token = prefs.getString('accessToken') ?? '';

//       if (_token == null || _token!.isEmpty) {
//         setState(() {
//           _error = 'No authentication token found. Please log in.';
//           _isLoading = false;
//         });
//         return;
//       }

//       // await Future.wait([
//       //   _fetchStudentProfile(),
//       //   _fetchCourses(),
//       //   _fetchAttendanceSummary(),
//       // ]);

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   // Future<void> _fetchStudentProfile() async {
//   //   final response = await http.get(
//   //     Uri.parse('${Env.apiBaseUrl}/student/profile'),
//   //     headers: {'Authorization': 'Bearer $_token'},
//   //   );
//   //   if (response.statusCode == 200) {
//   //     _studentProfile = json.decode(response.body);
//   //   } else {
//   //     throw Exception('Failed to load profile');
//   //   }
//   // }

//   // Future<void> _fetchCourses() async {
//   //   final response = await http.get(
//   //     Uri.parse('${Env.apiBaseUrl}/student/courses'),
//   //     headers: {'Authorization': 'Bearer $_token'},
//   //   );
//   //   if (response.statusCode == 200) {
//   //     _courses = json.decode(response.body);
//   //   } else {
//   //     throw Exception('Failed to load courses');
//   //   }
//   // }

//   // Future<void> _fetchAttendanceSummary() async {
//   //   final response = await http.get(
//   //     Uri.parse('${Env.apiBaseUrl}/student/attendance/summary'),
//   //     headers: {'Authorization': 'Bearer $_token'},
//   //   );
//   //   if (response.statusCode == 200) {
//   //     _attendanceSummary = json.decode(response.body);
//   //   } else {
//   //     throw Exception('Failed to load attendance summary');
//   //   }
//   // }
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_error != null) {
//       return Scaffold(body: Center(child: Text(_error!)));
//     }

//     return DefaultTabController(
//       length: 3,
//       child: Builder(
//         builder: (context) {
//           return Scaffold(
//             // drawer: _buildDrawer(tabController),
//             appBar: AppBar(
//               title: const Text('Student Dashboard'),
//               backgroundColor: Colors.indigo,
//               foregroundColor: Colors.white,
//               automaticallyImplyLeading: true,
//               bottom: const TabBar(
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.black,
//                 tabs: [
//                   Tab(icon: Icon(Icons.person), text: 'Profile'),
//                   Tab(icon: Icon(Icons.subject), text: 'Subjects'),
//                   Tab(icon: Icon(Icons.check_circle), text: 'Attendance'),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () async {
//                     final url = Uri.parse('${Env.apiBaseUrl}/api/auth/logout');
//                     final response = await http.post(
//                       url,
//                       headers: {
//                         "Authorization": "Bearer ${_token ?? ''}",
//                         "Content-Type": "application/json",
//                       },
//                       body: jsonEncode({
//                         "email": widget.user?.email.toUpperCase(),
//                       }),
//                     );

//                     if (response.statusCode == 200) {
//                       toastification.show(
//                         type: ToastificationType.success,
//                         style: ToastificationStyle.flat,
//                         alignment: Alignment.topCenter,
//                         context: context,
//                         title: const Text("Logout successfully."),
//                         autoCloseDuration: const Duration(seconds: 5),
//                       );

//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const AuthPage()),
//                       );
//                     } else {
//                       toastification.show(
//                         type: ToastificationType.error,
//                         style: ToastificationStyle.flat,
//                         alignment: Alignment.topCenter,
//                         context: context,
//                         title: const Text("Can't logout."),
//                         autoCloseDuration: const Duration(seconds: 5),
//                       );
//                     }
//                   },
//                   child: const Text(
//                     'Logout',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             body: TabBarView(
//               children: [
//                 _buildProfileTab(),
//                 _buildSubjectsTab(),
//                 _buildAttendanceTab(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ---------------- TABS ----------------

//   Widget _buildProfileTab() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // Welcome Card
//         Card(
//           elevation: 4,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome, ${_studentProfile?['name'] ?? 'Student'}!',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text('Email: ${_studentProfile?['email'] ?? ''}'),
//                 Text('Student ID: ${_studentProfile?['studentId'] ?? ''}'),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         TableCalendar(
//           firstDay: DateTime.utc(2010, 10, 16), //strat date of the semester
//           lastDay: DateTime.now(),
//           focusedDay: DateTime.now(),
//         ),
//         const SizedBox(height: 16),

//         // Basic user info coming from JWT user map
//         Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Account Info',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("ID: ${widget.token.toUpperCase()}"),
//                 Text("ID: ${widget.user?.id.toUpperCase()}"),
//                 Text("Email: ${widget.user?.email.toUpperCase()}"),
//                 Text("Role: ${widget.user!.role!.toUpperCase()}"),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubjectsTab() {
//     if (_courses != null && _courses!.isNotEmpty) {
//       return ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _courses!.length + 1,
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return const Padding(
//               padding: EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Enrolled Courses',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             );
//           }

//           final course = _courses![index - 1];
//           return Card(
//             elevation: 2,
//             margin: const EdgeInsets.symmetric(vertical: 4),
//             child: ListTile(
//               title: Text(course['name'] ?? 'Course Name'),
//               subtitle: Text('Code: ${course['code'] ?? ''}'),
//               trailing: Text(course['teacher'] ?? ''),
//             ),
//           );
//         },
//       );
//     } else {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Align(
//           alignment: Alignment.topLeft,
//           child: Text('No courses enrolled.', style: TextStyle(fontSize: 16)),
//         ),
//       );
//     }
//   }

//   Widget _buildAttendanceTab() {
//     final totalClasses = _attendanceSummary?['totalClasses'] ?? 0;
//     final attended = _attendanceSummary?['attended'] ?? 0;
//     final percentageNum = (_attendanceSummary?['percentage'] as num?) ?? 0.0;
//     final percentage = percentageNum.toStringAsFixed(2);

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Card(
//           elevation: 4,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Attendance Summary',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text('Total Classes: $totalClasses'),
//                 Text('Attended: $attended'),
//                 Text('Percentage: $percentage%'),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),

//         // QR Scan / placeholder
//         ElevatedButton(
//           onPressed: () async {
//             String? result;
//             await showDialog(
//               context: context,
//               barrierDismissible: true,
//               builder: (dialogContext) {
//                 return AlertDialog(
//                   title: const Text('Scan QR for Attendance'),
//                   contentPadding: const EdgeInsets.all(8),
//                   content: SizedBox(
//                     width: 400,
//                     height: 400,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Center(
//                         child: QrImageView(
//                           data: "data",
//                           version: QrVersions.auto,
//                           size: 240,
//                           gapless: true,
//                         ),
//                       ),
//                     ),
//                     // FlutterWebQrcodeScanner(
//                     //   cameraDirection: CameraDirection.back,
//                     //   stopOnFirstResult: true,
//                     //   onGetResult: (value) {
//                     //     result = value;
//                     //     Navigator.of(dialogContext).pop(); // close dialog
//                     //   },
//                     // ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(dialogContext).pop(); // cancel
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 );
//               },
//             );
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.indigo,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             minimumSize: const Size(double.infinity, 50),
//           ),
//           child: const Text('Scan QR for Attendance'),
//         ),
//       ],
//     );
//   }
// }
