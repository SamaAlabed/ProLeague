import 'package:flutter/material.dart';

import 'package:grad_project/core/models/coachItem.dart';
import 'package:grad_project/core/models/coachCard.dart';
import 'package:grad_project/core/firestoreServices/fetchTeamData.dart';

class CoachesPage extends StatelessWidget {
  const CoachesPage({super.key});

  Future<List<Coach>> fetchCoaches() async {
    final rawCoaches = await CoachService.fetchAllCoaches();
    return rawCoaches.map((data) => Coach.fromMap(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Team Coaches'),
      ),
      body: FutureBuilder<List<Coach>>(
        future: fetchCoaches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading coaches',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final coaches = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: coaches.map((coach) => CoachCard(coach)).toList(),
            ),
          );
        },
      ),
    );
  }
}
