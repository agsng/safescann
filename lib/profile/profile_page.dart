import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../providers/profile_manager.dart';
import '../providers/auth_provider.dart';
import '../widgets/section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _emailController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleColorController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insurancePolicyController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _medicationsController;
  late TextEditingController _homeAddressController;
  late TextEditingController _hospitalController;

  // Dropdown options
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _vehicleTypeOptions = ['Car', 'Motorcycle', 'Truck', 'Van', 'Other'];
  final List<String> _vehicleColorOptions = ['Red', 'Blue', 'Black', 'White', 'Silver', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];

  // Emergency contacts
  final List<TextEditingController> _ecNameControllers = [];
  final List<TextEditingController> _ecRelationshipControllers = [];
  final List<TextEditingController> _ecPhoneControllers = [];
  final List<TextEditingController> _ecEmailControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchProfile();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _primaryPhoneController = TextEditingController();
    _alternatePhoneController = TextEditingController();
    _emailController = TextEditingController();
    _vehiclePlateController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehicleModelController = TextEditingController();
    _vehicleColorController = TextEditingController();
    _insuranceProviderController = TextEditingController();
    _insurancePolicyController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _allergiesController = TextEditingController();
    _conditionsController = TextEditingController();
    _medicationsController = TextEditingController();
    _homeAddressController = TextEditingController();
    _hospitalController = TextEditingController();
  }

  Future<void> _fetchProfile() async {
    final profileManager = Provider.of<ProfileManager>(context, listen: false);
    await profileManager.fetchProfile();
    _populateControllers(profileManager.userProfile);
  }

  void _populateControllers(UserProfile? profile) {
    if (profile == null) return;

    setState(() {
      _fullNameController.text = profile.fullName ?? '';
      _dobController.text = profile.dateOfBirth ?? '';
      _genderController.text = profile.gender ?? '';
      _primaryPhoneController.text = profile.primaryPhoneNumber ?? '';
      _alternatePhoneController.text = profile.alternatePhoneNumber ?? '';
      _emailController.text = profile.email ?? '';
      _vehiclePlateController.text = profile.vehicleNumberPlate ?? '';
      _vehicleTypeController.text = profile.vehicleType ?? '';
      _vehicleModelController.text = profile.vehicleMakeModel ?? '';
      _vehicleColorController.text = profile.vehicleColor ?? '';
      _insuranceProviderController.text = profile.insuranceProvider ?? '';
      _insurancePolicyController.text = profile.insurancePolicyNo ?? '';
      _bloodGroupController.text = profile.bloodGroup ?? '';
      _allergiesController.text = profile.knownAllergies ?? '';
      _conditionsController.text = profile.medicalConditions ?? '';
      _medicationsController.text = profile.medications ?? '';
      _homeAddressController.text = profile.homeAddress ?? '';
      _hospitalController.text = profile.preferredHospital ?? '';

      // Emergency contacts
      _ecNameControllers.clear();
      _ecRelationshipControllers.clear();
      _ecPhoneControllers.clear();
      _ecEmailControllers.clear();

      for (var contact in profile.emergencyContacts) {
        _ecNameControllers.add(TextEditingController(text: contact.name));
        _ecRelationshipControllers.add(TextEditingController(text: contact.relationship));
        _ecPhoneControllers.add(TextEditingController(text: contact.phone));
        _ecEmailControllers.add(TextEditingController(text: contact.email));
      }

      // Ensure at least 2 emergency contacts
      while (_ecNameControllers.length < 2) {
        _addEmergencyContact();
      }
    });
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
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addEmergencyContact() {
    setState(() {
      _ecNameControllers.add(TextEditingController());
      _ecRelationshipControllers.add(TextEditingController());
      _ecPhoneControllers.add(TextEditingController());
      _ecEmailControllers.add(TextEditingController());
    });
  }

  void _removeEmergencyContact(int index) {
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    final profileManager = Provider.of<ProfileManager>(context, listen: false);
    final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);

    try {
      List<EmergencyContact> emergencyContacts = [];
      for (int i = 0; i < _ecNameControllers.length; i++) {
        emergencyContacts.add(EmergencyContact(
          name: _ecNameControllers[i].text,
          relationship: _ecRelationshipControllers[i].text,
          phone: _ecPhoneControllers[i].text,
          email: _ecEmailControllers[i].text,
        ));
      }

      UserProfile updatedProfile = UserProfile(
        uid: authProvider.user?.uid,
        fullName: _fullNameController.text,
        email: _emailController.text,
        dateOfBirth: _dobController.text,
        gender: _genderController.text,
        primaryPhoneNumber: _primaryPhoneController.text,
        alternatePhoneNumber: _alternatePhoneController.text,
        emergencyContacts: emergencyContacts,
        vehicleNumberPlate: _vehiclePlateController.text,
        vehicleType: _vehicleTypeController.text,
        vehicleMakeModel: _vehicleModelController.text,
        vehicleColor: _vehicleColorController.text,
        insuranceProvider: _insuranceProviderController.text,
        insurancePolicyNo: _insurancePolicyController.text,
        bloodGroup: _bloodGroupController.text,
        knownAllergies: _allergiesController.text,
        medicalConditions: _conditionsController.text,
        medications: _medicationsController.text,
        homeAddress: _homeAddressController.text,
        preferredHospital: _hospitalController.text,
      );

      await profileManager.saveProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
      }
    }
  }

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
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _homeAddressController.dispose();
    _hospitalController.dispose();

    for (var controller in _ecNameControllers) controller.dispose();
    for (var controller in _ecRelationshipControllers) controller.dispose();
    for (var controller in _ecPhoneControllers) controller.dispose();
    for (var controller in _ecEmailControllers) controller.dispose();

    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: !_isEditing,
          fillColor: Colors.grey[200],
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onTap: onTap,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: !_isEditing,
          fillColor: Colors.grey[200],
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: _isEditing
            ? (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
          }
        }
            : null,
        validator: validator,
      ),
    );
  }

  Widget _buildEmergencyContact(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emergency Contact ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_isEditing && _ecNameControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEmergencyContact(index),
                  ),
              ],
            ),
            _buildTextField(
              controller: _ecNameControllers[index],
              label: 'Name',
              icon: Icons.person,
              readOnly: !_isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _ecRelationshipControllers[index],
              label: 'Relationship',
              icon: Icons.people,
              readOnly: !_isEditing,
            ),
            _buildTextField(
              controller: _ecPhoneControllers[index],
              label: 'Phone',
              icon: Icons.phone,
              readOnly: !_isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Phone is required';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _ecEmailControllers[index],
              label: 'Email',
              icon: Icons.email,
              readOnly: !_isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileManager = Provider.of<ProfileManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() {
                _isEditing = true;
                _populateControllers(profileManager.userProfile);
              }),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => setState(() {
                _isEditing = false;
                _populateControllers(profileManager.userProfile);
              }),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: profileManager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 30),
                          onPressed: _pickImage,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Basic Information
              const SectionTitle(title: 'Basic Information'),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                readOnly: !_isEditing,
                validator: (value) {
                  if (_isEditing && (value == null || value.isEmpty)) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _isEditing ? () => _selectDate(context) : null,
              ),
              _buildDropdown(
                controller: _genderController,
                label: 'Gender',
                options: _genderOptions,
                icon: Icons.wc,
              ),

              // Contact Details
              const SectionTitle(title: 'Contact Details'),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                readOnly: !_isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (_isEditing && (value == null || value.isEmpty)) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _primaryPhoneController,
                label: 'Primary Phone',
                icon: Icons.phone,
                readOnly: !_isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (_isEditing && (value == null || value.isEmpty)) {
                    return 'Primary phone is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _alternatePhoneController,
                label: 'Alternate Phone',
                icon: Icons.phone_android,
                readOnly: !_isEditing,
                keyboardType: TextInputType.phone,
              ),

              // Emergency Contacts
              const SectionTitle(title: 'Emergency Contacts'),
              ...List.generate(_ecNameControllers.length,
                      (index) => _buildEmergencyContact(index)),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _addEmergencyContact,
                  child: const Text('Add Emergency Contact'),
                ),

              // Vehicle Information
              const SectionTitle(title: 'Vehicle Information'),
              _buildTextField(
                controller: _vehiclePlateController,
                label: 'License Plate',
                icon: Icons.directions_car,
                readOnly: !_isEditing,
              ),
              _buildDropdown(
                controller: _vehicleTypeController,
                label: 'Vehicle Type',
                options: _vehicleTypeOptions,
                icon: Icons.directions_car,
              ),
              _buildTextField(
                controller: _vehicleModelController,
                label: 'Make & Model',
                icon: Icons.branding_watermark,
                readOnly: !_isEditing,
              ),
              _buildDropdown(
                controller: _vehicleColorController,
                label: 'Color',
                options: _vehicleColorOptions,
                icon: Icons.color_lens,
              ),
              _buildTextField(
                controller: _insuranceProviderController,
                label: 'Insurance Provider',
                icon: Icons.medical_services,
                readOnly: !_isEditing,
              ),
              _buildTextField(
                controller: _insurancePolicyController,
                label: 'Policy Number',
                icon: Icons.note,
                readOnly: !_isEditing,
              ),

              // Medical Information
              const SectionTitle(title: 'Medical Information'),
              _buildDropdown(
                controller: _bloodGroupController,
                label: 'Blood Group',
                options: _bloodGroupOptions,
                icon: Icons.bloodtype,
              ),
              _buildTextField(
                controller: _allergiesController,
                label: 'Known Allergies',
                icon: Icons.warning,
                readOnly: !_isEditing,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _conditionsController,
                label: 'Medical Conditions',
                icon: Icons.medical_information,
                readOnly: !_isEditing,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _medicationsController,
                label: 'Current Medications',
                icon: Icons.medication,
                readOnly: !_isEditing,
                maxLines: 3,
              ),

              // Location Information
              const SectionTitle(title: 'Location Information'),
              _buildTextField(
                controller: _homeAddressController,
                label: 'Home Address',
                icon: Icons.home,
                readOnly: !_isEditing,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _hospitalController,
                label: 'Preferred Hospital',
                icon: Icons.local_hospital,
                readOnly: !_isEditing,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}