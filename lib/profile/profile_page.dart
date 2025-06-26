import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import the new models
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';

// Import your providers
import '../providers/profile_manager.dart';
import '../providers/auth_provider.dart';

// Import your reusable widgets (using the specific names from your provided files)
import '../widgets/profle_section_title.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/profile_dropdown.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/profile_image_picker.dart';
// import '../widgets/vehicle_card.dart'; // No longer directly used for display in ProfilePage

// Import the new vehicle management page
import '../pages/vehicle_management_page.dart'; // NEW import


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  File? _profileImage; // TODO: Implement Firebase Storage upload for this
  final ImagePicker _picker = ImagePicker();

  // Text controllers for basic user information
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _emailController;

  // Text controllers for medical information
  late TextEditingController _bloodGroupController;
  late TextEditingController _knownAllergiesController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _medicationsController;

  // Text controllers for location information
  late TextEditingController _homeAddressController;
  late TextEditingController _preferredHospitalController;

  // Lists for dropdown options (can be moved to utils/app_constants.dart eventually)
  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to disclose'];
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
    _fetchProfile(); // Initial fetch of profile data
  }

  /// Initializes all text controllers.
  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _primaryPhoneController = TextEditingController();
    _emailController = TextEditingController();

    _bloodGroupController = TextEditingController();
    _knownAllergiesController = TextEditingController();
    _medicalConditionsController = TextEditingController();
    _medicationsController = TextEditingController();

    _homeAddressController = TextEditingController();
    _preferredHospitalController = TextEditingController();

    // Initialize at least two empty emergency contact fields
    for (int i = 0; i < 2; i++) {
      _addEmergencyContactField();
    }
  }

  /// Populates text controllers with data from UserProfile.
  /// Vehicle data is handled by VehicleManagementPage.
  void _populateControllers(UserProfile? profile) {
    if (profile == null) return;

    final authProvider = context.read<CustomAuthProvider>();

    _fullNameController.text = profile.fullName ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
    _genderController.text = profile.gender ?? '';
    _primaryPhoneController.text = profile.primaryPhoneNumber ?? '';
    _emailController.text = authProvider.user?.email ?? profile.email ?? '';

    _bloodGroupController.text = profile.bloodGroup ?? '';
    _knownAllergiesController.text = profile.knownAllergies ?? '';
    _medicalConditionsController.text = profile.medicalConditions ?? '';
    _medicationsController.text = profile.medications ?? '';

    _homeAddressController.text = profile.homeAddress ?? '';
    _preferredHospitalController.text = profile.preferredHospital ?? '';

    // Clear and re-add emergency contact controllers for simplicity in populate
    _clearAndDisposeEmergencyContactControllers();
    for (var contact in profile.emergencyContacts) {
      _ecNameControllers.add(TextEditingController(text: contact.name ?? ''));
      _ecRelationshipControllers.add(TextEditingController(text: contact.relationship ?? ''));
      _ecPhoneControllers.add(TextEditingController(text: contact.phone ?? ''));
      _ecEmailControllers.add(TextEditingController(text: contact.email ?? ''));
    }
    while (_ecNameControllers.length < 2) { // Ensure at least 2 empty fields
      _addEmergencyContactField();
    }
  }

  void _clearAndDisposeEmergencyContactControllers() {
    for (var controller in _ecNameControllers) controller.dispose();
    for (var controller in _ecRelationshipControllers) controller.dispose();
    for (var controller in _ecPhoneControllers) controller.dispose();
    for (var controller in _ecEmailControllers) controller.dispose();
    _ecNameControllers.clear();
    _ecRelationshipControllers.clear();
    _ecPhoneControllers.clear();
    _ecEmailControllers.clear();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _primaryPhoneController.dispose();
    _emailController.dispose();

    _bloodGroupController.dispose();
    _knownAllergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();

    _homeAddressController.dispose();
    _preferredHospitalController.dispose();

    _clearAndDisposeEmergencyContactControllers();

    super.dispose();
  }

  /// Fetches the user profile and their associated vehicles from ProfileManager.
  /// Note: Vehicles are now fetched primarily for summary display on this page.
  Future<void> _fetchProfile() async {
    final profileManager = context.read<ProfileManager>();
    await profileManager.fetchProfile(); // This fetches both UserProfile and Vehicles
    _populateControllers(profileManager.userProfile); // Only pass UserProfile for general fields
    // Vehicles are read directly from profileManager.userVehicles in the build method for display
  }

  /// Saves or updates the user profile via ProfileManager.
  /// Vehicle data is exclusively managed in VehicleManagementPage.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profileManager = context.read<ProfileManager>();
    final authProvider = context.read<CustomAuthProvider>();

    try {
      // 1. Prepare Emergency Contacts
      List<EmergencyContact> emergencyContactsList = [];
      for (int i = 0; i < _ecNameControllers.length; i++) {
        if (_ecNameControllers[i].text.isNotEmpty ||
            _ecRelationshipControllers[i].text.isNotEmpty ||
            _ecPhoneControllers[i].text.isNotEmpty ||
            _ecEmailControllers[i].text.isNotEmpty) {
          emergencyContactsList.add(
            EmergencyContact(
              name: _ecNameControllers[i].text.trim(),
              relationship: _ecRelationshipControllers[i].text.trim(),
              phone: _ecPhoneControllers[i].text.trim(),
              email: _ecEmailControllers[i].text.trim(),
            ),
          );
        }
      }

      // Get current user's UID
      final ownerUserId = authProvider.user?.uid;
      if (ownerUserId == null) {
        throw Exception("User not logged in. Cannot save profile.");
      }

      // 2. Prepare and Save UserProfile data
      UserProfile updatedProfile = UserProfile(
        uid: ownerUserId,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        gender: _genderController.text.trim(),
        primaryPhoneNumber: _primaryPhoneController.text.trim(),
        email: _emailController.text.trim(),
        bloodGroup: _bloodGroupController.text.trim(),
        knownAllergies: _knownAllergiesController.text.trim(),
        medicalConditions: _medicalConditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
        homeAddress: _homeAddressController.text.trim(),
        preferredHospital: _preferredHospitalController.text.trim(),
        profilePhotoUrl: profileManager.userProfile?.profilePhotoUrl,
        emergencyContacts: emergencyContactsList,
        // The assignedVehicles map is now managed by VehicleManagementPage and fetched here.
        // We ensure we send back the current state of assignedVehicles from the manager.
        assignedVehicles: profileManager.userProfile?.assignedVehicles ?? {},
      );

      await profileManager.saveProfile(updatedProfile);


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _isEditing = false;
        // Re-fetch to ensure UI reflects latest state from DB
        _fetchProfile();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // TODO: Upload to Firebase Storage and update profile
    }
  }

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

  void _addEmergencyContactField() {
    setState(() {
      _ecNameControllers.add(TextEditingController());
      _ecRelationshipControllers.add(TextEditingController());
      _ecPhoneControllers.add(TextEditingController());
      _ecEmailControllers.add(TextEditingController());
    });
  }

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


  @override
  Widget build(BuildContext context) {
    final profileManager = context.watch<ProfileManager>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only populate basic controllers and emergency contacts here
      if (!_isEditing) {
        _populateControllers(profileManager.userProfile); // Pass only UserProfile
      } else if (profileManager.userProfile == null && !profileManager.isLoading) {
        _populateControllers(null); // Pass null if profile is not available
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isEditing
              ? IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: profileManager.isLoading
                ? null
                : () {
              setState(() {
                _isEditing = false;
                // Re-populate from the last fetched state to discard unsaved changes
                _populateControllers(profileManager.userProfile);
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
                // Re-populate on entering edit mode to ensure latest saved data
                _populateControllers(profileManager.userProfile);
              });
            },
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: profileManager.isLoading ? null : _saveProfile,
            ),
        ],
      ),
      body: profileManager.isLoading && profileManager.userProfile == null
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ProfileImagePicker(
                          profileImage: _profileImage,
                          isEditing: _isEditing,
                          onPickImage: _pickImage,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SectionTitle(title: 'Basic User Information'),
                      ProfileTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        readOnly: !_isEditing,
                        validator: (value) => (value?.isEmpty ?? true) && _isEditing ? 'Full Name is required' : null,
                      ),
                      ProfileTextField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: _isEditing ? () => _selectDate(context) : null,
                      ),
                      ProfileDropdown(
                        controller: _genderController,
                        label: 'Gender',
                        options: _genderOptions,
                        icon: Icons.wc,
                        isEditing: _isEditing,
                      ),
                      ProfileTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        readOnly: !_isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value?.isEmpty ?? true) && _isEditing ? 'Email is required' : null,
                      ),

                      SectionTitle(title: 'Contact Details'),
                      ProfileTextField(
                        controller: _primaryPhoneController,
                        label: 'Primary Phone Number',
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                        readOnly: !_isEditing,
                        validator: (value) => (value?.isEmpty ?? true) && _isEditing ? 'Primary Phone is required' : null,
                      ),

                      SectionTitle(title: 'Emergency Contacts'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ecNameControllers.length,
                        itemBuilder: (context, index) {
                          return EmergencyContactCard(
                            index: index,
                            nameController: _ecNameControllers[index],
                            relationshipController: _ecRelationshipControllers[index],
                            phoneController: _ecPhoneControllers[index],
                            emailController: _ecEmailControllers[index],
                            isEditing: _isEditing,
                            canDelete: _ecNameControllers.length > 2,
                            onDelete: () => _removeEmergencyContactField(index),
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

                      // Display registered vehicles summary and "Manage Vehicles" button
                      SectionTitle(title: 'Registered Vehicles'),
                      if (profileManager.userVehicles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            _isEditing ? 'Add vehicles via "Manage Vehicles" button.' : 'No vehicles registered.',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: profileManager.userVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = profileManager.userVehicles[index];
                            final assignedName = profileManager.userProfile?.assignedVehicles[vehicle.id] ?? 'N/A';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                leading: const Icon(Icons.directions_car, color: Colors.blue),
                                title: Text(
                                  'Plate: ${vehicle.vehicleNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Assigned To: $assignedName'),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.car_rental),
                          label: const Text('Manage Vehicles'),
                          onPressed: profileManager.isLoading
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VehicleManagementPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SectionTitle(title: 'Medical Information'),
                      ProfileDropdown(
                        controller: _bloodGroupController,
                        label: 'Blood Group',
                        options: _bloodGroupOptions,
                        icon: Icons.bloodtype,
                        isEditing: _isEditing,
                      ),
                      ProfileTextField(
                        controller: _knownAllergiesController,
                        label: 'Known Allergies',
                        maxLines: 3,
                        icon: Icons.medical_services_outlined,
                        readOnly: !_isEditing,
                      ),
                      ProfileTextField(
                        controller: _medicalConditionsController,
                        label: 'Medical Conditions',
                        maxLines: 3,
                        icon: Icons.local_hospital_outlined,
                        readOnly: !_isEditing,
                      ),
                      ProfileTextField(
                        controller: _medicationsController,
                        label: 'Medications Currently Taking',
                        maxLines: 3,
                        icon: Icons.medication_outlined,
                        readOnly: !_isEditing,
                      ),

                      SectionTitle(title: 'Location Information'),
                      ProfileTextField(
                        controller: _homeAddressController,
                        label: 'Home Address',
                        maxLines: 3,
                        icon: Icons.home,
                        readOnly: !_isEditing,
                      ),
                      ProfileTextField(
                        controller: _preferredHospitalController,
                        label: 'Preferred Hospital (Optional)',
                        icon: Icons.health_and_safety_outlined,
                        readOnly: !_isEditing,
                      ),

                      SectionTitle(title: 'Security & Verification'),
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
  }
}
