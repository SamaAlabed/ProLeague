import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:grad_project/screens/signinOptions/allowNotifications.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
  }

  Future<void> _checkEmailVerified() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const AllowNotifications()),
          (route) => false,
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'A verification email has been sent to your email.\nPlease verify to continue.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser
                    ?.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email resent.')),
                );
              },
              child: const Text('Resend Email'),
            ),
          ],
        ),
      ),
    );
  }
}
