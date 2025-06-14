import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onImagePick});

  final void Function(File pickedImage) onImagePick;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImageFile;

  Future<void> _selectImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
      maxHeight: 200,
      maxWidth: 200,
      imageQuality: 50,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImageFile = File(pickedImage.path);
    });

    widget.onImagePick(_selectedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey.shade300,
          foregroundImage:
              _selectedImageFile != null
                  ? FileImage(_selectedImageFile!)
                  : null,
          child:
              _selectedImageFile == null
                  ? Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                  : null,
        ),
        const SizedBox(height: 10),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'gallery') {
              _selectImage(ImageSource.gallery);
            } else if (value == 'camera') {
              _selectImage(ImageSource.camera);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'gallery',
                  child: Row(
                    children: [
                      Icon(Icons.photo),
                      SizedBox(width: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
              ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_a_photo),
                SizedBox(width: 8),
                Text('Select Image'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
