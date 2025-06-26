import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CustomAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? _user;
  bool _isLoading = false;
  bool _isEmailVerified = false;

  CustomAuthProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _isEmailVerified;

  // New initialize method to set up auth listener
  void initialize() {
    _setupAuthListener();
  }

  // Set up auth state listener
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isEmailVerified = user?.emailVerified ?? false;
      notifyListeners();
    });
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = userCredential.user;
      _isEmailVerified = _user?.emailVerified ?? false;

      // Optional: Fetch additional user data from Firestore
      await _fetchUserData();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<void> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user details in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      _user = userCredential.user;
      _isEmailVerified = false;

      // Send email verification
      await sendEmailVerification();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      _user = null;
      _isEmailVerified = false;
      notifyListeners();
    } catch (e) {
      throw AuthException('Logout failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to send verification email.');
    }
  }

  // Fetch additional user data from Firestore
  Future<void> _fetchUserData() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        // Update user data if needed
      }
    } catch (e) {
      if (kDebugMode) print('Failed to fetch user data: $e');
    }
  }

  // Error handling
  AuthException _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email.');
      case 'wrong-password':
        return AuthException('Incorrect password.');
      case 'email-already-in-use':
        return AuthException('Email already in use.');
      case 'invalid-email':
        return AuthException('Invalid email address.');
      case 'weak-password':
        return AuthException('Password should be at least 6 characters.');
      case 'too-many-requests':
        return AuthException('Too many requests. Try again later.');
      case 'operation-not-allowed':
        return AuthException('Email/password accounts are not enabled.');
      case 'user-disabled':
        return AuthException('This account has been disabled.');
      default:
        return AuthException(e.message ?? 'Authentication failed.');
    }
  }

  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
