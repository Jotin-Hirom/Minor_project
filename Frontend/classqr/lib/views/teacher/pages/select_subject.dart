import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

import '../../../core/config/env.dart';
import '../../../models/subject.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/teacher_selected_subject.dart';

class SelectSubjectsPage extends ConsumerStatefulWidget {
  const SelectSubjectsPage({super.key});

  @override
  ConsumerState<SelectSubjectsPage> createState() => _SelectSubjectsPageState();
}

class _SelectSubjectsPageState extends ConsumerState<SelectSubjectsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subCodeController = TextEditingController();
  final TextEditingController _subNameController = TextEditingController();
  bool _isCreating = false;

  String searchQuery = "";
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _subCodeController.dispose();
    _subNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce: wait 250ms after user stops typing
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        searchQuery = value.toLowerCase();
      });
    });
  }

  Future<void> createSubject() async {
    final auth = ref.read(authStateProvider);
    final subjects = ref.watch(teacherSelectedSubjectsProvider);
    // For now, just log and show an informational toast; implement POST logic later.
    try {
      print('role: ${auth.role}');
      print('selected subjects: ${subjects.map((s) => s.code).toList()}');

      toastification.show(
        type: ToastificationType.info,
        context: context,
        alignment: Alignment.topCenter,
        title: const Text("Create subject not implemented"),
        autoCloseDuration: const Duration(seconds: 3),
      );

      // Close the dialog if it was opened
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      _error("Something went wrong: $e");
    }
  }

  void _error(String msg) {
    toastification.show(
      type: ToastificationType.error,
      context: context,
      alignment: Alignment.topCenter,
      title: Text(msg),
    );
  }

  void _openCreateSubjectDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Subject"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subCodeController,
                decoration: const InputDecoration(labelText: "Subject Code"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subNameController,
                decoration: const InputDecoration(labelText: "Subject Name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(onPressed: createSubject, child: const Text("Create")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;
    if (user == null) {
      return const Center(child: Text("User not authenticated"));
    }
    final selected = ref.watch(teacherSelectedSubjectsProvider);
    final sortMode = ref.watch(subjectSortProvider);
    final asyncSubjects = ref.watch(allSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ClassQR - Student Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Course",
            onPressed: _openCreateSubjectDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (v) => ref.read(subjectSortProvider.notifier).state = v,
            itemBuilder: (_) => const [
              PopupMenuItem(value: "A-Z", child: Text("Sort A → Z")),
              PopupMenuItem(value: "Z-A", child: Text("Sort Z → A")),
              PopupMenuItem(value: "CODE", child: Text("Sort by Code")),
            ],
          ),
        ],
      ),

      body: asyncSubjects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading subjects")),
        data: (subjects) {
          // ---------- FILTER ----------
          List<Course> filtered = subjects.where((s) {
            if (searchQuery.isEmpty) return true;
            return s.code.toLowerCase().contains(searchQuery) ||
                s.courseName.toLowerCase().contains(searchQuery);
          }).toList();

          // ---------- SORT ----------
          if (sortMode == "A-Z") {
            filtered.sort((a, b) => a.courseName.compareTo(b.courseName));
          } else if (sortMode == "Z-A") {
            filtered.sort((a, b) => b.courseName.compareTo(a.courseName));
          } else {
            filtered.sort((a, b) => a.code.compareTo(b.code));
          }

          return Column(
            children: [
              // ---------- SEARCH BAR ----------
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search by name or code...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // ---------- SELECTED SUBJECTS (CHIPS) ----------
              if (selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 6,
                    children: selected.map((s) {
                      return Chip(
                        label: Text(s.code),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => ref
                            .read(teacherSelectedSubjectsProvider.notifier)
                            .toggle(s),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 10),

              // ---------- FAST LIST ----------
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    final isSelected = selected.any((x) => x.code == s.code);

                    return ListTile(
                      dense: true,
                      title: Text(
                        "${s.code} - ${s.courseName}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.indigo : Colors.grey,
                      ),
                      onTap: () {
                        ref
                            .read(teacherSelectedSubjectsProvider.notifier)
                            .toggle(s);
                      },
                    );
                  },
                ),
              ),

              // ---------- CONTINUE ----------
              SizedBox(
                width: 120, // your desired width
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // required for strict width
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    createSubject();

                    // toastification.show(
                    //   type: ToastificationType.success,
                    //   style: ToastificationStyle.flat,
                    //   alignment: Alignment.topCenter,
                    //   context: context,
                    //   title: const Text("Subjects Created"),
                    //   autoCloseDuration: const Duration(seconds: 5),
                    // );
                    // context.go("/teacher");
                  },
                  child: const Text("Create", textAlign: TextAlign.center),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
