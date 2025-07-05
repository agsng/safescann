/// A models class to represent a single emergency contact.
class EmergencyContact {
  String? name;
  String? relationship;
  String? phone;
  String? email;

  EmergencyContact({
    this.name,
    this.relationship,
    this.phone,
    this.email,
  });

  /// Factory constructor to create an EmergencyContact object from a Map.
  factory EmergencyContact.fromMap(Map<String, dynamic> data) {
    return EmergencyContact(
      name: data['name'],
      relationship: data['relationship'],
      phone: data['phone'],
      email: data['email'],
    );
  }

  /// Converts the EmergencyContact object into a Map for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
    };
  }

  Map<String, dynamic> toPublicMap() {
    return {
      'name': name?.split(" ")[0],
      'relationship': relationship,
    };
  }
}
