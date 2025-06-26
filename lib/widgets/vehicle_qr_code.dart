import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VehicleQrCode extends StatelessWidget {
  final String vehicleUUID;

  const VehicleQrCode({super.key, required this.vehicleUUID});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double qrSize = constraints.maxWidth < 300
            ? constraints.maxWidth * 0.8
            : 250.0;

        return Center(
          child: QrImageView(
            data: vehicleUUID,
            version: QrVersions.auto,
            size: qrSize,
            gapless: false,
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
