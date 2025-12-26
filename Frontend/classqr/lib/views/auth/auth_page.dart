import 'package:classqr/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/auth_provider.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/forgot_password.dart';

final authTabIndexProvider = StateProvider<int>((ref) => 0);

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(authTabIndexProvider);

    final screens = const [LoginPage(), SignupPage(), ForgotPasswordPage()];

    final titles = ['Sign In', 'Sign Up', 'Forgot'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              opacity: 0.3,
              image: AssetImage('assets/images/tu_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'CLASS QR',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 370,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: List.generate(3, (index) {
                    final active = selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(authTabIndexProvider.notifier).state =
                                index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: active
                                ? const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            titles[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: active ? Colors.black : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: screens[selectedIndex]),
            ],
          ),
        ),
      ),
    );
  }
}
