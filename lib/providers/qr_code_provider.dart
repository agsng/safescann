import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import for QR code generation


class QrCodeGenerator {
  /// Returns a [QrImageView] widget for the given [data].
  ///
  /// [data]: The string content (e.g., a vehicle UUID) to encode in the QR code.
  /// [size]: The size (width and height) of the QR code image. Defaults to 280.0.
  /// [backgroundColor]: The background color of the QR code. Defaults to Colors.white.
  static QrImageView buildQrCode({
    required String data,
    double size = 280.0,
    Color backgroundColor = Colors.white,
  }) {
    // Return a QrImageView widget directly
    return QrImageView(
      data: data, // The data (UUID) to encode
      version: QrVersions.auto, // Automatically determines the best QR version
      size: size, // Size of the QR code image
      backgroundColor: backgroundColor, // Background color of the QR code
      gapless: true, // Render with no gaps for better scanning
      errorStateBuilder: (cxt, err) {
        // Error handling for QR code generation issues
        return Center(
          child: Text(
            'Oops! Failed to generate QR Code for:\n$data',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}
