import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/admin/analytics.dart';

import 'package:grad_project/core/providers/themeProvider.dart';
import 'package:grad_project/screens/pages/aboutAppPage.dart';
import 'package:grad_project/screens/pages/fAQsPage.dart';
import 'package:grad_project/screens/pages/privacyPolicyPage.dart';
import 'package:grad_project/admin/reportsPage.dart';
import 'package:grad_project/screens/signinOptions/HomePage.dart';
import 'package:grad_project/screens/pages/profilePage.dart';

class BuildDrawer extends ConsumerStatefulWidget {
  const BuildDrawer({super.key});

  @override
  ConsumerState<BuildDrawer> createState() => _BuildDrawerState();
}

class _BuildDrawerState extends ConsumerState<BuildDrawer> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (mounted) {
      setState(() {
        userRole = doc.data()?['role'] ?? 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: Text(
                    'Mode (Dark/Light)',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.document_scanner_sharp,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => PrivacyPolicyPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.phonelink_setup_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    'About App',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => AboutAppPage()));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.question_answer,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    'FAQs',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => FAQPage()));
                  },
                ),
              ],
            ),
          ),
          if (userRole == 'admin')
          Divider(color: Theme.of(context).colorScheme.secondary),
          if (userRole == 'admin')
            ListTile(
              leading: Icon(
                Icons.report_gmailerrorred,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Reports',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ReportsPage()),
                );
              },
            ),
          if (userRole == 'admin')
            ListTile(
              leading: Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Analytics',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => AnalyticsDashboard()),
                );
              },
            ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 236, 40, 26),
            ),
            title: Text(
              'Log Out',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18,
                color: const Color.fromARGB(255, 236, 40, 26),
              ),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => HomePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
