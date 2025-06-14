import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:grad_project/core/firestoreServices/usersData.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;

  void _submitPost() async {
    if (_controller.text.trim().isEmpty && _pickedImage == null) return;

    setState(() => _isLoading = true);

    try {
      await PostService.uploadPost(
        text: _controller.text.trim(),
        imageFile: _pickedImage,
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Post upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload post')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_pickedImage != null) Image.file(_pickedImage!, height: 150),
            PopupMenuButton<String>(
              color: Theme.of(context).colorScheme.primaryContainer,
              onSelected: (value) async {
                final ImageSource source =
                    value == 'camera'
                        ? ImageSource.camera
                        : ImageSource.gallery;

                final picked = await ImagePicker().pickImage(source: source);
                if (picked != null && mounted) {
                  setState(() => _pickedImage = File(picked.path));
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'gallery',
                      child: ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Gallery'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'camera',
                      child: ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Camera'),
                      ),
                    ),
                  ],
              child: TextButton.icon(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  'Add Image',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed:
                    null,
              ),
            ),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitPost,
              icon: const Icon(Icons.upload),
              label: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
