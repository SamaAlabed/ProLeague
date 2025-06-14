import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grad_project/core/models/statCard.dart';
import 'package:grad_project/screens/tabs/awardsPage.dart';
import 'package:grad_project/teamsData/playersAssists.dart';
import 'package:grad_project/teamsData/playersGoals.dart';
import 'package:grad_project/teamsData/teamsGoals.dart';
import 'package:grad_project/teamsData/teamsCleanSheets.dart';
import 'package:grad_project/core/widgets/buildDrawer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? topPlayer;
  Map<String, dynamic>? topTeam;
  Map<String, dynamic>? topAssistPlayer;
  Map<String, dynamic>? topCleanSheetTeam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopStats();
    _logStatsPageAnalytics();
  }

  Future<void> _logStatsPageAnalytics() async {
    String screenName = 'StatsPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> fetchTopStats() async {
    final teamsSnapshot =
        await FirebaseFirestore.instance.collection('teams').get();

    final players = <Map<String, dynamic>>[];
    final assistPlayers = <Map<String, dynamic>>[];
    final teams = <Map<String, dynamic>>[];
    final cleanSheetTeams = <Map<String, dynamic>>[];

    for (var teamDoc in teamsSnapshot.docs) {
      final teamData = teamDoc.data();
      final teamLogo = teamData['TeamLogo'] ?? '';

      if (teamData['TeamGoals'] != null) {
        teams.add({
          'name': teamData['TeamName'] ?? '',
          'logo': teamLogo,
          'goals': int.tryParse(teamData['TeamGoals'].toString()) ?? 0,
        });
      }

      if (teamData['CleanSheets'] != null) {
        cleanSheetTeams.add({
          'name': teamData['TeamName'] ?? '',
          'logo': teamLogo,
          'sheets': int.tryParse(teamData['CleanSheets'].toString()) ?? 0,
        });
      }

      final membersSnapshot =
          await teamDoc.reference.collection('Members').get();
      for (var memberDoc in membersSnapshot.docs) {
        final data = memberDoc.data();
        if (data['Goals'] != null) {
          players.add({
            'name': data['Name'] ?? '',
            'goals': int.tryParse(data['Goals'].toString()) ?? 0,
            'picture': data['picture'] ?? '',
          });
        }
        if (data['Assists'] != null) {
          assistPlayers.add({
            'name': data['Name'] ?? '',
            'assists': int.tryParse(data['Assists'].toString()) ?? 0,
            'picture': data['picture'] ?? '',
          });
        }
      }
    }

    players.removeWhere((p) => p['goals'] == 0);
    assistPlayers.removeWhere((p) => p['assists'] == 0);
    teams.removeWhere((t) => t['goals'] == 0);
    cleanSheetTeams.removeWhere((t) => t['sheets'] == 0);

    players.sort((a, b) => b['goals'].compareTo(a['goals']));
    assistPlayers.sort((a, b) => b['assists'].compareTo(a['assists']));
    teams.sort((a, b) => b['goals'].compareTo(a['goals']));
    cleanSheetTeams.sort((a, b) => b['sheets'].compareTo(a['sheets']));

    setState(() {
      topPlayer = players.isNotEmpty ? players.first : null;
      topAssistPlayer = assistPlayers.isNotEmpty ? assistPlayers.first : null;
      topTeam = teams.isNotEmpty ? teams.first : null;
      topCleanSheetTeam =
          cleanSheetTeams.isNotEmpty ? cleanSheetTeams.first : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text('Season', style: Theme.of(context).textTheme.titleLarge),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'Statistics'), Tab(text: 'Awards')],
          ),
        ),
        drawer: BuildDrawer(),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
                : TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2024/2025 Top Stats:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              StatCard(
                                title: 'Goals',
                                value: topPlayer?['goals'].toString() ?? '0',
                                imgUrl:
                                    topPlayer?['picture'] ??
                                    'assets/images/player.png',
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PlayersGoals(),
                                      ),
                                    ),
                              ),
                              StatCard(
                                title: 'Most Assists',
                                value:
                                    topAssistPlayer?['assists'].toString() ??
                                    '0',
                                imgUrl:
                                    topAssistPlayer?['picture'] ??
                                    'assets/images/player.png',
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PlayersAssists(),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Team Goals',
                                  value: topTeam?['goals'].toString() ?? '0',
                                  imgUrl:
                                      topTeam?['logo'] ??
                                      'assets/images/player.png',
                                  onPressed:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => const TeamsGoals(),
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: 'Clean Sheets',
                                  value:
                                      topCleanSheetTeam?['sheets'].toString() ??
                                      '0',
                                  imgUrl:
                                      topCleanSheetTeam?['logo'] ??
                                      'assets/images/player.png',
                                  onPressed:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (ctx) => const TeamsCleanSheets(),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const AwardsTab(),
                  ],
                ),
      ),
    );
  }
}
