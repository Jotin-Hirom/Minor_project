// views/auth/components/inputField.dart
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final Widget? prefix;
  final TextEditingController controller;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.hint,
    required this.controller,
    this.prefix,
    this.obscure = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}