import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull extension
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

  // To hold existing vehicle IDs, maintaining the order of the UI list.
  // This is crucial for correctly identifying which vehicle is being edited/deleted.
  final List<String?> _vehicleIdsInUIOrder = [];

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
    _vehicleIdsInUIOrder.clear(); // Clear this tracking list
  }

  Future<void> _fetchVehicles() async {
    final profileManager = context.read<ProfileManager>();
    await profileManager.fetchProfile(); // This will fetch user profile and vehicles
    _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
  }

  void _populateVehicleControllers(UserProfile? profile, List<Vehicle> vehicles) {
    _clearAndDisposeVehicleControllers(); // Clear existing controllers and IDs

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
      // Get assigned name from profile.assignedVehicles map using vehicle.id
      final assignedName = profile.assignedVehicles[vehicle.id] ?? '';
      _vehicleAssignedNameControllers.add(TextEditingController(text: assignedName));

      _vehicleIdsInUIOrder.add(vehicle.id); // Store the actual vehicle ID
    }
    // Ensure at least one empty vehicle field if no vehicles exist or if we're editing and want to add one
    if (_vehicleNumberControllers.isEmpty && _isEditingVehicles) {
      _addVehicleField();
    } else if (_vehicleNumberControllers.isEmpty && !(context.read<ProfileManager>().isLoading)) {
      // If no vehicles and not loading, add one empty field for initial input
      _addVehicleField();
    }
    setState(() {}); // Trigger rebuild after populating
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
      _vehicleIdsInUIOrder.add(null); // Add null for a new vehicle (no ID yet)
    });
  }

  Future<void> _removeVehicleField(int index) async {
    final profileManager = context.read<ProfileManager>();
    final vehicleIdToRemove = _vehicleIdsInUIOrder[index]; // Get the ID directly

    // Dispose controllers first
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

    // Remove from local lists
    setState(() {
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
      _vehicleIdsInUIOrder.removeAt(index); // Remove the ID from tracking list
    });

    if (vehicleIdToRemove != null) {
      try {
        // Call the ProfileManager's delete method which handles Firestore deletions
        // This will delete the vehicle document and its associated data.
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
        if (kDebugMode) {
          print('Error attempting to delete vehicle document in _removeVehicleField: $e');
        }
      }
    } else {
      // This case is for a newly added vehicle that hasn't been saved yet.
      // It just needs to be removed from the UI.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New vehicle removed from UI.'), backgroundColor: Colors.orange),
      );
    }
    // The assignedVehicles map update will happen when _saveVehicles is called.
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
    final authProvider = context.read<CustomAuthProvider>();

    try {
      final ownerUserId = authProvider.user?.uid;
      if (ownerUserId == null) {
        throw Exception("User not logged in. Cannot save vehicles without an owner.");
      }

      Map<String, String> finalAssignedVehiclesMap = {}; // This will hold the complete, final map for UserProfile
      Set<String> currentUIVehicleIds = {}; // Use a Set for efficient lookup of IDs currently in UI

      // --- Step 1: Process Adds and Updates, building the final map ---
      for (int i = 0; i < _vehicleNumberControllers.length; i++) {
        final vehicleNumber = _vehicleNumberControllers[i].text.trim();
        final assignedName = _vehicleAssignedNameControllers[i].text.trim();
        String? vehicleId = _vehicleIdsInUIOrder[i]; // Get the ID for this row (might be null for new)

        if (vehicleNumber.isNotEmpty) { // Only process if vehicle number is not empty
          final type = _vehicleTypeControllers[i].text.trim();
          final brand = _vehicleBrandControllers[i].text.trim();
          final model = _vehicleModelControllers[i].text.trim();
          final color = _vehicleColorControllers[i].text.trim();
          final insuranceProvider = _vehicleInsuranceProviderControllers[i].text.trim();
          final insurancePolicyNo = _vehicleInsurancePolicyNoControllers[i].text.trim();
          final driverUserId = _vehicleDriverUserIdControllers[i].text.trim();
          final notes = _vehicleNotesControllers[i].text.trim();

          Vehicle vehicleToProcess;

          if (vehicleId != null) {
            // This is an existing vehicle, find it in userVehicles to update
            vehicleToProcess = profileManager.userVehicles.firstWhereOrNull(
                  (v) => v.id == vehicleId,
            ) ?? Vehicle(id: vehicleId, vehicleNumber: '', ownerUserId: ownerUserId); // Fallback for safety

            // Update properties of the existing vehicle object
            vehicleToProcess = vehicleToProcess.copyWith(
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
            await profileManager.updateVehicle(vehicleToProcess);
          } else {
            // This is a new vehicle
            vehicleToProcess = Vehicle(
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
            await profileManager.addVehicle(vehicleToProcess); // This will set vehicleToProcess.id and qrCodeUuid
            _vehicleIdsInUIOrder[i] = vehicleToProcess.id; // Update the ID in our local tracking list
          }

          // After add/update, vehicleToProcess.id should be non-null
          if (vehicleToProcess.id != null) {
            finalAssignedVehiclesMap[vehicleToProcess.id!] = assignedName;
            currentUIVehicleIds.add(vehicleToProcess.id!); // Add to list of current UI IDs
          }
        }
      }

      // --- Step 2: Identify and delete vehicles that were removed from the UI ---
      // Compare the original assigned vehicles from the profileManager with the ones currently processed in the UI
      List<String> vehicleIdsToDelete = profileManager.userProfile!.assignedVehicles.keys.where(
              (id) => !currentUIVehicleIds.contains(id)
      ).toList();

      for (String id in vehicleIdsToDelete) {
        // Call deleteVehicle for any IDs that are no longer in the UI's assigned list.
        // The ProfileManager.deleteVehicle will delete the vehicle document and its associated data.
        await profileManager.deleteVehicle(id);
      }

      // --- Step 3: Update the user profile with the new assigned vehicles map ---
      // This single save operation will correctly overwrite the entire assignedVehicles map in Firestore.
      UserProfile updatedProfile = profileManager.userProfile!.copyWith(
        assignedVehicles: finalAssignedVehiclesMap, // Use the map that reflects all adds, updates, and removals
      );
      await profileManager.saveProfile(updatedProfile); // This will now correctly overwrite the assignedVehicles map

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicles saved successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _isEditingVehicles = false;
        // Re-fetch to ensure UI reflects latest state including new IDs and deletions
        _fetchVehicles();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicles: $e'), backgroundColor: Colors.red),
      );
      if (kDebugMode) {
        print('Error in _saveVehicles: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileManager = context.watch<ProfileManager>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only re-populate when not editing, or when profile is null and not loading (initial state)
      if (!_isEditingVehicles && !(profileManager.isLoading)) {
        // Check if current controllers match the actual vehicles.
        // This prevents unnecessary repopulation if state is already correct.
        // A simple length check and checking if any ID is null (meaning a new unsaved vehicle)
        // or if the first vehicle number doesn't match, can indicate a need to repopulate.
        if (_vehicleNumberControllers.length != profileManager.userVehicles.length ||
            _vehicleIdsInUIOrder.any((id) => id == null) ||
            (profileManager.userVehicles.isNotEmpty && _vehicleNumberControllers.isNotEmpty &&
                _vehicleNumberControllers[0].text != profileManager.userVehicles[0].vehicleNumber)
        ) {
          _populateVehicleControllers(profileManager.userProfile, profileManager.userVehicles);
        }
      } else if (profileManager.userProfile == null && !(profileManager.isLoading) && _vehicleNumberControllers.isNotEmpty) {
        // If logged out or no profile, clear controllers
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