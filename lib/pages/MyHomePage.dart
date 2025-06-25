import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/profile.dart';
import 'auth_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Profile Button
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
          // Logout Button (existing)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${auth.user?.email ?? 'Guest'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // The existing "View/Edit Profile" button can be kept or removed if the AppBar button is sufficient
            ElevatedButton(
              onPressed: () {
                // Navigate to the ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Text('View/Edit Profile (or use header button)'),
            ),
            // Add other dashboard content here
          ],
        ),
      ),
    );
  }
}
