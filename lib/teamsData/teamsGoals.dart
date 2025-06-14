import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsGoals extends StatefulWidget {
  const TeamsGoals({super.key});

  @override
  State<TeamsGoals> createState() => _TeamsGoalsState();
}

class _TeamsGoalsState extends State<TeamsGoals> {
  List<Map<String, dynamic>> teams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllTeams();
  }

  Future<void> fetchAllTeams() async {
    final teamsSnapshot =
        await FirebaseFirestore.instance.collection('teams').get();

    final List<Map<String, dynamic>> loadedTeams = [];

    for (var teamDoc in teamsSnapshot.docs) {
      final teamData = teamDoc.data();

      if (teamData.containsKey('TeamGoals') && teamData['TeamGoals'] != null) {
        loadedTeams.add({
          'name': teamData['TeamName'] ?? '',
          'logo': teamData['TeamLogo'] ?? '',
          'goals': int.tryParse(teamData['TeamGoals'].toString()) ?? 0,
        });
      }
    }

    loadedTeams.removeWhere((team) => team['goals'] == 0);

    loadedTeams.sort((a, b) {
      final aGoals = a['goals'] ?? 0;
      final bGoals = b['goals'] ?? 0;
      return bGoals.compareTo(aGoals);
    });

    setState(() {
      teams = loadedTeams;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Teams', style: Theme.of(context).textTheme.titleLarge),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
              : teams.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: teams.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final topTeam = teams[0];
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
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              topTeam['logo'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              topTeam['name'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            topTeam['goals'].toString(),
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
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Team',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'Goals',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final team = teams[index - 2];

                    Color? rowColor;
                    if (index == 2) {
                      rowColor = const Color(0xFFFFD700);
                    } else if (index == 3) {
                      rowColor = const Color(0xFFC0C0C0);
                    } else if (index == 4) {
                      rowColor = const Color(0xFFCD7F32);
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
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            team['logo'],
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            team['name'],
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      team['goals'].toString(),
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
