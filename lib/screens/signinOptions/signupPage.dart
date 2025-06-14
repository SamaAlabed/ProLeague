import 'package:flutter/material.dart';
import 'dart:io';

import 'package:grad_project/core/models/customTextField.dart';
import 'package:grad_project/core/models/CustomButtons.dart';
import 'package:grad_project/screens/signinOptions/loginPage.dart';
import 'package:grad_project/screens/signinOptions/verifyEmailPage.dart';
import 'package:grad_project/core/widgets/imageInput.dart';
import 'package:grad_project/core/firestoreServices/usersData.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;
  bool _showPassword1 = false;
  bool _showPassword2 = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  Future<void> _signup() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid || _pickedImage == null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final errorMessage = await UserSignupService.signupUser(
      username: username.text,
      email: email.text,
      password: password.text,
      pickedImage: _pickedImage!,
      role: 'user',
    );

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const VerifyEmailPage()),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Signup'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.sports_soccer,
                  color: const Color(0xFF363272),
                  size: 500,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageInput(
                        onImagePick: (pickedImage) {
                          setState(() {
                            _pickedImage = pickedImage;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: username,
                        hintText: 'Username',
                        label: 'Full Name',
                        prefixIcon: Icons.person_3_outlined,
                        validator: (value) {
                          if (value == null || value.trim().length < 4) {
                            return 'Please enter at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: email,
                        hintText: 'Example@gmail.com',
                        label: 'Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: password,
                        hintText: '********',
                        label: 'Password',
                        prefixIcon: Icons.lock,
                        obscureText: !_showPassword1,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword1
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                            r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$',
                          ).hasMatch(value)) {
                            return 'Password must be at least 8 characters, with upper, lower case and a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: confirmPassword,
                        hintText: '********',
                        label: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_showPassword2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword2
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                          } else if (value != password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      else
                        CustomElevatedButton(
                          title: 'Signup',
                          onPressed: _signup,
                        ),
                      const SizedBox(height: 16),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
