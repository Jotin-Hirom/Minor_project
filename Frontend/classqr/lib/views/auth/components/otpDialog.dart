import 'package:classqr/views/auth/components/passwordReset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../providers/otp_provider.dart';

Future<void> showOtpDialog(
  BuildContext parentContext, 
  String email, 
  String from,
) async {
  final otpControllers = List.generate(6, (_) => TextEditingController());

  void disposeControllers() {
    for (var c in otpControllers) {
      try {
        c.dispose();
      } catch (_) {}
    }
  }

  await showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          final otpState = ref.watch(otpProvider);
          final notifier = ref.read(otpProvider.notifier);
      
          // --------------------------- VERIFY ---------------------------
          Future<void> onVerify() async {
            final otp = otpControllers.map((c) => c.text).join();
      
            if (otp.length != 6) {
              toastification.show(
                type: ToastificationType.error,
                context: parentContext,
                 style: ToastificationStyle.flat,
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 5),
                title: const Text("Enter 6-digit OTP"),
              );
              return;
            }
      
            final ok = await notifier.verifyOTP(email, otp, from);
            if (!ok) {
              toastification.show(
                type: ToastificationType.error,
                context: parentContext,
                style: ToastificationStyle.flat,
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 5),
                title: Text(otpState.error ?? "OTP error"),
              );
              return;
            }
      
            // Close dialog safely
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
      
      
            toastification.show(
              type: ToastificationType.success,
              context: parentContext,
              style: ToastificationStyle.flat,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              title: const Text("OTP Verified"),
            );
      
            await Future.delayed(const Duration(milliseconds: 120));
            disposeControllers();
      
            // ---------------- After OTP success navigate using GoRouter ----------------
      
            if (!parentContext.mounted) return;
      
            if (from == "forgotPassword") {
              showNewPasswordDialog(parentContext, email);
            } else {
              parentContext.go('/auth');
            }
          }
      
          // --------------------------- RESEND ---------------------------
          Future<void> onResend() async {
            final ok = await notifier.resendOTP(email, from);
      
            toastification.show(
              type: ok
                  ? ToastificationType.success
                  : ToastificationType.error,
              context: parentContext,
              style: ToastificationStyle.flat,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              title: Text(ok ? "OTP Resent" : "Failed to resend"),
            );
          }
      
          // --------------------------- UI ---------------------------
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Text(
                (from == "signupStudent" || from == "signupTeacher")
                    ? "Verify your Account"
                    : "Reset your Password",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Enter the 6-digit OTP",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
      
                // OTP INPUT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: otpControllers[i],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            FocusScope.of(dialogContext).nextFocus();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
      
                const SizedBox(height: 14),
      
                // RESEND OTP
                TextButton(
                  onPressed: otpState.resending ? null : () => onResend(),
                  child: Text(
                    otpState.resending ? "Sending..." : "Resend OTP",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      
            actions: [
              // CANCEL
              TextButton(
                onPressed: () {
                  disposeControllers();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
      
              // VERIFY
              ElevatedButton(
                onPressed: otpState.verifying ? null : () => onVerify(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  otpState.verifying ? "Verifying..." : "Verify",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}



// import 'dart:convert';
// import 'package:classqr/views/auth/auth_page.dart';
// import 'package:classqr/views/auth/components/passwordReset.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:toastification/toastification.dart';
// import 'package:classqr/core/config/env.dart';

// void showOtpDialog(BuildContext context, String email, String from) {
//   List<TextEditingController> otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   ); 
  
//   // Reactive state instead of setState
//   final isResending = ValueNotifier<bool>(false);
//   final isVerifying = ValueNotifier<bool>(false);
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),

//             // ------------------ TITLE ------------------
//             title: Center(
//               child: Text(
//                 (from == "signStudent" || from == "signTeacher")
//                     ? "Verify your account"
//                     : "Reset your password",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 5),

//                 const Text(
//                   "Enter the valid OTP below",
//                   style: TextStyle(fontSize: 15, color: Colors.black54),
//                 ),

//                 const SizedBox(height: 20),

//                 // -------------------- OTP BOXES --------------------
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(6, (index) {
//                     return SizedBox(
//                       width: 45,
//                       height: 55,
//                       child: TextField(
//                         controller: otpControllers[index],
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),

//                         onChanged: (value) {
//                           if (value.isNotEmpty && index < 5) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                         },

//                         decoration: InputDecoration(
//                           counterText: "",
//                           filled: true,
//                           fillColor: Colors.grey.shade200,
//                           contentPadding: const EdgeInsets.all(
//                             0,
//                           ), // center digit
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),

//                 const SizedBox(height: 20),

//                 // -------------------- RESEND OTP --------------------
//                 TextButton(
//                   onPressed: () {
//                     // Call your backend to resend OTP
//                     resendOTP(email, from);
//                   },
//                   child: Text(
//                     "Resend OTP",
//                     style: TextStyle(
//                       color: Colors.deepPurple,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // -------------------- BUTTONS --------------------
//             actionsAlignment: MainAxisAlignment.spaceBetween,

//             actions: [
//               TextButton(
//                 onPressed: () {

//                   Navigator.pop(context);
//                 },
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//               ),

//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 25,
//                     vertical: 10,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () async {
//                   final otp = otpControllers.map((e) => e.text).join();

//                   bool ok = await verifyOTP(email, otp, from);
//                   if (ok) {
//                     toastification.show(
//                       type: ToastificationType.success,
//                       style: ToastificationStyle.flat,
//                       alignment: Alignment.topCenter,
//                       context: context,
//                       title: Text("OTP verified."),
//                       autoCloseDuration: const Duration(seconds: 5),
//                     );
//                     // timer?.cancel();

//                     Navigator.pop(context);
//                     if (from == "forgotPassword") {
//                       showNewPasswordDialog(context, email);
//                     } else {

//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const AuthPage()),
//                       );
//                     }
//                   } else {
//                     toastification.show(
//                       type: ToastificationType.error,
//                       style: ToastificationStyle.flat,
//                       alignment: Alignment.topCenter,
//                       context: context,
//                       title: Text("OTP does not match."),
//                       autoCloseDuration: const Duration(seconds: 5),
//                     );
//                   }
//                 },
//                 child: const Text(
//                   "Verify",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

// // ---------------- VERIFY OTP BACKEND CALL ----------------
// Future<bool> verifyOTP(String email, String otp, String from) async {
//   final url = Uri.parse(
//     from == "forgotPassword"
//         ? "${Env.apiBaseUrl}/api/auth/verify-forgot"
//         : "${Env.apiBaseUrl}/api/auth/verify",
//   );
//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({"email": email, "otp": otp}),
//   );
//   return response.statusCode == 200;
// }

// Future<bool> resendOTP(String email, String from) async {
//   final url = Uri.parse(
//     from == "forgotPassword"
//         ? "${Env.apiBaseUrl}/api/auth/forgot-password"
//         : "${Env.apiBaseUrl}/api/auth/resend-otp",
//   );

//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({"email": email}),
//   );

//   if (response.statusCode == 200) {
//     return true; // OTP sent successfully
//   }
//   return false; // failed
// }
