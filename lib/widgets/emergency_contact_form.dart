import 'package:flutter/material.dart';
import 'text_input_field.dart'; // Import your reusable text input field

class EmergencyContactForm extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController relationshipController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback? onRemove;
  final bool isEditing;

  const EmergencyContactForm({
    super.key,
    required this.index,
    required this.nameController,
    required this.relationshipController,
    required this.phoneController,
    required this.emailController,
    this.onRemove,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextInputField(
              controller: nameController,
              labelText: 'Name',
              prefixIcon: Icons.person_outline,
              readOnly: !isEditing,
              validator: (value) => (value!.isEmpty && (relationshipController.text.isNotEmpty || phoneController.text.isNotEmpty || emailController.text.isNotEmpty)) && isEditing ? 'Name is required' : null,
            ),
            TextInputField(
              controller: relationshipController,
              labelText: 'Relationship',
              prefixIcon: Icons.people_alt_outlined,
              readOnly: !isEditing,
            ),
            TextInputField(
              controller: phoneController,
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              readOnly: !isEditing,
              validator: (value) => (value!.isEmpty && (nameController.text.isNotEmpty || relationshipController.text.isNotEmpty || emailController.text.isNotEmpty)) && isEditing ? 'Phone is required' : null,
            ),
            TextInputField(
              controller: emailController,
              labelText: 'Email (Optional)',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              readOnly: !isEditing,
            ),
            if (isEditing && onRemove != null) // Allow removing if editing and callback provided
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Remove Contact', style: TextStyle(color: Colors.red)),
                  onPressed: onRemove,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
