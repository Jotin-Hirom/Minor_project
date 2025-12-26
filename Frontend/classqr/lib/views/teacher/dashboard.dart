import 'dart:convert';

import 'package:classqr/views/teacher/pages/profile_tab.dart';
import 'package:classqr/views/teacher/pages/subject_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import '../../constant/console.dart';
import '../../core/config/env.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/refresh.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  final String? token;
  final User? user;
  const TeacherDashboard({super.key, this.token, this.user});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  @override
  void initState() { 
    super.initState();
    // Kick off token refresh as soon as widget mounts.
    // We do this without awaiting in initState; the async method will check mounted before modifying state.
    // _attemptRefresh();
  }

  Future<void> _attemptRefresh() async {
    // Read current auth state
    final auth = ref.read(authStateProvider);
    final email = auth.user?.email.toLowerCase();

    if (email == null || email.isEmpty) {
      // Nothing to refresh
      return;
    }

    try {
      final Map<String, dynamic> resp = await refreshToken(email);

      // Typical response shapes: { "token": "..."} or { "accessToken": "..."} or { "data": {"token": "..."}}
      String? newToken;
      if (resp.containsKey('token') && resp['token'] is String) {
        newToken = resp['token'] as String;
      } else if (resp.containsKey('accessToken') &&
          resp['accessToken'] is String) {
        newToken = resp['accessToken'] as String;
      } else if (resp.containsKey('data') &&
          resp['data'] is Map &&
          (resp['data'] as Map).containsKey('token')) {
        newToken = (resp['data'] as Map)['token'] as String?;
      }

      if (newToken != null && newToken.isNotEmpty) {
        // Update token in auth provider.
        // --- ADJUST THIS LINE to your notifier API if method name differs ---
        // Example method names you might have: setToken, updateToken, loginWithToken, saveToken, etc.
        try {
          // Attempt a common notifier method
          await ref.read(authStateProvider.notifier).updateToken(newToken);
        } catch (_) {
          // If the notifier doesn't have updateToken, attempt a few common alternatives
          try {
            await ref.read(authStateProvider.notifier).setToken(newToken);
          } catch (_) {
            try {
              await ref
                  .read(authStateProvider.notifier)
                  .loginWithToken(newToken);
            } catch (e) {
              // If none of the above exist, log a console message. You should wire this to the actual method.
              // You can also directly persist token to wherever your app stores it (secure storage), then update provider.
              log(
                'TeacherDashboard: Could not update token on auth notifier. '
                'Please adapt notifier method names. Error: $e',
              );
            }
          }
        }

        // optionally: show a subtle success toast (commented out)
        // toastification.show(type: ToastificationType.success, alignment: Alignment.topCenter, context: context, title: Text("Session refreshed."));
      } else {
        // No token returned -> treat as failure
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          alignment: Alignment.topCenter,
          context: context,
          title: const Text("Session refresh failed."),
          autoCloseDuration: const Duration(seconds: 4),
        );
        // force logout to clear stale state
        await ref.read(authStateProvider.notifier).logout();
        if (mounted) context.go('/auth');
      }
    } catch (e, st) {
      log('TeacherDashboard: refreshToken error: $e\n$st');
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        context: context,
        title: const Text("Unable to refresh session."),
        autoCloseDuration: const Duration(seconds: 5),
      );
      // On network/server error, log the user out to avoid inconsistent state
      try {
        await ref.read(authStateProvider.notifier).logout();
      } catch (_) {}
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ClassQR - Teacher Dashboard"),
          backgroundColor: Colors.indigo, 
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            isScrollable: false,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.subject), text: 'Courses'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse('${Env.apiBaseUrl}/api/auth/logout');
                dynamic response;
                try {
                  var token = auth.token;
                  final result = await http.post(
                    url,
                    headers: {
                      "Authorization": "Bearer $token",
                      "Content-Type": "application/json",
                    },
                    body: jsonEncode({"email": user?.email.toLowerCase()}),
                  );
                  response = result;
                } catch (e) {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Server error."),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }
                if (response != null && response.statusCode == 200) {
                  toastification.show(
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Logged out successfully."),
                  );
                  await ref.read(authStateProvider.notifier).logout();
                  context.go('/auth');
                } else {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    alignment: Alignment.topCenter,
                    context: context,
                    title: const Text("Can't logout."),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }
              },
              child: Icon(
                CupertinoIcons.square_arrow_right,
                size: 30.0,
                color: CupertinoColors.white, // Or any other color
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ProfileTab(user: user),
            SubjectsTab(),
          ],
        ),
      ),
    );
  }
}

//context.pushNamed("teacher_select_subjects");
// context.goNamed("teacher_home");
