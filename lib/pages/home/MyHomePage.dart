import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safescann/providers/qr_code_provider.dart';
import '../../profile/profile_page.dart';
import '../../providers/auth_provider.dart';
import '../../pages/vehicle_management_page.dart';
import '../my_qrs_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // NEW: Controllers and state for the QR generator dialog
  final TextEditingController _uuidController = TextEditingController();
  String _generatedQrData = '';

  @override
  void dispose() {
    _uuidController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  /// NEW: Shows a dialog for generating a QR code based on a UUID input.
  void _showQrGeneratorDialog() {
    // Clear previous QR data and input when the dialog is opened
    setState(() {
      _generatedQrData = '';
      _uuidController.clear();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder is used to allow the dialog's content to rebuild
        // when the QR code is generated, without rebuilding the whole page.
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Generate Single QR Code'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column take minimum space
                  children: [
                    TextField(
                      controller: _uuidController,
                      decoration: const InputDecoration(
                        labelText: 'Enter UUID',
                        border: OutlineInputBorder(), // Add a border for better appearance
                      ),
                    ),
                    const SizedBox(height: 20), // Spacing
                    ElevatedButton(
                      onPressed: () {
                        // Update the QR data and trigger a rebuild of the dialog content
                        setStateInDialog(() {
                          _generatedQrData = _uuidController.text.trim();
                        });
                      },
                      child: const Text('Generate QR'),
                    ),
                    // Only show QR code and its label if data is available
                    if (_generatedQrData.isNotEmpty) ...[
                      const SizedBox(height: 20), // Spacing
                      // Using the QrCodeUtils to build the QR image
                      QrCodeGenerator.buildQrCode(data: _generatedQrData, size: 200.0),
                      const SizedBox(height: 10), // Spacing
                      Text('QR Code for: $_generatedQrData'), // Display the data below the QR
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<CustomAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Profile Button (can be removed if using drawer for profile management)
          IconButton(
            icon: const Icon(Icons.account_circle), // A common icon for profiles
            onPressed: () {
              // Navigate to the ProfilePage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      // Add the Drawer for the side menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.car_rental),
              title: const Text('Manage Vehicles'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleManagementPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Manage Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('My Vehicle QR Codes'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GetMyQrsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await auth.logout();
              },
            ),
            // You can add more ListTile widgets for additional options here
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${auth.user?.email ?? 'Guest'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Add other dashboard content here
          ],
        ),
      ),
    );
  }
}
