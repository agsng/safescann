import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/vehicleModel.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_manager.dart';
import '../widgets/profle_section_title.dart';
import '../widgets/vehicle_card.dart'; // Import VehicleCard for this page

class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  _VehicleManagementPageState createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditingVehicles = false; // Separate editing state for this page

  // Lists of controllers for vehicles (managed locally on this page)
  final List<TextEditingController> _vehicleNumberControllers = [];
  final List<TextEditingController> _vehicleTypeControllers = [];
  final List<TextEditingController> _vehicleBrandControllers = [];
  final List<TextEditingController> _vehicleModelControllers = [];
  final List<TextEditingController> _vehicleColorControllers = [];
  final List<TextEditingController> _vehicleInsuranceProviderControllers = [];
  final List<TextEditingController> _vehicleInsurancePolicyNoControllers = [];
  final List<TextEditingController> _vehicleDriverUserIdControllers = [];
  final List<TextEditingController> _vehicleNotesControllers = [];
  final List<TextEditingController> _vehicleAssignedNameControllers = [];

  // To hold existing vehicle IDs
  final Map<String, String> _localAssignedVehicles = {}; // VehicleId -> AssignedName

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  @override
  void dispose() {
    _clearAndDisposeVehicleControllers();
    super.dispose();
  }

  void _clearAndDisposeVehicleControllers() {
    for (var controller in _vehicleNumberControllers) controller.dispose();
    for (var controller in _vehicleTypeControllers) controller.dispose();
    for (var controller in _vehicleBrandControllers) controller.dispose();
    for (var controller in _vehicleModelControllers) controller.dispose();
    for (var controller in _vehicleColorControllers) controller.dispose();
    for (var controller in _vehicleInsuranceProviderControllers) controller.dispose();
    for (var controller in _vehicleInsurancePolicyNoControllers) controller.dispose();
    for (var controller in _vehicleDriverUserIdControllers) controller.dispose();
    for (var controller in _vehicleNotesControllers) controller.dispose();
    for (var controller in _vehicleAssignedNameControllers) controller.dispose();

    _vehicleNumberControllers.clear();
    _vehicleTypeControllers.clear();
    _vehicleBrandControllers.clear();
    _vehicleModelControllers.clear();
    _vehicleColorControllers.clear();
    _vehicleInsuranceProviderControllers.clear();
    _vehicleInsurancePolicyNoControllers.clear();
    _vehicleDriverUserIdControllers.clear();
    _vehicleNotesControllers.clear();
    _vehicleAssignedNameControllers.clear();
    _localAssignedVehicles.clear();
  }

  Future<void> _fetchVehicles() async {
    final profileManager = context.read<ProfileManager>();
    await profileManager.fetchProfile(); // This will fetch user profile and vehicles
    _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
  }

  void _populateVehicleControllers(UserProfile? profile, List<Vehicle> vehicles) {
    _clearAndDisposeVehicleControllers();
    _localAssignedVehicles.clear();

    if (profile == null) return;

    for (var vehicle in vehicles) {
      _vehicleNumberControllers.add(TextEditingController(text: vehicle.vehicleNumber));
      _vehicleTypeControllers.add(TextEditingController(text: vehicle.type));
      _vehicleBrandControllers.add(TextEditingController(text: vehicle.brand));
      _vehicleModelControllers.add(TextEditingController(text: vehicle.model));
      _vehicleColorControllers.add(TextEditingController(text: vehicle.color));
      _vehicleInsuranceProviderControllers.add(TextEditingController(text: vehicle.insuranceProvider));
      _vehicleInsurancePolicyNoControllers.add(TextEditingController(text: vehicle.insurancePolicyNo));
      _vehicleDriverUserIdControllers.add(TextEditingController(text: vehicle.driverUserId));
      _vehicleNotesControllers.add(TextEditingController(text: vehicle.notes));
      final assignedName = profile.assignedVehicles[vehicle.id] ?? '';
      _vehicleAssignedNameControllers.add(TextEditingController(text: assignedName));

      if (vehicle.id != null) {
        _localAssignedVehicles[vehicle.id!] = assignedName;
      }
    }
    // Ensure at least one empty vehicle field if no vehicles
    if (_vehicleNumberControllers.isEmpty) {
      _addVehicleField();
    }
  }

  void _addVehicleField() {
    setState(() {
      _vehicleNumberControllers.add(TextEditingController());
      _vehicleTypeControllers.add(TextEditingController());
      _vehicleBrandControllers.add(TextEditingController());
      _vehicleModelControllers.add(TextEditingController());
      _vehicleColorControllers.add(TextEditingController());
      _vehicleInsuranceProviderControllers.add(TextEditingController());
      _vehicleInsurancePolicyNoControllers.add(TextEditingController());
      _vehicleDriverUserIdControllers.add(TextEditingController());
      _vehicleNotesControllers.add(TextEditingController());
      _vehicleAssignedNameControllers.add(TextEditingController());
    });
  }

  Future<void> _removeVehicleField(int index) async {
    final profileManager = context.read<ProfileManager>();
    final vehicleNumberToRemove = _vehicleNumberControllers[index].text;
    String? vehicleIdToRemove;

    for (var entry in _localAssignedVehicles.entries) {
      if (profileManager.userVehicles.any((v) => v.id == entry.key && v.vehicleNumber == vehicleNumberToRemove)) {
        vehicleIdToRemove = entry.key;
        break;
      }
    }

    setState(() {
      _vehicleNumberControllers[index].dispose();
      _vehicleTypeControllers[index].dispose();
      _vehicleBrandControllers[index].dispose();
      _vehicleModelControllers[index].dispose();
      _vehicleColorControllers[index].dispose();
      _vehicleInsuranceProviderControllers[index].dispose();
      _vehicleInsurancePolicyNoControllers[index].dispose();
      _vehicleDriverUserIdControllers[index].dispose();
      _vehicleNotesControllers[index].dispose();
      _vehicleAssignedNameControllers[index].dispose();

      _vehicleNumberControllers.removeAt(index);
      _vehicleTypeControllers.removeAt(index);
      _vehicleBrandControllers.removeAt(index);
      _vehicleModelControllers.removeAt(index);
      _vehicleColorControllers.removeAt(index);
      _vehicleInsuranceProviderControllers.removeAt(index);
      _vehicleInsurancePolicyNoControllers.removeAt(index);
      _vehicleDriverUserIdControllers.removeAt(index);
      _vehicleNotesControllers.removeAt(index);
      _vehicleAssignedNameControllers.removeAt(index);

      if (vehicleIdToRemove != null) {
        _localAssignedVehicles.remove(vehicleIdToRemove);
      }
    });

    if (vehicleIdToRemove != null) {
      try {
        await profileManager.deleteVehicle(vehicleIdToRemove);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle removed successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove vehicle: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveVehicles() async {
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
    final authProvider = context.read<CustomAuthProvider>(); // Corrected reference

    try {
      final ownerUserId = authProvider.user?.uid;
      if (ownerUserId == null) {
        throw Exception("User not logged in. Cannot save vehicles without an owner.");
      }

      Map<String, String> newAssignedVehicles = {};

      for (int i = 0; i < _vehicleNumberControllers.length; i++) {
        final vehicleNumber = _vehicleNumberControllers[i].text.trim();
        final assignedName = _vehicleAssignedNameControllers[i].text.trim();

        if (vehicleNumber.isNotEmpty) {
          final type = _vehicleTypeControllers[i].text.trim();
          final brand = _vehicleBrandControllers[i].text.trim();
          final model = _vehicleModelControllers[i].text.trim();
          final color = _vehicleColorControllers[i].text.trim();
          final insuranceProvider = _vehicleInsuranceProviderControllers[i].text.trim();
          final insurancePolicyNo = _vehicleInsurancePolicyNoControllers[i].text.trim();
          final driverUserId = _vehicleDriverUserIdControllers[i].text.trim();
          final notes = _vehicleNotesControllers[i].text.trim();

          String? existingVehicleId;
          for (var entry in _localAssignedVehicles.entries) {
            if (profileManager.userVehicles.any((v) => v.id == entry.key && v.vehicleNumber == vehicleNumber)) {
              existingVehicleId = entry.key;
              break;
            }
          }

          Vehicle vehicle = Vehicle(
            id: existingVehicleId,
            vehicleNumber: vehicleNumber,
            type: type.isEmpty ? null : type,
            brand: brand.isEmpty ? null : brand,
            model: model.isEmpty ? null : model,
            color: color.isEmpty ? null : color,
            insuranceProvider: insuranceProvider.isEmpty ? null : insuranceProvider,
            insurancePolicyNo: insurancePolicyNo.isEmpty ? null : insurancePolicyNo,
            ownerUserId: ownerUserId,
            driverUserId: driverUserId.isEmpty ? null : driverUserId,
            isDriverRegistered: driverUserId.isNotEmpty,
            notes: notes.isEmpty ? null : notes,
          );

          if (existingVehicleId != null) {
            await profileManager.updateVehicle(vehicle);
          } else {
            await profileManager.addVehicle(vehicle);
          }
          if (vehicle.id != null) {
            newAssignedVehicles[vehicle.id!] = assignedName;
          }
        }
      }

      // Identify and delete vehicles that were removed from the UI
      List<String> vehiclesToDelete = _localAssignedVehicles.keys.where((id) => !newAssignedVehicles.containsKey(id)).toList();
      for (String id in vehiclesToDelete) {
        await profileManager.deleteVehicle(id);
      }

      // Update the user profile with the new assigned vehicles map
      UserProfile updatedProfile = profileManager.userProfile!.copyWith(
        assignedVehicles: newAssignedVehicles,
      );
      await profileManager.saveProfile(updatedProfile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicles saved successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _isEditingVehicles = false;
        _fetchVehicles(); // Re-fetch to ensure UI reflects latest state
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicles: $e'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileManager = context.watch<ProfileManager>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditingVehicles) {
        _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
      } else if (profileManager.userProfile == null && !profileManager.isLoading) {
        _populateVehicleControllers(null, []);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vehicles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isEditingVehicles
              ? IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: profileManager.isLoading
                ? null
                : () {
              setState(() {
                _isEditingVehicles = false;
                _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
              });
            },
          )
              : IconButton(
            icon: const Icon(Icons.edit),
            onPressed: profileManager.isLoading
                ? null
                : () {
              setState(() {
                _isEditingVehicles = true;
                _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
              });
            },
          ),
          if (_isEditingVehicles)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: profileManager.isLoading ? null : _saveVehicles,
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
                      SectionTitle(title: 'Your Registered Vehicles'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vehicleNumberControllers.length,
                        itemBuilder: (context, index) {
                          return VehicleCard(
                            index: index,
                            vehicleNumberController: _vehicleNumberControllers[index],
                            typeController: _vehicleTypeControllers[index],
                            brandController: _vehicleBrandControllers[index],
                            modelController: _vehicleModelControllers[index],
                            colorController: _vehicleColorControllers[index],
                            insuranceProviderController: _vehicleInsuranceProviderControllers[index],
                            insurancePolicyNoController: _vehicleInsurancePolicyNoControllers[index],
                            driverUserIdController: _vehicleDriverUserIdControllers[index],
                            notesController: _vehicleNotesControllers[index],
                            assignedNameController: _vehicleAssignedNameControllers[index],
                            isEditing: _isEditingVehicles, // Use local editing state
                            onDelete: _vehicleNumberControllers.length > 1 && _isEditingVehicles
                                ? () => _removeVehicleField(index)
                                : null,
                          );
                        },
                      ),
                      if (_isEditingVehicles)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Vehicle'),
                            onPressed: profileManager.isLoading ? null : _addVehicleField,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
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
