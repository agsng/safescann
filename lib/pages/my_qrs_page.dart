// lib/my_qrs_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_manager.dart'; // Import ProfileManager
import '../widgets/vehicle_qr_code.dart'; // Import VehicleQrCode widget

class GetMyQrsPage extends StatefulWidget {
  const GetMyQrsPage({super.key});

  @override
  State<GetMyQrsPage> createState() => _GetMyQrsPageState();
}

class _GetMyQrsPageState extends State<GetMyQrsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileManager>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileManager = context.watch<ProfileManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicle QR Codes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: profileManager.isLoading && profileManager.userVehicles.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : profileManager.userVehicles.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No vehicles registered yet. Please go to "Manage Vehicles" to add your vehicles.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ) // Show message if no vehicles
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: profileManager.userVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = profileManager.userVehicles[index];

          // Only check if qrCodeUuid is available
          if (vehicle.qrCodeUuid == null || vehicle.qrCodeUuid!.isEmpty) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'QR Code cannot be generated (QR Code UUID missing).',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Vehicle Number
                  Text(
                    'Vehicle Number: ${vehicle.vehicleNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    'Type: ${vehicle.type ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  // Display QR Code by instantiating VehicleQrCode widget
                  Center(
                    child: VehicleQrCode(
                      qrCodeIdentifier: vehicle.qrCodeUuid!, // Pass only qrCodeUuid
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display "Order Now" Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Order Now for Vehicle ${vehicle.vehicleNumber}! (To be implemented)'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Order Now'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green, // Green for "Order Now"
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}