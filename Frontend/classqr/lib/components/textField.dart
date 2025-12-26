import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? prefixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}


// // ignore_for_file: file_names

// import 'package:flutter/material.dart';
// import 'package:classqr/views/auth/components/inputField.dart';

// Widget field(
//   TextEditingController controller,
//   String label,
//   String? Function(String?) validator, {
//   bool obscure = false,
//   TextInputType keyboard = TextInputType.text,
// }) {
//   return TextFormField(
//     controller: controller,
//     obscureText: obscure,
//     keyboardType: keyboard,
//     validator: validator,
//     decoration: fieldStyle(label),
//   );
// }
 