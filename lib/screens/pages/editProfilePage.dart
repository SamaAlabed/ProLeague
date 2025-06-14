import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:grad_project/core/firestoreServices/usersData.dart';
import 'package:grad_project/core/widgets/imageInput.dart';
import 'package:grad_project/screens/signinOptions/changePassword.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _imageUrl;
  File? _pickedImage;
  bool _isChangingImage = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = await UserProfileService.loadUserProfile();
    setState(() {
      _usernameController.text = data['username'] ?? '';
      _emailController.text = user.email ?? '';
      _imageUrl = data['imageUrl'];
      _isLoading = false;
    });
  }

  void _handleImagePick(File imageFile) {
    setState(() {
      _pickedImage = imageFile;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      await UserProfileService.updateUserProfile(
        username: _usernameController.text,
        email: _emailController.text,
        newImageFile: _pickedImage,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated. Check your new email for verification.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _isChangingImage
                        ? ImageInput(onImagePick: _handleImagePick)
                        : Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage:
                                  _imageUrl != null
                                      ? NetworkImage(_imageUrl!)
                                      : null,
                              child:
                                  _imageUrl == null
                                      ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      )
                                      : null,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _isChangingImage = true);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              label: Text(
                                'Change Image',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ChangePassword(),
                            ),
                          );
                        },
                        child: Text(
                          'Change Password',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveChanges,
                      icon: const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
