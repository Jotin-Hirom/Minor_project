import 'package:flutter/material.dart';

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              "Roll No",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Expanded(
          //   child: Text(
          //     "Mark Attendance",
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          SizedBox(width: 60),
        ],
      ),
    );
  }
}
