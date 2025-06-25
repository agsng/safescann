import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart'; // Required for Provider
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Firestore
import 'package:intl/intl.dart'; // For date formatting. Add 'intl: ^latest_version' to pubspec.yaml

import '../provider/profile_manager.dart'; // Required for Firestore
import 'package:safescann/pages/auth_provider.dart'; // Corrected import path for AuthProvider

/// A model class to represent the user's profile data.
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
  // bool? emailVerified; // Removed as requested

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
    // this.emailVerified, // Removed as requested
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
      // emailVerified: data['emailVerified'], // Removed as requested
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
      // 'emailVerified': emailVerified, // Removed as requested
    };
  }
}


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fix: Initialize _formKey here
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Text controllers for each field
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _emailController; // Email might be read-only but needs controller for display
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehicleMakeModelController;
  late TextEditingController _vehicleColorController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insurancePolicyController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _knownAllergiesController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _medicationsController;
  late TextEditingController _homeAddressController;
  late TextEditingController _preferredHospitalController;

  // Lists for dropdown options
  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to disclose'];
  final List<String> _vehicleTypeOptions = ['Car', 'Motorcycle', 'Truck', 'Van', 'Bicycle', 'Other'];
  final List<String> _vehicleColorOptions = ['Red', 'Blue', 'Black', 'White', 'Silver', 'Grey', 'Green', 'Yellow', 'Orange', 'Brown', 'Purple', 'Gold', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];


  // List of controllers for emergency contacts
  final List<TextEditingController> _ecNameControllers = [];
  final List<TextEditingController> _ecRelationshipControllers = [];
  final List<TextEditingController> _ecPhoneControllers = [];
  final List<TextEditingController> _ecEmailControllers = [];


  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Fetch profile data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  /// Initializes all text controllers.
  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _primaryPhoneController = TextEditingController();
    _alternatePhoneController = TextEditingController();
    _emailController = TextEditingController(); // Initialize email controller
    _vehiclePlateController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehicleMakeModelController = TextEditingController();
    _vehicleColorController = TextEditingController();
    _insuranceProviderController = TextEditingController();
    _insurancePolicyController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _knownAllergiesController = TextEditingController();
    _medicalConditionsController = TextEditingController();
    _medicationsController = TextEditingController();
    _homeAddressController = TextEditingController();
    _preferredHospitalController = TextEditingController();
  }

  /// Populates text controllers with data from UserProfile fetched from ProfileManager.
  void _populateControllers(UserProfile? profile) {
    if (profile == null) return;

    // Access AuthProvider using context.read<AuthProvider>() for a one-time read
    // This is safe to do in build or init methods when the provider is guaranteed to be an ancestor.
    final authProvider = context.read<AuthProvider>();

    _fullNameController.text = profile.fullName ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
    _genderController.text = profile.gender ?? '';
    _primaryPhoneController.text = profile.primaryPhoneNumber ?? '';
    _alternatePhoneController.text = profile.alternatePhoneNumber ?? '';
    _emailController.text = profile.email ?? authProvider.user?.email ?? ''; // Fetch logged-in user email as default
    _vehiclePlateController.text = profile.vehicleNumberPlate ?? '';
    _vehicleTypeController.text = profile.vehicleType ?? '';
    _vehicleMakeModelController.text = profile.vehicleMakeModel ?? '';
    _vehicleColorController.text = profile.vehicleColor ?? '';
    _insuranceProviderController.text = profile.insuranceProvider ?? '';
    _insurancePolicyController.text = profile.insurancePolicyNo ?? '';
    _bloodGroupController.text = profile.bloodGroup ?? '';
    _knownAllergiesController.text = profile.knownAllergies ?? '';
    _medicalConditionsController.text = profile.medicalConditions ?? '';
    _medicationsController.text = profile.medications ?? '';
    _homeAddressController.text = profile.homeAddress ?? '';
    _preferredHospitalController.text = profile.preferredHospital ?? '';

    // Clear existing emergency contact controllers before repopulating
    _ecNameControllers.forEach((c) => c.dispose());
    _ecRelationshipControllers.forEach((c) => c.dispose());
    _ecPhoneControllers.forEach((c) => c.dispose());
    _ecEmailControllers.forEach((c) => c.dispose());
    _ecNameControllers.clear();
    _ecRelationshipControllers.clear();
    _ecPhoneControllers.clear();
    _ecEmailControllers.clear();


    // Populate emergency contact controllers
    for (var contact in profile.emergencyContacts) {
      _ecNameControllers.add(TextEditingController(text: contact['name']));
      _ecRelationshipControllers.add(TextEditingController(text: contact['relationship']));
      _ecPhoneControllers.add(TextEditingController(text: contact['phone']));
      _ecEmailControllers.add(TextEditingController(text: contact['email']));
    }
    // Ensure at least two empty contact fields if currently less than 2
    while (_ecNameControllers.length < 2) {
      _addEmergencyContactField();
    }
  }

  /// Disposes all text controllers to prevent memory leaks.
  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _primaryPhoneController.dispose();
    _alternatePhoneController.dispose();
    _emailController.dispose();
    _vehiclePlateController.dispose();
    _vehicleTypeController.dispose();
    _vehicleMakeModelController.dispose();
    _vehicleColorController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    _bloodGroupController.dispose();
    _knownAllergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _homeAddressController.dispose();
    _preferredHospitalController.dispose();

    for (var controller in _ecNameControllers) controller.dispose();
    for (var controller in _ecRelationshipControllers) controller.dispose();
    for (var controller in _ecPhoneControllers) controller.dispose();
    for (var controller in _ecEmailControllers) controller.dispose();


    super.dispose();
  }

  /// Fetches the user profile from ProfileManager.
  Future<void> _fetchUserProfile() async {
    // Using context.read to get the ProfileManager instance for a one-time operation
    final profileManager = context.read<ProfileManager>();
    await profileManager.fetchProfile();
    // After fetching, populate controllers. Listen to profileManager for updates.
    // _populateControllers will be called via Consumer/Selector or in didChangeDependencies
  }

  /// Saves or updates the user profile via ProfileManager.
  Future<void> _saveUserProfile() async {
    // Validate the form before saving
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect data from controllers into a new UserProfile object
    UserProfile updatedProfile = UserProfile(
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _genderController.text.trim(),
      primaryPhoneNumber: _primaryPhoneController.text.trim(),
      alternatePhoneNumber: _alternatePhoneController.text.trim(),
      email: _emailController.text.trim(), // Email comes from Auth user, but can be displayed
      vehicleNumberPlate: _vehiclePlateController.text.trim(),
      vehicleType: _vehicleTypeController.text.trim(),
      vehicleMakeModel: _vehicleMakeModelController.text.trim(),
      vehicleColor: _vehicleColorController.text.trim(),
      insuranceProvider: _insuranceProviderController.text.trim(),
      insurancePolicyNo: _insurancePolicyController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      knownAllergies: _knownAllergiesController.text.trim(),
      medicalConditions: _medicalConditionsController.text.trim(),
      medications: _medicationsController.text.trim(),
      homeAddress: _homeAddressController.text.trim(),
      preferredHospital: _preferredHospitalController.text.trim(),
      // Profile photo URL needs to be handled separately (e.g., upload to storage and save URL)
      // For now, assuming it's not directly editable in the text fields
      profilePhotoUrl: context.read<ProfileManager>().userProfile?.profilePhotoUrl,
    );

    // Update emergency contacts from controllers
    List<Map<String, String>> emergencyContactsList = [];
    for (int i = 0; i < _ecNameControllers.length; i++) {
      if (_ecNameControllers[i].text.isNotEmpty ||
          _ecRelationshipControllers[i].text.isNotEmpty ||
          _ecPhoneControllers[i].text.isNotEmpty ||
          _ecEmailControllers[i].text.isNotEmpty) {
        emergencyContactsList.add({
          'name': _ecNameControllers[i].text.trim(),
          'relationship': _ecRelationshipControllers[i].text.trim(),
          'phone': _ecPhoneControllers[i].text.trim(),
          'email': _ecEmailControllers[i].text.trim(),
        });
      }
    }
    updatedProfile.emergencyContacts = emergencyContactsList;

    final profileManager = context.read<ProfileManager>(); // Using context.read
    try {
      await profileManager.saveProfile(updatedProfile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Opens a date picker for DOB selection.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Adds a new set of emergency contact input fields.
  void _addEmergencyContactField() {
    setState(() {
      _ecNameControllers.add(TextEditingController());
      _ecRelationshipControllers.add(TextEditingController());
      _ecPhoneControllers.add(TextEditingController());
      _ecEmailControllers.add(TextEditingController());
    });
  }

  /// Removes an emergency contact input field at a specific index.
  void _removeEmergencyContactField(int index) {
    setState(() {
      _ecNameControllers[index].dispose();
      _ecRelationshipControllers[index].dispose();
      _ecPhoneControllers[index].dispose();
      _ecEmailControllers[index].dispose();

      _ecNameControllers.removeAt(index);
      _ecRelationshipControllers.removeAt(index);
      _ecPhoneControllers.removeAt(index);
      _ecEmailControllers.removeAt(index);
    });
  }

  /// Builds a section title.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// Builds a single text input field with common styling.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap, // Added onTap for DOB picker
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly || !_isEditing,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onTap: readOnly || !_isEditing ? null : onTap, // Only allow onTap if not readOnly and in editing mode
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          filled: true,
          fillColor: (readOnly || !_isEditing) ? Colors.grey[200] : Colors.white,
        ),
      ),
    );
  }

  /// Builds a dropdown input field.
  Widget _buildDropdownField({
    required String labelText,
    required TextEditingController controller,
    required List<String> options,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IgnorePointer( // Prevent interaction if not editing
        ignoring: !_isEditing,
        child: DropdownButtonFormField<String>(
          value: options.contains(controller.text) ? controller.text : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[200],
          ),
          hint: Text('Select $labelText'),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _isEditing ? (String? newValue) {
            if (newValue != null) {
              setState(() {
                controller.text = newValue;
              });
            }
          } : null, // Disable onChanged if not editing
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileManager>(
      builder: (context, profileManager, child) {
        // Update controllers when profile data changes in ProfileManager
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _populateControllers(profileManager.userProfile);
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Profile'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              // Edit/Cancel button
              _isEditing
                  ? IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: profileManager.isLoading
                    ? null
                    : () {
                  // Discard changes by re-populating with current profile data
                  _populateControllers(profileManager.userProfile);
                  setState(() {
                    _isEditing = false;
                  });
                },
              )
                  : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: profileManager.isLoading
                    ? null
                    : () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              // Save button
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: profileManager.isLoading ? null : _saveUserProfile,
                ),
            ],
          ),
          body: profileManager.isLoading && profileManager.userProfile == null // Show initial loading spinner
              ? const Center(child: CircularProgressIndicator())
              : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey, // Associate the form key for validation
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Photo (Placeholder)
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: profileManager.userProfile?.profilePhotoUrl != null && profileManager.userProfile!.profilePhotoUrl!.isNotEmpty
                                      ? NetworkImage(profileManager.userProfile!.profilePhotoUrl!) as ImageProvider
                                      : const AssetImage('assets/default_avatar.png'), // Placeholder image
                                  child: profileManager.userProfile?.profilePhotoUrl == null || profileManager.userProfile!.profilePhotoUrl!.isEmpty
                                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                                      : null,
                                ),
                                if (_isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 30),
                                      onPressed: () {
                                        // TODO: Implement image picking and upload to Firebase Storage logic
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Image picking not implemented yet!')),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Basic User Information
                          _buildSectionTitle('Basic User Information'),
                          _buildTextField(
                            controller: _fullNameController,
                            labelText: 'Full Name',
                            prefixIcon: Icons.person,
                            validator: (value) => value!.isEmpty && _isEditing ? 'Full Name is required' : null,
                          ),
                          _buildTextField(
                            controller: _dobController,
                            labelText: 'Date of Birth',
                            prefixIcon: Icons.calendar_today,
                            readOnly: true, // Make read-only to allow date picker
                            onTap: () => _selectDate(context), // Open date picker on tap
                          ),
                          _buildDropdownField(
                            controller: _genderController,
                            labelText: 'Gender',
                            options: _genderOptions,
                            prefixIcon: Icons.wc,
                          ),
                          _buildTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            prefixIcon: Icons.email,
                            readOnly: true, // Email is typically read-only
                          ),

                          // Contact Details
                          _buildSectionTitle('Contact Details'),
                          _buildTextField(
                            controller: _primaryPhoneController,
                            labelText: 'Primary Phone Number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone,
                            validator: (value) => value!.isEmpty && _isEditing ? 'Primary Phone is required' : null,
                          ),
                          _buildTextField(
                            controller: _alternatePhoneController,
                            labelText: 'Alternate Phone Number (Optional)',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_android,
                          ),

                          // Emergency Contacts
                          _buildSectionTitle('Emergency Contacts'),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _ecNameControllers.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Contact ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      _buildTextField(
                                        controller: _ecNameControllers[index],
                                        labelText: 'Name',
                                        prefixIcon: Icons.person_outline,
                                        validator: (value) => (value!.isEmpty && (_ecRelationshipControllers[index].text.isNotEmpty || _ecPhoneControllers[index].text.isNotEmpty || _ecEmailControllers[index].text.isNotEmpty)) && _isEditing ? 'Name is required' : null,
                                      ),
                                      _buildTextField(
                                        controller: _ecRelationshipControllers[index],
                                        labelText: 'Relationship',
                                        prefixIcon: Icons.people_alt_outlined,
                                      ),
                                      _buildTextField(
                                        controller: _ecPhoneControllers[index],
                                        labelText: 'Phone Number',
                                        keyboardType: TextInputType.phone,
                                        prefixIcon: Icons.phone,
                                        validator: (value) => (value!.isEmpty && (_ecNameControllers[index].text.isNotEmpty || _ecRelationshipControllers[index].text.isNotEmpty || _ecEmailControllers[index].text.isNotEmpty)) && _isEditing ? 'Phone is required' : null,
                                      ),
                                      _buildTextField(
                                        controller: _ecEmailControllers[index],
                                        labelText: 'Email (Optional)',
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined,
                                      ),
                                      if (_isEditing && _ecNameControllers.length > 2) // Allow removing if more than 2
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            label: const Text('Remove Contact', style: TextStyle(color: Colors.red)),
                                            onPressed: profileManager.isLoading ? null : () => _removeEmergencyContactField(index),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Emergency Contact'),
                                onPressed: profileManager.isLoading ? null : _addEmergencyContactField,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Vehicle Information
                          _buildSectionTitle('Vehicle Information'),
                          _buildTextField(
                            controller: _vehiclePlateController,
                            labelText: 'Vehicle Number Plate',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          _buildDropdownField(
                            controller: _vehicleTypeController,
                            labelText: 'Vehicle Type',
                            options: _vehicleTypeOptions,
                            prefixIcon: Icons.directions_car,
                          ),
                          _buildTextField(
                            controller: _vehicleMakeModelController,
                            labelText: 'Make & Model',
                            prefixIcon: Icons.branding_watermark,
                          ),
                          _buildDropdownField(
                            controller: _vehicleColorController,
                            labelText: 'Color',
                            options: _vehicleColorOptions,
                            prefixIcon: Icons.color_lens_outlined,
                          ),
                          _buildTextField(
                            controller: _insuranceProviderController,
                            labelText: 'Insurance Provider (Optional)',
                            prefixIcon: Icons.local_activity_outlined,
                          ),
                          _buildTextField(
                            controller: _insurancePolicyController,
                            labelText: 'Insurance Policy No. (Optional)',
                            prefixIcon: Icons.policy_outlined,
                          ),

                          // Medical Info
                          _buildSectionTitle('Medical Information'),
                          _buildDropdownField(
                            controller: _bloodGroupController,
                            labelText: 'Blood Group',
                            options: _bloodGroupOptions,
                            prefixIcon: Icons.bloodtype,
                          ),
                          _buildTextField(
                            controller: _knownAllergiesController,
                            labelText: 'Known Allergies',
                            maxLines: 3,
                            prefixIcon: Icons.medical_services_outlined,
                          ),
                          _buildTextField(
                            controller: _medicalConditionsController,
                            labelText: 'Medical Conditions',
                            maxLines: 3,
                            prefixIcon: Icons.local_hospital_outlined,
                          ),
                          _buildTextField(
                            controller: _medicationsController,
                            labelText: 'Medications Currently Taking',
                            maxLines: 3,
                            prefixIcon: Icons.medication_outlined,
                          ),

                          // Location Info
                          _buildSectionTitle('Location Information'),
                          _buildTextField(
                            controller: _homeAddressController,
                            labelText: 'Home Address',
                            maxLines: 3,
                            prefixIcon: Icons.home,
                          ),
                          _buildTextField(
                            controller: _preferredHospitalController,
                            labelText: 'Preferred Hospital (Optional)',
                            prefixIcon: Icons.health_and_safety_outlined,
                          ),

                          // 🛡️ Security & Verification
                          _buildSectionTitle('Security & Verification'),
                          // Removed email verification status display as requested
                          // Removed direct SwitchListTile for biometric as it's not implemented for storage
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
