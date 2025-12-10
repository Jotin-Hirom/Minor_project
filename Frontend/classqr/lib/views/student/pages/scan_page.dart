import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  final String studentEmail; // 👈 parameter added

  const ScanPage({
    super.key,
    required this.studentEmail, // 👈 required argument
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController controller = MobileScannerController();

  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR  (${widget.studentEmail})"), // optional display
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isScanned) return;
              isScanned = true;

              final barcode = capture.barcodes.first;
              final String? code = barcode.rawValue;

              if (code != null) {
                // you can log or send studentEmail + code to server here
                Navigator.pop(
                  context,
                  code,
                ); // return scanned value to previous page
              }
            },
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_on, size: 30),
                  onPressed: () => controller.toggleTorch(),
                ),
                const SizedBox(width: 25),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, size: 30),
                  onPressed: () => controller.switchCamera(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
