import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safescann/providers/qr_code_provider.dart';
import '../providers/profile_manager.dart'; // Import ProfileManager
import '../models/vehicleModel.dart'; // Import Vehicle model

class GetMyQrsPage extends StatefulWidget {
  const GetMyQrsPage({super.key});

  @override
  State<GetMyQrsPage> createState() => _GetMyQrsPageState();
}

class _GetMyQrsPageState extends State<GetMyQrsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile and vehicles when the page initializes
    // This ensures we have the latest vehicle data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileManager>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ProfileManager to react to changes in userVehicles or loading state
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
                  // Display QR Code
                  if (vehicle.id != null && vehicle.id!.isNotEmpty)
                    Center(
                      child: QrCodeGenerator.buildQrCode(
                        data: vehicle.id!, // Use vehicle ID as QR data
                        size: 200.0, // Set a smaller size for list view
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'QR Code cannot be generated (Vehicle ID missing).',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Display "Order Now" Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement "Order Now" logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order Now for Vehicle ${vehicle.vehicleNumber}! (To be implemented)'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Order Now'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green, // Green for "Order Now"
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
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
