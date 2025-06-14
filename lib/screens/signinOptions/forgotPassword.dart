import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:grad_project/core/models/customTextField.dart';
import 'package:grad_project/core/models/CustomButtons.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              title: Text(
                "Check your email",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              content: Text(
                "A reset link has been sent to $email.\n\nOnce you've reset your password, click below to return to login.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back to Login",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E3ED), // Light grey box
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E174D),
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset('assets/images/forgot_password.jpg', height: 180),
                const SizedBox(height: 15),
                const Text(
                  "Please Enter Your Email Address to recieve a Verfication Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF1E174D), fontSize: 14),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'example@email.com',
                    label: 'Confirm your email',
                    prefixIcon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 25),
                CustomElevatedButton(
                  title: 'Reset My Password',
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
