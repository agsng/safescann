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
    int number = random.nextInt(99999999) + 1; // Range: 1 to 99,999,999
    return number.toString().padLeft(8, '0'); // Pads with leading zeros
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
    String? qrCodeUuid, // accept optional
  }) : qrCodeUuid = qrCodeUuid ?? generateNumericUUID(); // assign new if null

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
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    };
  }
  // Registring QrCode data
  Map<String, dynamic> toQRMetadataFirestore() {
    return {
      'qrCodeUuid': qrCodeUuid,
      'ownerUserId': ownerUserId,
      'vehicleId': id, // Make sure 'id' is set when calling this
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

}


