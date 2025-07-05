import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Vehicle {
  String? id;
  String vehicleNumber;
  String? type;
  String? brand;
  String? model;
  String? color;
  String? insuranceProvider;
  String? insurancePolicyNo;
  String ownerUserId;
  String? driverUserId;
  bool isDriverRegistered;
  String? notes;
  String qrCodeUuid;

  static String generateNumericUUID() {
    final random = Random.secure();
    // Generates a number between 1 and 99,999,999 (inclusive)
    int number = random.nextInt(99999999) + 1;
    // Pads with leading zeros to ensure an 8-digit string
    return number.toString().padLeft(8, '0');
  }

  Vehicle({
    this.id,
    required this.vehicleNumber,
    this.type,
    this.brand,
    this.model,
    this.color,
    this.insuranceProvider,
    this.insurancePolicyNo,
    required this.ownerUserId,
    this.driverUserId,
    this.isDriverRegistered = false,
    this.notes,
    String? qrCodeUuid, // accept optional for constructor
  }) : qrCodeUuid = qrCodeUuid ?? generateNumericUUID(); // assign new if null

  /// Factory constructor to create a Vehicle object from a Firestore DocumentSnapshot.
  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      vehicleNumber: data['vehicleNumber'] ?? '',
      type: data['type'],
      brand: data['brand'],
      model: data['model'],
      color: data['color'],
      insuranceProvider: data['insuranceProvider'],
      insurancePolicyNo: data['insurancePolicyNo'],
      ownerUserId: data['ownerUserId'] ?? '',
      driverUserId: data['driverUserId'],
      isDriverRegistered: data['isDriverRegistered'] ?? false,
      notes: data['notes'],
      qrCodeUuid: data['qrCodeUuid'], // use existing if present
    );
  }

  /// Converts the Vehicle object into a Map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'vehicleNumber': vehicleNumber,
      'type': type,
      'brand': brand,
      'model': model,
      'color': color,
      'insuranceProvider': insuranceProvider,
      'insurancePolicyNo': insurancePolicyNo,
      'ownerUserId': ownerUserId,
      'driverUserId': driverUserId,
      'isDriverRegistered': isDriverRegistered,
      'notes': notes,
      'qrCodeUuid': qrCodeUuid,
      'createdAt': FieldValue.serverTimestamp(), // Set on creation
      'lastUpdatedAt': FieldValue.serverTimestamp(), // Update on every save
    };
  }

  /// Converts the Vehicle object into a Map for storing in the QRMetadata collection.
  Map<String, dynamic> toQRMetadataFirestore() {
    return {
      'qrCodeUuid': qrCodeUuid,
      'ownerUserId': ownerUserId,
      'vehicleId': id, // Make sure 'id' is set when calling this
      'createdAt': FieldValue.serverTimestamp(), // Set on creation
      'lastUpdatedAt': FieldValue.serverTimestamp(), // Update on every save
    };
  }

  /// Creates a new [Vehicle] instance with specified changes.
  ///
  /// If a parameter is null, the corresponding value from the current instance is used.
  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? type,
    String? brand,
    String? model,
    String? color,
    String? insuranceProvider,
    String? insurancePolicyNo,
    String? ownerUserId,
    String? driverUserId,
    bool? isDriverRegistered,
    String? notes,
    String? qrCodeUuid,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNo: insurancePolicyNo ?? this.insurancePolicyNo,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      driverUserId: driverUserId ?? this.driverUserId,
      isDriverRegistered: isDriverRegistered ?? this.isDriverRegistered,
      notes: notes ?? this.notes,
      qrCodeUuid: qrCodeUuid ?? this.qrCodeUuid,
    );
  }

  Map<String, dynamic> toPublicMap() {
    return {
      'vehicleNumber': vehicleNumber,
      'type': type,
      'brand': brand,
      'model': model,
      'color': color,
      'notes': notes,
      'qrCodeUuid': qrCodeUuid,
    };
  }
}