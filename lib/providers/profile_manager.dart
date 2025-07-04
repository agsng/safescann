import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure this import path is correct for your CustomAuthProvider
import '../providers/auth_provider.dart'; // Assuming CustomAuthProvider is in this path
import '../models/user_profile.dart'; // Import the updated UserProfile model
import '../models/vehicleModel.dart'; // Import the Vehicle model

/// A class to manage user profile data, extending ChangeNotifier for state management.
/// It interacts with Firebase Firestore to store and retrieve user profiles.
class ProfileManager with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  // Changed type from AuthProvider to CustomAuthProvider
  final CustomAuthProvider _authProvider; // Reference to CustomAuthProvider

  UserProfile? _userProfile; // Stores the currently loaded user profile
  List<Vehicle> _userVehicles = []; // Stores the list of vehicles associated with the user
  bool _isLoading = false; // Indicates if an operation (fetch/save) is in progress

  // Getters for accessing profile data and loading state
  UserProfile? get userProfile => _userProfile;
  List<Vehicle> get userVehicles => _userVehicles;
  bool get isLoading => _isLoading;
  String? get currentUserId => _authProvider.user?.uid;

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
      _userVehicles = []; // Clear vehicles on logout as well
      notifyListeners();
    }
  }

  /// Fetches the user profile from Firestore.
  Future<void> fetchProfile() async {
    final user = _authProvider.user;
    if (user == null) {
      _userProfile = null; // No user logged in
      _userVehicles = [];
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

      // After fetching UserProfile, fetch the associated Vehicles
      await _fetchUserVehicles(user.uid);

      notifyListeners(); // Notify listeners that user profile and vehicles have been updated
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile or vehicles: $e');
      }
      // Consider throwing an error or showing a message to the user
      _userProfile = null; // Clear profile on error
      _userVehicles = [];
      notifyListeners();
    } finally {
      _setLoading(false); // Clear loading state
    }
  }

  /// Fetches vehicles owned by a specific user.
  Future<void> _fetchUserVehicles(String userId) async {
    try {
      // Query the 'vehicles' collection for vehicles owned by this user
      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('ownerUserId', isEqualTo: userId)
          .get();

      _userVehicles = querySnapshot.docs
          .map((doc) => Vehicle.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user vehicles: $e');
      }
      _userVehicles = []; // Clear vehicles on error
    }
  }

  /// Saves the updated user profile to Firestore.
  /// Note: Vehicle objects themselves are managed by addVehicle, updateVehicle, deleteVehicle.
  /// This method updates the UserProfile document, including the `assignedVehicles` map.
  Future<void> saveProfile(UserProfile profile) async {
    final user = _authProvider.user;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      profile.uid = user.uid; // Ensure the UID matches the current user

      if (kDebugMode) {
        print('Saving profile with data: ${profile.toFirestore()}');
      }

      await _firestore.collection('users').doc(user.uid).set(
        profile.toFirestore(),
        SetOptions(merge: true), // Use merge to update existing fields without overwriting
      );

      _userProfile = profile; // Update the local profile
      notifyListeners();

      if (kDebugMode) {
        print('Profile saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
        print('Stack trace: $e');
      }
      throw Exception('Failed to save profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new vehicle to the 'vehicles' collection.
  /// The vehicle's ID will be automatically added to the user's assignedVehicles map when saving the UserProfile.
  Future<void> addVehicle(Vehicle vehicle) async {
    final user = _authProvider.user;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    if (user.uid != vehicle.ownerUserId) {
      throw Exception('Vehicle owner mismatch.');
    }

    _setLoading(true);
    try {
      // Add vehicle to 'vehicles' collection
      final vehicleDocRef = await _firestore.collection('vehicles').add(vehicle.toFirestore());
      vehicle.id = vehicleDocRef.id; // Assign the newly generated ID to the model

      // Add QR metadata to 'QRMetadata' collection
      await _firestore.collection('QRMetadata').doc(vehicle.qrCodeUuid).set(vehicle.toQRMetadataFirestore());

      // Add to local list
      _userVehicles.add(vehicle);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding vehicle or QR metadata: $e');
      }
      throw Exception('Failed to add vehicle: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing vehicle in the 'vehicles' collection and potentially its QRMetadata.
  Future<void> updateVehicle(Vehicle vehicle) async {
    final user = _authProvider.user;
    if (user == null || vehicle.id == null) {
      throw Exception('User not logged in or vehicle ID missing.');
    }
    if (user.uid != vehicle.ownerUserId) {
      throw Exception('Vehicle owner mismatch. Cannot update another user\'s vehicle.');
    }

    _setLoading(true);
    try {
      // Update vehicle in 'vehicles' collection
      await _firestore.collection('vehicles').doc(vehicle.id).set(
        vehicle.toFirestore(),
        SetOptions(merge: true), // Use merge to update specific fields
      );

      // Update QR metadata in 'QRMetadata' collection
      // If qrCodeUuid can change, you might need to delete the old one and create a new one.
      // For simplicity, we assume qrCodeUuid is stable after creation.
      await _firestore.collection('QRMetadata').doc(vehicle.qrCodeUuid).set(
        vehicle.toQRMetadataFirestore(),
        SetOptions(merge: true), // Use merge for QR metadata as well
      );

      // Update local list
      int index = _userVehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _userVehicles[index] = vehicle;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating vehicle or QR metadata: $e');
      }
      throw Exception('Failed to update vehicle: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a vehicle from the 'vehicles' collection and its associated QRMetadata.
  Future<void> deleteVehicle(String vehicleId) async {
    final user = _authProvider.user;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      // Find the vehicle to get its qrCodeUuid before deleting
      final vehicleToDelete = _userVehicles.firstWhere((v) => v.id == vehicleId);

      // Delete the vehicle document itself
      await _firestore.collection('vehicles').doc(vehicleId).delete();

      // Delete the corresponding QR metadata
      if (vehicleToDelete.qrCodeUuid.isNotEmpty) {
        await _firestore.collection('QRMetadata').doc(vehicleToDelete.qrCodeUuid).delete();
      }

      // Remove from local list.
      _userVehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting vehicle or QR metadata: $e');
      }
      throw Exception('Failed to delete vehicle: $e');
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