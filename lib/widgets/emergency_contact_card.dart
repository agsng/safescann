import 'package:flutter/material.dart';
import 'profile_text_field.dart';

class EmergencyContactCard extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController relationshipController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isEditing;
  final bool canDelete;
  final VoidCallback onDelete;

  const EmergencyContactCard({
    super.key,
    required this.index,
    required this.nameController,
    required this.relationshipController,
    required this.phoneController,
    required this.emailController,
    required this.isEditing,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                if (isEditing)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: canDelete ? Colors.red : Colors.grey,
                    ),
                    onPressed: canDelete ? onDelete : null,
                    tooltip: canDelete ? 'Remove contact' : 'At least 1 contact required',
                  ),
              ],
            ),
            ProfileTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.person,
              readOnly: !isEditing,
              validator: (value) {
                if (isEditing && (value == null || value.isEmpty)) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            ProfileTextField(
              controller: relationshipController,
              label: 'Relationship',
              icon: Icons.people,
              readOnly: !isEditing,
            ),
            ProfileTextField(
              controller: phoneController,
              label: 'Phone',
              icon: Icons.phone,
              readOnly: !isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (isEditing && (value == null || value.isEmpty)) {
                  return 'Phone is required';
                }
                return null;
              },
            ),
            ProfileTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
              readOnly: !isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}