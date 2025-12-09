

import 'dart:convert';

import 'package:classqr/core/config/env.dart';
import 'package:classqr/views/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

void showNewPasswordDialog(BuildContext context, String email) {
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  final formKey = GlobalKey<FormState>();

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

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reset Password",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newPass,
                obscureText: true,
                validator: validatePasswordField,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: confirmPass,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Confirm password must be filled.";
                  }
                  if (v != newPass.text) return "Passwords do not match";
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              if (newPass.text != confirmPass.text) {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  alignment: Alignment.topCenter,
                  context: context,
                  title: Text("Passwords do not match"),
                  autoCloseDuration: const Duration(seconds: 5),
                );
                return;
              }

              bool ok = await resetPassword(email, newPass.text.trim());

              if (ok) {
                Navigator.pop(context); // close new password dialog
                toastification.show(
                  type: ToastificationType.success,
                  style: ToastificationStyle.flat,
                  alignment: Alignment.topCenter,
                  context: context,
                  title: Text("Your password is updated now."),
                  autoCloseDuration: const Duration(seconds: 5),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              } else {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  alignment: Alignment.topCenter,
                  context: context,
                  title: Text("Failed to update password."),
                  autoCloseDuration: const Duration(seconds: 5),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}

Future<bool> resetPassword(String email, String newPassword) async {
  final url = Uri.parse("${Env.apiBaseUrl}/api/auth/reset-password");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "new_password": newPassword}),
  );
  return response.statusCode == 200;
}
