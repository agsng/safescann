import 'package:cloud_firestore/cloud_firestore.dart';

/// A models class to represent the user's profile data.
/// This helps in structuring data consistently for Firestore operations.
class UserProfile {
  String? uid;
  String? fullName;
  String? email;
  String? dateOfBirth; // Consider using DateTime for actual date objects
  String? gender;
  String? profilePhotoUrl; // URL for profile picture
  String? primaryPhoneNumber;
  String? alternatePhoneNumber;
  List<Map<String, String>> emergencyContacts; // List of maps for dynamic contacts
  String? vehicleNumberPlate;
  String? vehicleType;
  String? vehicleMakeModel;
  String? vehicleColor;
  String? insuranceProvider;
  String? insurancePolicyNo;
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
    this.alternatePhoneNumber,
    this.emergencyContacts = const [],
    this.vehicleNumberPlate,
    this.vehicleType,
    this.vehicleMakeModel,
    this.vehicleColor,
    this.insuranceProvider,
    this.insurancePolicyNo,
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
      alternatePhoneNumber: data['alternatePhoneNumber'],
      // Convert list of dynamic maps to list of string maps
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e))
          .toList() ??
          [],
      vehicleNumberPlate: data['vehicleNumberPlate'],
      vehicleType: data['vehicleType'],
      vehicleMakeModel: data['vehicleMakeModel'],
      vehicleColor: data['vehicleColor'],
      insuranceProvider: data['insuranceProvider'],
      insurancePolicyNo: data['insurancePolicyNo'],
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
      'alternatePhoneNumber': alternatePhoneNumber,
      'emergencyContacts': emergencyContacts,
      'vehicleNumberPlate': vehicleNumberPlate,
      'vehicleType': vehicleType,
      'vehicleMakeModel': vehicleMakeModel,
      'vehicleColor': vehicleColor,
      'insuranceProvider': insuranceProvider,
      'insurancePolicyNo': insurancePolicyNo,
      'bloodGroup': bloodGroup,
      'knownAllergies': knownAllergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'homeAddress': homeAddress,
      'preferredHospital': preferredHospital,
      // createdAt is only set on initial creation if not present
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(), // Always update last login
    };
  }
}
