import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayersAssists extends StatefulWidget {
  const PlayersAssists({super.key});

  @override
  State<PlayersAssists> createState() => _PlayersAssistsState();
}

class _PlayersAssistsState extends State<PlayersAssists> {
  List<Map<String, dynamic>> players = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPlayersWithAssists();
  }

  Future<void> fetchPlayersWithAssists() async {
    final teamsSnapshot =
        await FirebaseFirestore.instance.collection('teams').get();

    final List<Map<String, dynamic>> assistPlayers = [];

    for (var teamDoc in teamsSnapshot.docs) {
      final teamData = teamDoc.data();
      final teamLogo = teamData['TeamLogo'] ?? '';

      final membersSnapshot =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(teamDoc.id)
              .collection('Members')
              .get();

      for (var memberDoc in membersSnapshot.docs) {
        final memberData = memberDoc.data();
        final assists =
            int.tryParse(memberData['Assists']?.toString() ?? '0') ?? 0;

        if (assists > 0) {
          assistPlayers.add({
            'name': memberData['Name'] ?? '',
            'assists': assists,
            'picture': memberData['picture'] ?? '',
            'clubLogo': teamLogo,
          });
        }
      }
    }

    assistPlayers.sort((a, b) => b['assists'].compareTo(a['assists']));

    setState(() {
      players = assistPlayers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'Most Assists',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
              : players.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: players.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final topPlayer = players[0];
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              topPlayer['picture'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topPlayer['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Image.network(
                                  topPlayer['clubLogo'],
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            topPlayer['assists'].toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  } else if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              'Pos',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Player',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'Club',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'AST',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final player = players[index - 2];

                    Color? rowColor;
                    if (index == 2) {
                      rowColor = const Color(0xFFFFD700); // Gold
                    } else if (index == 3) {
                      rowColor = const Color(0xFFC0C0C0); // Silver
                    } else if (index == 4) {
                      rowColor = const Color(0xFFCD7F32); // Bronze
                    }

                    return TweenAnimationBuilder<Offset>(
                      tween: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ),
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOut,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: Offset(offset.dx * 30, 0),
                          child: Container(
                            color: rowColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      (index - 1).toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      player['name'],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Image.network(
                                      player['clubLogo'],
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      player['assists'].toString(),
                                      textAlign: TextAlign.end,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
    );
  }
}
