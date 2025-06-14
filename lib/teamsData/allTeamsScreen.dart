import 'package:flutter/material.dart';

import 'package:grad_project/teamsData/teamSheet.dart';
import 'package:grad_project/teamsData/teamsList.dart';

class AllTeamsScreen extends StatelessWidget {
  const AllTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Teams', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(team['image']!),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            title: Text(team['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) => TeamSheet(
                        teamName: team['name']!,
                        logoUrl: team['image']!,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
