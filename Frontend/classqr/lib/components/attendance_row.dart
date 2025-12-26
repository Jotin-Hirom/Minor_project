import 'package:classqr/components/action_chip.dart';
import 'package:flutter/material.dart';

class AttendanceRow extends StatelessWidget {
  final String roll;
  final String name;
  final String present;

  const AttendanceRow({
    super.key,
    required this.roll,
    required this.name,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(roll)),
          Expanded(child: Text(name)),

          Expanded(
            child: Text(
              present,
              style: TextStyle(
                color: present == "Present" ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          CustomActionChip(
            icon: present != "Present"
                ? Icons.check_circle_outline
                : Icons.person_remove_alt_1_outlined,
            label: present != "Present" ? "P" : "A",
            onPressed: () async {
              // Handle marking present here
              
            },
          ),
        ],
      ),
    );
  }
}
