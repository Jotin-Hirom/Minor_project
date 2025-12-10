import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:toastification/toastification.dart';

import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_services.dart';

/// Riverpod provider MUST be outside the widget class
final selectedRoleProvider = StateProvider<String>((ref) => 'Student'); 

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // VALIDATE EMAIL
  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";

    final emailChecked = v.trim();
    final studentRegex = RegExp(r'^[a-zA-Z]{3}[0-9]{5}@tezu\.ac\.in$');
    final teacherRegex = RegExp(r'^[a-zA-Z]{3,}@tezu\.ernet\.in$');

    if (studentRegex.hasMatch(emailChecked)) return null;
    if (teacherRegex.hasMatch(emailChecked)) return null;

    return "Enter a valid Student or Teacher email";
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";

    final pw = value.trim();
    if (pw.length < 6) return "Password must be at least 6 characters long";
    if (RegExp(r'[A-Za-z]').allMatches(pw).length < 2) {
      return "Password must contain at least 2 letters";
    }
    if (RegExp(r'\d').allMatches(pw).length < 3) {
      return "Password must contain at least 3 numbers";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>_\-+=]').hasMatch(pw)) {
      return "Password must contain at least 1 special character";
    }
    return null;
  }

  Future<void> onSubmit() async {
    final selectedRole = ref.read(selectedRoleProvider);

    if (!_formKey.currentState!.validate()) return;

    final res = await AuthService.login(
      selectedRole.toLowerCase(),
      emailController.text.trim().toLowerCase(),
      passwordController.text.trim(),
    );

    final status = res['status'] as int? ?? 0;
    final data = res['data'] as Map<String, dynamic>?;

    if (status == 200 && data?['success'] == true) {
      final token = data!['accessToken'];
      final user = User.fromJson(data['user']);

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        context: context,
        title: const Text('Signed in successfully.'),
        autoCloseDuration: const Duration(seconds: 3),
      );
      await ref
          .read(authStateProvider.notifier)
          .login(user.role ?? selectedRole.toLowerCase(), user, token);
    } else if (status == 503) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        context: context,
        title: const Text("Server error."),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        context: context,
        title: const Text('Sign in failed'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = ref.watch(selectedRoleProvider);

    InputDecoration fieldStyle(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

    return Center(
      child: SingleChildScrollView(
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign in for login',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 14),

                // ------------------- FIXED DROPDOWN -------------------
                DropdownButtonFormField<String>(
                  initialValue: selectedRole, // correct binding
                  decoration: fieldStyle('Select Role'),
                  items: ['Admin', 'Student', 'Teacher']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) =>
                      ref.read(selectedRoleProvider.notifier).state =
                          v ?? 'Student',
                ),

                const SizedBox(height: 12),
                const Text('Email'),
                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  validator: validateEmail,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: '@tezu.ac.in or @tezu.ernet.in',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Password'),
                const SizedBox(height: 8),

                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  validator: validatePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Enter your password',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onSubmit,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
