import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'views/auth/auth_page.dart';
import 'views/student/dashboard.dart';
import 'views/teacher/dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;

      if (!loggedIn && state.uri.toString() != '/auth') return '/auth';
      if (loggedIn && state.uri.toString() == '/auth') {
        if (auth.role == 'student') return '/home';
        if (auth.role == 'teacher') return '/teacher';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'student_home',
        builder: (context, state) {
          final a = ref.read(authStateProvider);
          return StudentDashboard(token: a.token, user: a.user);
        },
      ),
      GoRoute(
        path: '/teacher',
        name: 'teacher_home',
        builder: (context, state) {
          final a = ref.read(authStateProvider);
          return TeacherDashboard(user: a.user);
        },
      ),
      // GoRoute(
      //   path: '/teacher',
      //   name: 'teacher_home',
      //   builder: (context, state) {
      //     final a = ref.read(authStateProvider);
      //     return AdminDashboard(user: a.user);
      //   },
      // ),
    ],
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Class QR',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
