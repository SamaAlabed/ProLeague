import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:grad_project/core/models/customTextField.dart';
import 'package:grad_project/core/models/CustomButtons.dart';
import 'package:grad_project/screens/signinOptions/forgotPassword.dart';
import 'package:grad_project/screens/signinOptions/signupPage.dart';
import 'package:grad_project/core/widgets/tabs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => Tabs()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      String message = 'An error occurred. Please try again.';
      if (error.code == 'user-not-found') {
        message = 'User not found.';
      } else if (error.code == 'wrong-password') {
        message = 'Wrong password.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    await FirebaseAnalytics.instance.logLogin(loginMethod: 'email');

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('user_signins')
        .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // خلفية الكرة الرمادية
            Opacity(
              opacity: 0.3,
              child: Align(
                alignment: AlignmentDirectional(0, -1.98),
                child: Icon(
                  Icons.sports_soccer,
                  color: const Color(0xFF363272),
                  size: 500,
                ),
              ),
            ),

            // محاذاة المحتوى للنصف السفلي
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo1.png',
                        height: 159.5,
                        width: 112.7,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign Into your account',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: emailController,
                              hintText: 'Example@gmail.com',
                              label: 'Email Address',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: passwordController,
                              hintText: '*********',
                              label: 'Password',
                              prefixIcon: Icons.key,
                              obscureText: !_showPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot your password?',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator(
                            color: theme.colorScheme.secondary,
                          )
                          : CustomElevatedButton(
                            title: 'Log In',
                            onPressed: _login,
                          ),

                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => SignupPage()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: "Don't Have An Account? "),
                              TextSpan(
                                text: "Signup",
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
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
}
