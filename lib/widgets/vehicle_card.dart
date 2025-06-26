import 'package:flutter/material.dart';
import 'package:safescann/widgets/text_input_field.dart';
import 'package:safescann/widgets/dropdown_input_field.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A reusable card widget for displaying and editing vehicle information.
class VehicleCard extends StatelessWidget {
  final int index;
  final TextEditingController vehicleNumberController;
  final TextEditingController typeController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController colorController;
  final TextEditingController insuranceProviderController;
  final TextEditingController insurancePolicyNoController;
  final TextEditingController driverUserIdController; // For owner to assign driver
  final TextEditingController notesController;
  final TextEditingController assignedNameController; // NEW: For the assigned name
  final VoidCallback? onDelete;
  final bool isEditing;

  // Dropdown options (could be fetched from constants or a provider)
  final List<String> vehicleTypeOptions = ['Car', 'Motorcycle', 'Truck', 'Van', 'Bicycle', 'Other'];
  final List<String> vehicleColorOptions = ['Red', 'Blue', 'Black', 'White', 'Silver', 'Grey', 'Green', 'Yellow', 'Orange', 'Brown', 'Purple', 'Gold', 'Other'];

  VehicleCard({
    super.key,
    required this.index,
    required this.vehicleNumberController,
    required this.typeController,
    required this.brandController,
    required this.modelController,
    required this.colorController,
    required this.insuranceProviderController,
    required this.insurancePolicyNoController,
    required this.driverUserIdController,
    required this.notesController,
    required this.assignedNameController, // NEW: Include in constructor
    this.onDelete,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue),
                ),
                if (isEditing && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                    onPressed: onDelete,
                    tooltip: 'Remove Vehicle',
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            TextInputField(
              controller: vehicleNumberController,
              labelText: 'Vehicle Number Plate',
              prefixIcon: Icons.badge_outlined,
              readOnly: !isEditing,
              validator: (value) => (value?.isEmpty ?? true) && isEditing ? 'Vehicle number is required' : null,
            ),
            // New field for assigned name
            TextInputField(
              controller: assignedNameController,
              labelText: 'Assigned Name (e.g., "Dad", "Office Car")',
              prefixIcon: Icons.assignment_ind_outlined,
              readOnly: !isEditing,
              validator: (value) => (value?.isEmpty ?? true) && isEditing ? 'Assigned Name is required' : null,
              notes: "A memorable name or relation for this vehicle.",
            ),
            DropdownInputField(
              controller: typeController,
              labelText: 'Vehicle Type',
              options: vehicleTypeOptions,
              prefixIcon: Icons.directions_car,
              enabled: isEditing,
            ),
            TextInputField(
              controller: brandController,
              labelText: 'Brand',
              prefixIcon: Icons.local_car_wash_outlined,
              readOnly: !isEditing,
            ),
            TextInputField(
              controller: modelController,
              labelText: 'Model',
              prefixIcon: Icons.car_rental,
              readOnly: !isEditing,
            ),
            DropdownInputField(
              controller: colorController,
              labelText: 'Color',
              options: vehicleColorOptions,
              prefixIcon: Icons.color_lens_outlined,
              enabled: isEditing,
            ),
            TextInputField(
              controller: insuranceProviderController,
              labelText: 'Insurance Provider (Optional)',
              prefixIcon: Icons.local_activity_outlined,
              readOnly: !isEditing,
            ),
            TextInputField(
              controller: insurancePolicyNoController,
              labelText: 'Insurance Policy No. (Optional)',
              prefixIcon: Icons.policy_outlined,
              readOnly: !isEditing,
            ),
            TextInputField(
              controller: driverUserIdController,
              labelText: 'Assigned Driver (User ID - Optional)',
              prefixIcon: Icons.person_add_alt_1,
              readOnly: !isEditing,
              notes: "Enter driver's User ID if they are also an app user.",
            ),
            TextInputField(
              controller: notesController,
              labelText: 'Notes (e.g., "Office commute car")',
              prefixIcon: Icons.notes,
              maxLines: 2,
              readOnly: !isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleQRCode(String vehicleUUID) {
    return QrImageView(
      data: vehicleUUID,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
