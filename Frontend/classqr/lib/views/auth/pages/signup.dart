import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:toastification/toastification.dart';

import '../../../providers/dept_provider.dart';
import '../../../services/auth_services.dart';
import '../../../components/otpDialog.dart';
import '../../../components/programme_dropdown.dart';

final signupSelectedRoleProvider = StateProvider<String>((ref) => 'Student');

final studentFormKeyProvider = StateProvider<GlobalKey<FormState>>(
  (ref) => GlobalKey<FormState>(),
);

final teacherFormKeyProvider = StateProvider<GlobalKey<FormState>>(
  (ref) => GlobalKey<FormState>(),
);

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  // ---------------- STUDENT CONTROLLERS ----------------
  final name = TextEditingController();
  final roll = TextEditingController();
  final semester = TextEditingController();
  final programme = TextEditingController();
  final batch = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // ---------------- TEACHER CONTROLLERS ----------------
  final tName = TextEditingController();
  final tEmail = TextEditingController();
  final tPassword = TextEditingController();
  final tConfirmPassword = TextEditingController();

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return "Name is required";
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(v)) return "Only alphabets allowed";
    return null;
  }

  String? validateRoll(String? v) {
    if (v == null || v.isEmpty) return "Roll number is required";
    if (!RegExp(r'^[A-Za-z]{3}[0-9]{5}$').hasMatch(v)) {
      return "Format: ABC12345";
    }
    return null;
  }

  String? validateSemester(String? v) {
    if (v == null || v.trim().isEmpty) return "Semester is required";
    final s = int.tryParse(v.trim());
    if (s == null || s < 1 || s > 10) return "Semester must be between 1–10";
    return null;
  }

  String? validateProgramme(String? v) {
    if (v == null || v.isEmpty) return "Programme is required";
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(v)) return "Only alphabets allowed";
    return null;
  }

  String? validateBatch(String? v) {
    if (v == null || v.trim().isEmpty) return "Batch Year is required";
    final val = v.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(val)) {
      return "Enter valid year (e.g. 2023)";
    }
    return null;
  }

  String? validateStudentEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";

    if (!v.endsWith("@tezu.ac.in")) {
      return "Student email must end with @tezu.ac.in";
    }

    if (roll.text.isEmpty) return "Enter Roll Number first";

    final prefix = v.split("@")[0];

    if (prefix.toLowerCase() != roll.text.toLowerCase()) {
      return "Email prefix must match Roll Number";
    }

    if (!RegExp(r'^[A-Za-z]{3}[0-9]{5}$').hasMatch(prefix)) {
      return "Roll must be ABC12345";
    }

    return null;
  }

  String? validateTeacherEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";

    if (!v.endsWith("@tezu.ernet.in")) {
      return "Teacher email must end with @tezu.ernet.in";
    }

    final username = v.split("@")[0];

    if (!RegExp(r'^[A-Za-z][A-Za-z0-9._%+-]*$').hasMatch(username)) {
      return "Email must start with a letter and contain letters/numbers";
    }

    return null;
  }

  String? validateTeacherName(String? v) {
    if (v == null || v.isEmpty) return "Name is required";
    return null;
  }

  String? validateDesignation(String? v) {
    if (v == null || v.trim().isEmpty) return "Designation is required";
    return null;
  }

  String? validateSpecialization(String? v) {
    if (v == null || v.isEmpty) return "Specialization is required";
    return null;
  }

  String? validateDepartment(String? val) {
    if (val == null || val.isEmpty) return 'Please select a department';
    return null;
  }

  String? validatePasswordField(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    final regex = RegExp(
      r'^(?=(.*[A-Za-z]){4,})(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$',
    );
    if (!regex.hasMatch(v)) {
      return "Min 6 chars, 4 letters, 1 digit, 1 symbol";
    }
    return null;
  }

  String? validateConfirmPassword(String? v, TextEditingController ctrl) {
    if (v != ctrl.text) return "Passwords do not match";
    return null;
  }

  // Teacher designation
  String selectedDesignation = "Assistant Professor";

  @override
  void dispose() {
    name.dispose();
    roll.dispose();
    semester.dispose();
    programme.dispose();
    batch.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    tName.dispose();
    tEmail.dispose();
    tPassword.dispose();
    tConfirmPassword.dispose();
    super.dispose();
  }

  /// ------------------------------------------------------------
  /// ROLE CHANGE HANDLER
  /// ------------------------------------------------------------
  void onRoleChange(String role) {
    ref.read(signupSelectedRoleProvider.notifier).state = role;
    ref.read(studentFormKeyProvider.notifier).state = GlobalKey<FormState>();
    ref.read(teacherFormKeyProvider.notifier).state = GlobalKey<FormState>();
  }

  Future<void> submit() async {
    final role = ref.read(signupSelectedRoleProvider);
    final studentKey = ref.read(studentFormKeyProvider);
    final teacherKey = ref.read(teacherFormKeyProvider);

    if (role == "Student") {
      if (studentKey.currentState!.validate()) {
        final body = {
          'email': email.text.toLowerCase(),
          'password': password.text.trim(),
          'sname': name.text.toUpperCase(),
          'role': 'student',
          'roll_no': roll.text.trim(),
          'semester': semester.text.trim(),
          'programme': programme.text.toUpperCase(),
          'batch': batch.text.toUpperCase(),
          'photo_url': null,
        };

        final res = await AuthService.signup(body);
        final status = res['status'] as int? ?? 0;

        if (status == 200 || status == 201) {
          final emailToSend = email.text.toLowerCase();

          // Clear controllers
          name.clear();
          roll.clear();
          semester.clear();
          programme.clear();
          batch.clear();
          email.clear();
          password.clear();
          confirmPassword.clear();

          toastification.show(
            type: ToastificationType.success,
            context: context,
            alignment: Alignment.topCenter,
            title: const Text("Student Account created. Please verify email."),
          );

          showOtpDialog(context, emailToSend, "signupStudent");
        } else if (status == 408) {
          _error("Email already exists.");
        } else if (status == 409) {
          _error("Roll Number already exists.");
        } else if (status == 503) {
          _error("Server error.");
        } else {
          _error("Unable to sign in.");
        }
      }
    } else {
      if (teacherKey.currentState!.validate()) {
        final body = {
          'tname': tName.text.toUpperCase(),
          'designation': selectedDesignation.toUpperCase(),
          'dept': ref.read(selectedDepartmentProvider),
          'email': tEmail.text.toLowerCase(),
          'password': tPassword.text.trim(),
          'role': 'teacher',
          'photo_url': null,
        };

        final res = await AuthService.signup(body);
        final status = res['status'] as int? ?? 0;

        if (status == 200 || status == 201) {
          final emailToSend = tEmail.text.toLowerCase();

          tName.clear();
          tEmail.clear();
          tPassword.clear();
          tConfirmPassword.clear();

          toastification.show(
            type: ToastificationType.success,
            context: context,
            alignment: Alignment.topCenter,
            title: const Text(
              "Teacher Account created. Please verify your email.",
            ),
          );
          showOtpDialog(context, emailToSend, "signupTeacher");
        } else if (status == 409) {
          _error("Email already exists.");
        } else {
          _error("Unable to sign in.");
        }
      }
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

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(signupSelectedRoleProvider);
    final departments = ref.watch(departmentsProvider);
    final selectedDept = ref.watch(selectedDepartmentProvider);

    final studentKey = ref.watch(studentFormKeyProvider);
    final teacherKey = ref.watch(teacherFormKeyProvider);

    InputDecoration fieldStyle(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Register by signing up",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 14),

            /// ---------------- ROLE DROPDOWN ----------------
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: fieldStyle("Select Role"),
              items: const [
                DropdownMenuItem(value: "Student", child: Text("Student")),
                DropdownMenuItem(value: "Teacher", child: Text("Teacher")),
              ],
              onChanged: (v) => onRoleChange(v!),
            ),

            const SizedBox(height: 20),

            /// ---------------- FORM ----------------
            if (role == "Student")
              _studentForm(studentKey, fieldStyle)
            else
              _teacherForm(teacherKey, departments, selectedDept, fieldStyle),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: submit, // FIXED
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create $role Account",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- STUDENT FORM ----------------
  Widget _studentForm(
    GlobalKey<FormState> key,
    InputDecoration Function(String) fieldStyle,
  ) {
    return Form(
      key: key,
      child: Column(
        children: [
          field(name, "Full Name", validateName),
          const SizedBox(height: 12),
          field(roll, "Roll Number", validateRoll),
          const SizedBox(height: 12),
          field(
            semester,
            "Semester",
            validateSemester,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 12),
          ProgrammeDropdown(),
          const SizedBox(height: 12),
          field(
            batch,
            "Batch Year",
            validateBatch,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 12),
          field(email, "Email", validateStudentEmail),
          const SizedBox(height: 12),
          field(password, "Password", validatePasswordField, obscure: true),
          const SizedBox(height: 12),
          field(
            confirmPassword,
            "Confirm Password",
            (v) => validateConfirmPassword(v, password),
            obscure: true,
          ),
        ],
      ),
    );
  }

  /// ---------------- TEACHER FORM ----------------
  Widget _teacherForm(
    GlobalKey<FormState> key,
    List<String> departments,
    String? selectedDept,
    InputDecoration Function(String) fieldStyle,
  ) {
    return Form(
      key: key,
      child: Column(
        children: [
          field(tName, "Full Name", validateTeacherName),
          const SizedBox(height: 12),

          /// DESIGNATION
          DropdownButtonFormField<String>(
            initialValue: selectedDesignation,
            decoration: fieldStyle("Select Designation"),
            items: const [
              DropdownMenuItem(
                value: "Assistant Professor",
                child: Text("Assistant Professor"),
              ),
              DropdownMenuItem(
                value: "Associate Professor",
                child: Text("Associate Professor"),
              ),
              DropdownMenuItem(value: "Professor", child: Text("Professor")),
              DropdownMenuItem(value: "Lecturer", child: Text("Lecturer")),
              DropdownMenuItem(
                value: "Senior Lecturer",
                child: Text("Senior Lecturer"),
              ),
              DropdownMenuItem(
                value: "Visiting Faculty",
                child: Text("Visiting Faculty"),
              ),
            ],
            onChanged: (v) => setState(() => selectedDesignation = v!),
            validator: validateDesignation,
          ),

          const SizedBox(height: 12),

          /// DEPARTMENT
          DropdownButtonFormField<String>(
            initialValue: selectedDept,
            decoration: fieldStyle("Select Department"),
            items: departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) {
              ref.read(selectedDepartmentProvider.notifier).state = value;
            },
            validator: validateDepartment,
          ),

          const SizedBox(height: 12),

          field(tEmail, "Email", validateTeacherEmail),
          const SizedBox(height: 12),
          field(tPassword, "Password", validatePasswordField, obscure: true),
          const SizedBox(height: 12),
          field(
            tConfirmPassword,
            "Confirm Password",
            (v) => validateConfirmPassword(v, tPassword),
            obscure: true,
          ),
        ],
      ),
    );
  }

  /// ---------------- GENERIC TEXT FIELD BUILDER ----------------
  Widget field(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
