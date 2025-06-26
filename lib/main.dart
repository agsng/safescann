import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safescann/pages/home/MyHomePage.dart';
import 'package:safescann/providers/auth_provider.dart';
import 'package:safescann/pages/auth/login_page.dart';
import 'package:safescann/pages/auth/register_page.dart';
import 'package:safescann/providers/profile_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Error boundary for Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
  };

  // Initialize Firebase with enhanced error handling
  try {
    // Check if Firebase app is already initialized to prevent duplicate-app error
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          // Add your Firebase config here
          apiKey: "AIzaSyCSEFjpARjtSmNv76nmdgLYfXmTMQiTv34",
          appId: "1:220626158058:android:5b51118351cbd7eb433293",
          messagingSenderId: "220626158058",
          projectId: "safescann-aa466",
        ),
      );
    }
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize Firebase: ${e.toString()}'),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    MultiProvider( // Use MultiProvider for multiple ChangeNotifierProviders
      providers: [
        ChangeNotifierProvider(
          create: (context) => CustomAuthProvider()..initialize(),
        ),
        // ChangeNotifierProxyProvider is used when a provider depends on another provider
        ChangeNotifierProxyProvider<CustomAuthProvider, ProfileManager>(
          create: (context) => ProfileManager(authProvider: Provider.of<CustomAuthProvider>(context, listen: false)),
          update: (context, auth, previousProfileManager) {
            // Return a new ProfileManager if AuthProvider changes.
            // Re-creating the ProfileManager here ensures it always has the latest AuthProvider instance.
            // The ProfileManager has a listener to AuthProvider, so it will handle fetching the profile itself.
            return ProfileManager(authProvider: auth);
          },
        ),
      ],
      child: const SafeScannApp(),
    ),
  );
}

class SafeScannApp extends StatelessWidget {
  const SafeScannApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeScann',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MyHomePage(title: 'Dashboard'),
      },
      navigatorObservers: [
        // Add any navigation observers (e.g., for analytics)
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      // Customize dark theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<CustomAuthProvider>(context);

    // Wait for Firebase to emit auth state
    if (auth.isLoading) {
      return const AppSplashScreen();
    }

    return auth.isLoggedIn
        ? const MyHomePage(title: 'Dashboard')
        : const LoginPage();
  }
}
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}