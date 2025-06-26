import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure this import path is correct for your CustomAuthProvider
import '../providers/auth_provider.dart'; // Assuming CustomAuthProvider is in this path
import '../models/user_profile.dart'; // Import the updated UserProfile model

/// A class to manage user profile data, extending ChangeNotifier for state management.
/// It interacts with Firebase Firestore to store and retrieve user profiles.
class ProfileManager with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  // Changed type from AuthProvider to CustomAuthProvider
  final CustomAuthProvider _authProvider; // Reference to CustomAuthProvider

  UserProfile? _userProfile; // Stores the currently loaded user profile
  bool _isLoading = false; // Indicates if an operation (fetch/save) is in progress

  // Getters for accessing profile data and loading state
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  /// Constructor for ProfileManager.
  /// Takes optional FirebaseAuth, FirebaseFirestore, and required CustomAuthProvider instances.
  ProfileManager({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    // Changed type from AuthProvider to CustomAuthProvider
    required CustomAuthProvider authProvider,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _authProvider = authProvider {
    // Listen to auth state changes to automatically fetch profile when user logs in/out
    _authProvider.addListener(_onAuthChanged);
  }

  /// Handles authentication state changes.
  /// When the user changes (e.g., logs in), it triggers a profile fetch.
  void _onAuthChanged() {
    // Only fetch if logged in and profile is not already loaded OR if user changes
    if (_authProvider.isLoggedIn && (_userProfile == null || _userProfile?.uid != _authProvider.user?.uid)) {
      fetchProfile(); // Fetch profile if logged in and no profile loaded yet or user UID changed
    } else if (!_authProvider.isLoggedIn) {
      _userProfile = null; // Clear profile if logged out
      notifyListeners();
    }
  }

  /// Fetches the user profile from Firestore.
  Future<void> fetchProfile() async {
    final user = _authProvider.user;
    if (user == null) {
      _userProfile = null; // No user logged in
      notifyListeners();
      return;
    }

    _setLoading(true); // Set loading state
    try {
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        // If profile exists, create UserProfile from Firestore data
        _userProfile = UserProfile.fromFirestore(docSnapshot);
      } else {
        // If no profile exists, create a new basic profile
        _userProfile = UserProfile(uid: user.uid, email: user.email);
        // Optionally save this basic profile to Firestore immediately
        // This ensures a profile document exists for new users upon first fetch.
        await _firestore.collection('users').doc(user.uid).set(_userProfile!.toFirestore());
      }
      notifyListeners(); // Notify listeners that user profile has been updated
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      // Consider throwing an error or showing a message to the user
      _userProfile = null; // Clear profile on error
      notifyListeners();
    } finally {
      _setLoading(false); // Clear loading state
    }
  }

  /// Saves the updated user profile to Firestore.
  Future<void> saveProfile(UserProfile profile) async {
    final user = _authProvider.user;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      profile.uid = user.uid;

      // Debug print
      if (kDebugMode) {
        print('Saving profile with data: ${profile.toFirestore()}');
      }

      await _firestore.collection('users').doc(user.uid).set(
        profile.toFirestore(),
        SetOptions(merge: true),
      );

      _userProfile = profile;
      notifyListeners();

      if (kDebugMode) {
        print('Profile saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
        print('Stack trace: ${e}');
      }
      throw Exception('Failed to save profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Helper method to update the loading state and notify listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
