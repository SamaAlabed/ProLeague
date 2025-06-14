import 'package:flutter/material.dart';

import 'package:grad_project/core/firestoreServices/fetchTeamData.dart';
import 'package:grad_project/core/firestoreServices/firestoreHelper.dart';

class TeamSheet extends StatefulWidget {
  final String teamName;
  final String logoUrl;

  const TeamSheet({super.key, required this.teamName, required this.logoUrl});

  @override
  State<TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<TeamSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              widget.logoUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Text(
              widget.teamName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: TeamService.fetchPlayersByRole(widget.teamName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.values.every((list) => list.isEmpty)) {
            return Center(
              child: Text(
                "No players found",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final roles = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    roles.entries.where((e) => e.value.isNotEmpty).map((entry) {
                      final role = entry.key;
                      final players = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              role,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children:
                                players.map((player) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.42,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: NetworkImage(
                                            FirestoreHelper.getField(
                                                  player,
                                                  'picture',
                                                ) ??
                                                '',
                                          ),
                                          backgroundColor: Colors.grey.shade300,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            FirestoreHelper.getField(
                                                  player,
                                                  'Name',
                                                ) ??
                                                '',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
