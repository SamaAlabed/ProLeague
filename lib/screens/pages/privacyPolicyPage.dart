import 'package:flutter/material.dart';

import 'package:grad_project/core/models/privacyPolicyModels.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: PageView(
        children: [
          PrivacyPolicyModels.buildPage1(context, colorScheme),
          PrivacyPolicyModels.buildPage2(context, colorScheme),
        ],
      ),
    );
  }
}
