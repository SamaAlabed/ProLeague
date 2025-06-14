import 'package:flutter/material.dart';

class PrivacyPolicyModels {
  static Widget buildPage1(BuildContext context, ColorScheme colorScheme) {
    return _buildContent(
      context,
      colorScheme,
      children: [
        Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome to the Jordan Football Team App. Your privacy is important to us, and we are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and share your information when you use our app.',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('1. Information We Collect', context),
        Text(
          'When you use our app, we may collect the following types of information:',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 8),
        _buildBullet(
          '* Personal Information:',
          'Name, email address, and profile details if you create an account.',
          context,
        ),
        _buildBullet(
          '* Usage Data:',
          'How you interact with the app, such as viewed matches and favorite players.',
          context,
        ),
        _buildBullet(
          '* Device Information:',
          'Your device type, operating system, and app version.',
          context,
        ),
        _buildBullet(
          '* Location Data (Optional):',
          'If you allow, we may collect location data to provide personalized match recommendations.',
          context,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('2. How We Use Your Information', context),
        _buildBullet(
          '•',
          'Provide real-time match updates, player stats, and team news.',
          context,
        ),
        _buildBullet(
          '•',
          'Improve app performance and user experience.',
          context,
        ),
        _buildBullet(
          '•',
          'Send notifications about upcoming matches and team events.',
          context,
        ),
        _buildBullet(
          '•',
          'Monitor app usage to enhance features and fix issues.',
          context,
        ),
      ],
    );
  }

  static Widget buildPage2(BuildContext context, ColorScheme colorScheme) {
    return _buildContent(
      context,
      colorScheme,
      children: [
        _buildSectionTitle('3. How We Share Your Information', context),
        Text(
          'We do not sell your data. However, we may share it with:',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 8),
        _buildBullet(
          '* Service Providers:',
          'Third-party analytics and hosting services to improve the app.',
          context,
        ),
        _buildBullet(
          '* Legal Authorities:',
          'If required by law or to protect our rights.',
          context,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('4. Your Privacy Choices', context),
        _buildBullet(
          '* Account Settings:',
          'You can update or delete your account at any time.',
          context,
        ),
        _buildBullet(
          '* Notifications:',
          'Manage push notification preferences in app settings.',
          context,
        ),
        _buildBullet(
          '* Location Data:',
          'You can enable or disable location sharing through your device settings.',
          context,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('5. Security Measures', context),
        Text(
          'We take reasonable measures to protect your data, but no system is 100% secure. Please use strong passwords and avoid sharing account details.',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('6. Contact Us', context),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.email, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              'ProLeague@gmail.com',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              '0796743772',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme, {
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  static Widget _buildBullet(
    String label,
    String content,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
