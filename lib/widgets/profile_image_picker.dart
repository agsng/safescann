import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final bool isEditing;
  final Function() onPickImage;

  const ProfileImagePicker({
    super.key,
    required this.profileImage,
    required this.isEditing,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: profileImage != null
              ? FileImage(profileImage!)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          child: profileImage == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 30),
              onPressed: onPickImage,
            ),
          ),
      ],
    );
  }
}