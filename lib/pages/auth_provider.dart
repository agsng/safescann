import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoggedIn = false;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  // Login with Email & Password
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      throw e; // Handle error in UI
    }
  }

  // Register New User
  Future<void> register(String email, String password, String name) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _user = userCredential.user;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      throw e; // Handle error in UI
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}