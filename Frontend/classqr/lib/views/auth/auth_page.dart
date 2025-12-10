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
              TextButton(
                onPressed: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .login(
                        "student",
                        User.fromJson({
                          "id": "djsb364834",
                          "email": "csm24006@tezu.ac.in",
                          "password": "Demo@123",
                          "role": "student",
                        }),
                        "skhdjhsdkh",
                      );
                },
                child: const Text('STUDENT DASHBOARD'),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .login(
                        "teacher",
                        User.fromJson({
                          "id": "djsb364834",
                          "email": "csm24006@tezu.ernet.in",
                          "password": "Demo@123",
                          "role": "teacher",
                        }),
                        "skhdjhsdkh",
                      );
                },
                child: const Text('TEACHER DASHBOARD'),
              ), 
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

// import 'package:classqr/views/student/dashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:classqr/views/auth/pages/forgot_password.dart';
// import 'package:classqr/views/auth/pages/login.dart';
// import 'package:classqr/views/auth/pages/signup.dart';

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   State<AuthPage> createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   int _selectedIndex = 0;

//   final List<Widget> screens = const [
//     LoginPage(),
//     SignupPage(),
//     ForgotPasswordPage(),
//   ];

//   final List<String> titles = ["Sign In", "Sign Up", "Forgot"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F2FA),
//       body: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               opacity: .3,

//               image: AssetImage(
//                 "assets/images/tu_bg.jpg",
//               ), // Your background image
//               fit: BoxFit.cover, // Full screen
//             ),
//           ),
//           child: Column(
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => StudentDashboard(
//                         token: "skhdjhsdkh",
//                         user: {
//                           "id": "djsb364834",
//                           "email": "csm24042@tezu.ac.in",
//                         },
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text("goto Dashboard"),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.transparent,
//                       child: ClipOval(
//                         child: Image.asset(
//                           "assets/images/logo.jpg",
//                           width: 80, // radius * 2
//                           height: 80, // radius * 2
//                           fit: BoxFit.cover, // THIS makes it fill perfectly
//                         ),
//                       ),
//                     ),

//                     // ------------------ TOP BAR TITLE ------------------
//                     const Padding(
//                       padding: EdgeInsets.all(18.0),
//                       child: Text(
//                         "CLASS QR",
//                         style: TextStyle(
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.indigo,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ------------------ TABS ------------------
//               Container(
//                 height: 50,
//                 width: 370,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   children: List.generate(3, (index) {
//                     bool active = _selectedIndex == index;

//                     return Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _selectedIndex = index),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: active ? Colors.white : Colors.transparent,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: active
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.black12,
//                                       blurRadius: 10,
//                                     ),
//                                   ]
//                                 : [],
//                           ),
//                           child: Text(
//                             titles[index],
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: active
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: active ? Colors.black : Colors.black54,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // ------------------ ACTIVE SCREEN ------------------
//               Expanded(child: screens[_selectedIndex]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
