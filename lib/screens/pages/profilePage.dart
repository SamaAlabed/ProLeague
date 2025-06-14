import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:grad_project/screens/pages/allusersPage.dart';
import 'package:grad_project/screens/pages/editProfilePage.dart';
import 'package:grad_project/core/firestoreServices/usersData.dart';
import 'package:grad_project/screens/tabs/FavTeams.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _imageUrl;
  String? _username;
  String? _role;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileData();
    _logProfilePageAnalytics();
  }

  Future<void> _logProfilePageAnalytics() async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'ProfilePage',
      screenClass: 'ProfilePage',
    );
    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({'ProfilePage': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> _fetchUserProfileData() async {
    final profileData = await UserProfileService.loadUserProfile();
    setState(() {
      _imageUrl = profileData['imageUrl'];
      _username = profileData['username'];
      _role = profileData['role'] ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundImage:
                                _imageUrl != null
                                    ? NetworkImage(_imageUrl!)
                                    : null,
                            child:
                                _imageUrl == null
                                    ? const Icon(Icons.person, size: 46)
                                    : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const EditProfile(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _username ?? 'Loading...',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_role == 'admin')
                      Text(
                        'Admin',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildMenuItem(Icons.edit, 'Edit Profile ', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const EditProfile()),
                    );
                  }),
                  _buildMenuItem(Icons.favorite_border, 'Favourite Teams', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const FavTeamsScreen(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.mail_outline, 'Messages', () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => const Users()));
                  }),
                  _buildMenuItem(
                    Icons.share_rounded,
                    'Share This App',
                    () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          tileColor: Theme.of(context).colorScheme.secondary,
          leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing:
              badge != null
                  ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                  : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
