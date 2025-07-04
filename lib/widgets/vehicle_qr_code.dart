// lib/widgets/vehicle_qr_code.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VehicleQrCode extends StatelessWidget {
  final String qrCodeIdentifier; // The unique identifier for the QR code (vehicle.qrCodeUuid)

  static const String _firebaseHostingBaseUrl = 'https://safescann-aa466.web.app/';

  const VehicleQrCode({
    super.key,
    required this.qrCodeIdentifier, // Only qrCodeIdentifier is required
  });

  @override
  Widget build(BuildContext context) {
    final String qrDataUrl = '$_firebaseHostingBaseUrl/details/$qrCodeIdentifier';

    return LayoutBuilder(
      builder: (context, constraints) {
        double qrSize = constraints.maxWidth < 300
            ? constraints.maxWidth * 0.8
            : 200.0; // Consistent size

        return Column(
          children: [
            Center(
              child: QrImageView(
                data: qrDataUrl, // Pass the constructed URL here
                version: QrVersions.auto,
                size: qrSize,
                gapless: false, // Set to false for better compatibility
                backgroundColor: Colors.white,
                errorStateBuilder: (cxt, err) {
                  return Center(
                    child: Text(
                      'Oops! Failed to generate QR Code for:\n$qrDataUrl',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Display the URL below the QR code for verification (optional, but good for debugging)
            Text(
              '$qrDataUrl',
              style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
