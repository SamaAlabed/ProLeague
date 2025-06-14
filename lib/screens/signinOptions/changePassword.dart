import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/core/models/customTextField.dart';
import 'package:grad_project/screens/signinOptions/loginPage.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _showPassword1 = false;
  bool _showPassword2 = false;
  bool _showCurrentPassword = false;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("New passwords do not match.");
      return;
    }

    if (newPassword.length < 6) {
      _showMessage("New password must be at least 6 characters.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("No user is signed in.");
        return;
      }

      final email = user.email;
      if (email == null) {
        _showMessage("User email is missing.");
        return;
      }

      // Reauthenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _showMessage("Password changed successfully.");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showMessage("Incorrect current password.");
      } else if (e.code == 'requires-recent-login') {
        _showMessage("Please log in again to change your password.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        _showMessage("Firebase error: ${e.message}");
      }
    } catch (e) {
      _showMessage("Something went wrong: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFFA998F4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create New Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset("assets/images/change_password.jpg", height: 130),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _currentPasswordController,
                hintText: 'Current Password',
                label: 'Current Password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showCurrentPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _newPasswordController,
                hintText: 'New Password',
                label: 'New Password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword1,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword1 ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword1 = !_showPassword1;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (!RegExp(
                    r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$',
                  ).hasMatch(value)) {
                    return 'Password must be at least 8 characters\nwith upper, lower case and a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword2,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword2 ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword2 = !_showPassword2;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _confirmPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E174D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
