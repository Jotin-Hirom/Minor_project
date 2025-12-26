import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../services/auth_services.dart';
import '../../../components/otpDialog.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!v.endsWith('@tezu.ac.in') && !v.endsWith('@tezu.ernet.in')) {
      return 'Use registered Tezpur email';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!formKey.currentState!.validate()) return;
    final res = await AuthService.sendForgotOtp(
      emailController.text.trim().toLowerCase(),
    );
    final status = res['status'] as int? ?? 0;
    if (status == 200 || status == 201) {
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        context: context,
        title: const Text('OTP sent'),
        autoCloseDuration: const Duration(seconds: 3),
      );
      showOtpDialog(
        context,
        emailController.text.trim().toLowerCase(),
        'forgotPassword',
      );
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
        title: const Text('Failed to send OTP'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Enter your registered Tezpur University email address and we will send you an OTP to reset your password.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  validator: validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    onPressed: _sendOtp,
                    child: const Text(
                      'Send OTP',
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
