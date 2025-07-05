import 'package:cloud_firestore/cloud_firestore.dart';
import 'emergency_contact.dart';
// import 'vehicleModel.dart'; // No direct import of Vehicle model here, only IDs

/// A model class to represent the user's profile data.
/// This helps in structuring data consistently for Firestore operations.
class UserProfile {
  String? uid;
  String? fullName;
  String? email;
  String? dateOfBirth;
  String? gender;
  String? profilePhotoUrl;
  String? primaryPhoneNumber;
  // String? alternatePhoneNumber;
  List<EmergencyContact> emergencyContacts;
  Map<String, String> assignedVehicles; // Changed to Map<VehicleId, AssignedName>
  String? bloodGroup;
  String? knownAllergies;
  String? medicalConditions;
  String? medications;
  String? homeAddress;
  String? preferredHospital;
  Timestamp? createdAt;
  Timestamp? lastLogin;

  UserProfile({
    this.uid,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.profilePhotoUrl,
    this.primaryPhoneNumber,
    // this.alternatePhoneNumber,
    this.emergencyContacts = const [],
    this.assignedVehicles = const {}, // Initialize as empty map
    this.bloodGroup,
    this.knownAllergies,
    this.medicalConditions,
    this.medications,
    this.homeAddress,
    this.preferredHospital,
    this.createdAt,
    this.lastLogin,
  });

  /// Factory constructor to create a UserProfile object from a Firestore DocumentSnapshot.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      fullName: data['fullName'],
      email: data['email'],
      dateOfBirth: data['dateOfBirth'],
      gender: data['gender'],
      profilePhotoUrl: data['profilePhotoUrl'],
      primaryPhoneNumber: data['primaryPhoneNumber'],
      // alternatePhoneNumber: data['alternatePhoneNumber'],
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromMap(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      // Parse assignedVehicles from Firestore map
      assignedVehicles: (data['assignedVehicles'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
      bloodGroup: data['bloodGroup'],
      knownAllergies: data['knownAllergies'],
      medicalConditions: data['medicalConditions'],
      medications: data['medications'],
      homeAddress: data['homeAddress'],
      preferredHospital: data['preferredHospital'],
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
    );
  }

  /// Converts the UserProfile object into a Map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePhotoUrl': profilePhotoUrl,
      'primaryPhoneNumber': primaryPhoneNumber,
      // 'alternatePhoneNumber': alternatePhoneNumber,
      'emergencyContacts': emergencyContacts.map((contact) => contact.toMap()).toList(),
      'assignedVehicles': assignedVehicles, // Store the map of IDs and assigned names
      'bloodGroup': bloodGroup,
      'knownAllergies': knownAllergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'homeAddress': homeAddress,
      'preferredHospital': preferredHospital,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a new UserProfile instance with the provided parameters,
  /// copying existing values if a parameter is not explicitly given.
  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? profilePhotoUrl,
    String? primaryPhoneNumber,
    List<EmergencyContact>? emergencyContacts,
    Map<String, String>? assignedVehicles,
    String? bloodGroup,
    String? knownAllergies,
    String? medicalConditions,
    String? medications,
    String? homeAddress,
    String? preferredHospital,
    Timestamp? createdAt,
    Timestamp? lastLogin,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      primaryPhoneNumber: primaryPhoneNumber ?? this.primaryPhoneNumber,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      assignedVehicles: assignedVehicles ?? this.assignedVehicles,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      knownAllergies: knownAllergies ?? this.knownAllergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      homeAddress: homeAddress ?? this.homeAddress,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toPublicMap() {
    return {
      'fullName': fullName?.split(" ")[0],
      'emergencyContacts': emergencyContacts.map((contact) => contact.toPublicMap()).toList(),
      'bloodGroup': bloodGroup,
      'knownAllergies': knownAllergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'preferredHospital': preferredHospital,
    };
  }
}
