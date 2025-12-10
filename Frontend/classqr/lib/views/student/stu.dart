// lib/pages/student_dashboard.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';



class StudentDash extends StatefulWidget {
  final Student student;

  const StudentDash({super.key, required this.student});

  @override
  State<StudentDash> createState() => _StudentDashState();
}

class _StudentDashState extends State<StudentDash> {
  List<Subject> allSubjects = [];
  bool loadingSubjects = true;
  int selectedTab = 0; // 0=student,1=subject,2=attendance
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      // NOTE: file path must match pubspec.yaml: assets/subjects.json
      final raw = await rootBundle.loadString('assets/subjects.json');
      final Map<String, dynamic> j = json.decode(raw);
      final arr = j['subjects'] as List<dynamic>;
      setState(() {
        allSubjects = arr
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList();
        loadingSubjects = false;
      });
    } catch (e) {
      setState(() => loadingSubjects = false);
      debugPrint("Error loading subjects: $e");
    }
  }

  Future<void> _showImageOptionsAndSave() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context, ''),
              ),
            ],
          ),
        );
      },
    );

    if (choice == null || choice.isEmpty) return;

    final source = choice == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return; // user cancelled

      // Save path to SharedPreferences for this user
      await _savePhotoForCurrentUser(picked.path);

      // Update local Student object and UI
      setState(() {
        widget.student.photoUrl = picked.path;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (e) {
      debugPrint('Image pick error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not pick image')));
    }
  }

  Future<void> _savePhotoForCurrentUser(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('users') ?? '[]';
      final List users = json.decode(raw) as List;

      final idx = users.indexWhere(
        (u) =>
            (u['email'] as String).toLowerCase() ==
            widget.student.email.toLowerCase(),
      );
      if (idx == -1) return;

      final Map<String, dynamic> userMap = Map<String, dynamic>.from(
        users[idx] as Map,
      );
      userMap['photoUrl'] = path;
      users[idx] = userMap;
      await prefs.setString('users', json.encode(users));
    } catch (e) {
      debugPrint('Error saving photo path to prefs: $e');
    }
  }

  void _openSubjectPicker() async {
    final picked = await showModalBottomSheet<Subject>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          SubjectPicker(allSubjects, widget.student.selectedSubjects),
    );

    if (picked != null) {
      setState(() {
        widget.student.selectedSubjects.add(picked);
      });
      // persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('users') ?? '[]';
      final List users = json.decode(raw) as List;
      final idx = users.indexWhere(
        (u) =>
            (u['email'] as String).toLowerCase() ==
            widget.student.email.toLowerCase(),
      );
      if (idx != -1) {
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(
          users[idx] as Map,
        );
        userMap['selectedSubjects'] = widget.student.selectedSubjects
            .map((s) => s.toJson())
            .toList();
        users[idx] = userMap;
        await prefs.setString('users', json.encode(users));
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${picked.code} added")));
    }
  }

  // placeholder scan — integrate geolocation + QR scanner later
  void _scanAttendanceFor(Subject subject) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scan Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start QR + location flow for ${subject.code} (not implemented here).',
            ),
            const SizedBox(height: 8),
            const Text('Will check distance <= 5 meters before confirming.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Attendance recorded for ${subject.code} (simulated)',
                  ),
                ),
              );
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(Subject subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Attendance — ${subject.code}'),
        content: SizedBox(
          height: 140,
          child: Column(
            children: [
              const Text('Attendance summary (placeholder)'),
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: const CircularProgressIndicator(
                      value: 0.78,
                      strokeWidth: 12,
                    ),
                  ),
                  const Text(
                    '78%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget topBar() {
    ImageProvider? avatarImage;
    if (widget.student.photoUrl.isNotEmpty) {
      try {
        final f = File(widget.student.photoUrl);
        if (f.existsSync()) avatarImage = FileImage(f);
      } catch (_) {
        avatarImage = null;
      }
    }

    return Container(
      color: Colors.indigo,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'ClassQR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            widget.student.name,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showImageOptionsAndSave,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: avatarImage,
              child: avatarImage == null ? const Icon(Icons.person) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionCard(String title, int index) {
    final active = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(
                index == 0
                    ? Icons.person
                    : index == 1
                    ? Icons.book
                    : Icons.check_circle_outline,
                color: Colors.indigo,
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget studentDetailsView() {
    final s = widget.student;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Name: ${s.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showImageOptionsAndSave,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Roll: ${s.roll}'),
          const SizedBox(height: 8),
          Text('Email: ${s.email}'),
          const SizedBox(height: 8),
          Text('Programme: ${s.programme}'),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            children: [
              const Text(
                'Selected subjects:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openSubjectPicker,
                icon: const Icon(Icons.add),
                label: const Text('Add Subject'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (s.selectedSubjects.isEmpty)
            const Text('No subjects selected yet.')
          else
            Column(
              children: s.selectedSubjects
                  .map(
                    (sub) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${sub.code} — ${sub.courseName}'),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget subjectDetailsView() {
    final s = widget.student;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subjects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (s.selectedSubjects.isEmpty)
            const Text(
              'No subjects added. Click Add Subject in Student Details tab.',
            )
          else
            Column(
              children: s.selectedSubjects
                  .map(
                    (sub) => Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text('${sub.code} — ${sub.courseName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _showAttendanceDetails(sub),
                              child: const Text('Details'),
                            ),
                            ElevatedButton(
                              onPressed: () => _scanAttendanceFor(sub),
                              child: const Text('Scan Attendance'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget attendanceView() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (widget.student.selectedSubjects.isEmpty)
            const Text('No attendance records yet (no subjects).')
          else
            Column(
              children: widget.student.selectedSubjects
                  .map(
                    (sub) => ListTile(
                      title: Text('${sub.code} — ${sub.courseName}'),
                      subtitle: const Text('Present: 12  |  Absent: 3'),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar custom
      body: Column(
        children: [
          topBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: loadingSubjects
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Row(
                          children: [
                            actionCard('Student Details', 0),
                            actionCard('Subject Details', 1),
                            actionCard('Attendance Details', 2),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: selectedTab == 0
                                ? studentDetailsView()
                                : selectedTab == 1
                                ? subjectDetailsView()
                                : attendanceView(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet widget for picking/searching subjects
class SubjectPicker extends StatefulWidget {
  final List<Subject> all;
  final List<Subject> alreadyAdded;
  const SubjectPicker(this.all, this.alreadyAdded, {super.key});

  @override
  State<SubjectPicker> createState() => _SubjectPickerState();
}

class _SubjectPickerState extends State<SubjectPicker> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final available = widget.all
        .where((s) => !widget.alreadyAdded.any((a) => a.code == s.code))
        .toList();
    final filtered = query.isEmpty
        ? available
        : available
              .where(
                (s) =>
                    s.code.toLowerCase().contains(query.toLowerCase()) ||
                    s.courseName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add subject',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search subjects by code or name',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No subject matches'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final s = filtered[i];
                          return ListTile(
                            title: Text('${s.code} — ${s.courseName}'),
                            onTap: () => Navigator.pop(context, s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// Simple Student model for demo (in real app populate this from backend/auth)
class Student {
  String name;
  String roll;
  String email;
  String programme;
  String photoUrl; // can be network path or local asset
  List<Subject> selectedSubjects;

  Student({
    required this.name,
    required this.roll,
    required this.email,
    required this.programme,
    required this.photoUrl,
    List<Subject>? selectedSubjects,
  }) : selectedSubjects = selectedSubjects ?? [];
}

class Subject {
  final String code;
  final String courseName;

  Subject({required this.code, required this.courseName});

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
    code: j['code'] as String,
    courseName: j['course_name'] as String,
  );

  Map<String, dynamic> toJson() => {'code': code, 'course_name': courseName};
}
