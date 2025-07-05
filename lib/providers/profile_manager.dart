// In profile_manager.dart

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart'; // Ensure this import is present if using firstWhereOrNull

import '../models/user_profile.dart';
import '../models/vehicleModel.dart';
import '../providers/auth_provider.dart';
// The import below should be removed if it's importing itself, assuming this file *is* profile_manager.dart
// import '../providers/profile_manager.dart';


class ProfileManager with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CustomAuthProvider _authProvider;

  UserProfile? _userProfile;
  List<Vehicle> _userVehicles = [];
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  List<Vehicle> get userVehicles => _userVehicles;
  bool get isLoading => _isLoading;
  String? get currentUserId => _authProvider.user?.uid;

  ProfileManager({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required CustomAuthProvider authProvider,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _authProvider = authProvider {
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authProvider.isLoggedIn && (_userProfile == null || _userProfile?.uid != _authProvider.user?.uid)) {
      fetchProfile();
    } else if (!(_authProvider.isLoggedIn)) {
      _userProfile = null;
      _userVehicles = [];
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    final user = _authProvider.user;
    if (user == null) {
      _userProfile = null;
      _userVehicles = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        _userProfile = UserProfile.fromFirestore(docSnapshot);
      } else {
        _userProfile = UserProfile(uid: user.uid, email: user.email);
        await _firestore.collection('users').doc(user.uid).set(_userProfile!.toFirestore());
      }

      await _fetchUserVehicles(user.uid);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile or vehicles: $e');
      }
      _userProfile = null;
      _userVehicles = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserVehicles(String userId) async {
    try {
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
      _userVehicles = [];
    }
  }

  /// Saves the updated user profile to Firestore.
  /// This method updates the UserProfile document, including the `assignedVehicles` map.
  Future<void> saveProfile(UserProfile profile) async {
    final user = _authProvider.user;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      profile.uid = user.uid;

      if (kDebugMode) {
        print('ProfileManager: Calling saveProfile for user ${user.uid}');
        print('ProfileManager: assignedVehicles in saveProfile: ${profile.assignedVehicles}');
        print('ProfileManager: Full profile data to save: ${profile.toFirestore()}');
      }

      // Prepare data for general profile fields, excluding 'assignedVehicles'
      // This allows 'assignedVehicles' to be handled separately for a full overwrite.
      Map<String, dynamic> generalProfileData = profile.toFirestore();
      generalProfileData.remove('assignedVehicles'); // Temporarily remove from this map

      // Perform the general profile update with merge: true
      // This will merge other top-level fields, leaving 'assignedVehicles' untouched for now.
      await _firestore.collection('users').doc(user.uid).set(
        generalProfileData,
        SetOptions(merge: true),
      );

      // Now, perform a separate update specifically for 'assignedVehicles'.
      // This `update()` call will completely replace the 'assignedVehicles' map
      // with the new `profile.assignedVehicles` map, correctly handling deletions.
      await _firestore.collection('users').doc(user.uid).update(
        {'assignedVehicles': profile.assignedVehicles},
      );


      _userProfile = profile; // Update the local profile immediately after initiating the write
      notifyListeners(); // Notify listeners that user profile has been updated locally

      // Update public vehicle details for all *current* user vehicles
      for (final vehicle in _userVehicles) {
        if (vehicle.ownerUserId == user.uid) {
          await _updatePublicVehicleDetails(vehicle.qrCodeUuid, profile, vehicle);
        }
      }

      if (kDebugMode) {
        print('ProfileManager: Profile saved successfully to Firestore and local state updated.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ProfileManager: Error saving profile: $e');
        print('ProfileManager: Stack trace: $e');
      }
      throw Exception('Failed to save profile: $e');
    } finally {
      _setLoading(false);
    }
  }

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
      final vehicleDocRef = await _firestore.collection('vehicles').add(vehicle.toFirestore());
      vehicle.id = vehicleDocRef.id;

      await _firestore.collection('QRMetadata').doc(vehicle.qrCodeUuid).set(vehicle.toQRMetadataFirestore());

      if (_userProfile != null) {
        // Public details will be updated when the profile is saved via _saveVehicles
        // or ensure this is handled consistently for new vehicles if needed immediately.
        await _updatePublicVehicleDetails(vehicle.qrCodeUuid, _userProfile!, vehicle);
      }

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
      await _firestore.collection('vehicles').doc(vehicle.id).set(
        vehicle.toFirestore(),
        SetOptions(merge: true),
      );

      final qrDoc = await _firestore.collection('QRMetadata').doc(vehicle.qrCodeUuid).get();

      bool shouldUpdateQRMetadata = true;
      if (qrDoc.exists) {
        final data = qrDoc.data();
        if (data != null &&
            data['vehicleId'] == vehicle.id &&
            data['ownerUserId'] == vehicle.ownerUserId) {
          shouldUpdateQRMetadata = false;
        }
      }

      if (shouldUpdateQRMetadata) {
        await _firestore.collection('QRMetadata').doc(vehicle.qrCodeUuid).set(
          vehicle.toQRMetadataFirestore(),
          SetOptions(merge: true),
        );
      }

      if (_userProfile != null) {
        await _updatePublicVehicleDetails(vehicle.qrCodeUuid, _userProfile!, vehicle);
      }

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

  /// Deletes a vehicle from the 'vehicles' collection and its associated QRMetadata,
  /// PublicVehicleDetails documents. It also ensures the local `_userVehicles` list is updated.
  /// **Important:** The `assignedVehicles` map in UserProfile is now updated
  /// exclusively by the `_saveVehicles` method in `VehicleManagementPage`.
  Future<void> deleteVehicle(String vehicleId) async {
    final user = _authProvider.user;
    if (user == null) {
      if (kDebugMode) print('Delete failed: User not logged in.');
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      // Find the vehicle in the local list to get its QR UUID for associated document deletion
      final vehicleToDelete = _userVehicles.firstWhereOrNull((v) => v.id == vehicleId);

      // Only attempt to delete vehicle document and associated metadata
      // if the vehicle was found in the local list (meaning it existed in Firestore).
      if (vehicleToDelete != null) {
        final vehicleDocRef = _firestore.collection('vehicles').doc(vehicleId);
        final qrMetadataDocRef = _firestore.collection('QRMetadata').doc(vehicleToDelete.qrCodeUuid);
        final publicDetailsDocRef = _firestore.collection('PublicVehicleDetails').doc(vehicleToDelete.qrCodeUuid);

        // Batch delete for atomicity (optional but good practice for related documents)
        WriteBatch batch = _firestore.batch();
        batch.delete(vehicleDocRef);
        batch.delete(qrMetadataDocRef);
        batch.delete(publicDetailsDocRef);
        await batch.commit();

        if (kDebugMode) print('ProfileManager: Vehicle and associated data deleted from Firestore.');
      } else {
        if (kDebugMode) {
          print('ProfileManager: Vehicle with ID $vehicleId not found in local _userVehicles list. '
              'Skipping Firestore document deletions (vehicles, QRMetadata, PublicVehicleDetails).');
        }
      }

      // Remove from local _userVehicles list.
      _userVehicles.removeWhere((v) => v.id == vehicleId);
      if (kDebugMode) print('ProfileManager: Vehicle ID $vehicleId removed from local _userVehicles list.');

      notifyListeners(); // Notify listeners about changes in _userVehicles

    } catch (e) {
      if (kDebugMode) {
        print('ProfileManager: Error deleting vehicle or associated data: $e');
        rethrow; // Re-throw the exception so the UI can catch it and show a SnackBar.
      }
      throw Exception('Failed to delete vehicle: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Creates or updates a document in the PublicVehicleDetails collection.
  /// This combines public info from UserProfile and Vehicle.
  Future<void> _updatePublicVehicleDetails(String qrCodeUuid, UserProfile profile, Vehicle vehicle) async {
    if (qrCodeUuid.isEmpty) {
      if (kDebugMode) print("QR Code UUID is empty, cannot update public details.");
      return;
    }

    final publicData = {
      'qrCodeUuid': qrCodeUuid,
      'ownerPublicInfo': profile.toPublicMap(), // Assuming these are commented out
      'vehiclePublicInfo': vehicle.toPublicMap(), // Assuming these are commented out
      'lastUpdatedPublicly': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('PublicVehicleDetails').doc(qrCodeUuid).set(
        publicData,
        SetOptions(merge: true),
      );
      if (kDebugMode) print("PublicVehicleDetails updated for QR: $qrCodeUuid");
    } catch (e) {
      if (kDebugMode) print("Error updating PublicVehicleDetails for QR $qrCodeUuid: $e");
      // Consider logging to a remote error tracking system
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