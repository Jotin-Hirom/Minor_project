import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AttendanceTab extends ConsumerWidget {
  const AttendanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attended = 42;
    final total = 50;
    final percentage = (attended / total) * 100;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attendance Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Total Classes: $total"),
              Text("Attended: $attended"),
              Text("Percentage: ${percentage.toStringAsFixed(1)}%"),
              const SizedBox(height: 20),

              // CIRCLE INDICATOR (visual effect)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 10,
                        color: Colors.indigo,
                        backgroundColor: Colors.indigo.shade100,
                      ),
                    ),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            _showQRDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Scan QR for Attendance"),
        ),
      ],
    );
  }

  // Modern QR Pop-up
  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Scan QR"),
        content: SizedBox(
          height: 280,
          child: Center(
            child: QrImageView(data: "attendance-qr-here", size: 220),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
