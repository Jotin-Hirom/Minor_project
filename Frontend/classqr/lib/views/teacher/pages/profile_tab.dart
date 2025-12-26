// ignore_for_file: deprecated_member_use

import 'package:classqr/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfileTab extends StatelessWidget {
  final User? user;
  const ProfileTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        // PROFILE CARD
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  user?.name?[0].toUpperCase() ?? "S",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? "Student",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      "Role: ${user?.role?.toUpperCase() ?? "STUDENT"}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CALENDAR
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Widget _info(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
  //         Expanded(child: Text(value)),
  //       ],
  //     ),
  //   );
  // }
}
