import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safescann/pages/MyHomePage.dart';
import 'package:safescann/pages/auth_provider.dart';
import 'package:safescann/pages/login_page.dart';
import 'package:safescann/pages/register_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return auth.isLoggedIn
              ? MyHomePage(title: 'Dashboard')
              : LoginPage();
        },
      ),
      routes: {
        '/register': (context) => RegisterPage(),
      },
    );
  }
}