import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grad_project/screens/pages/tablePage.dart';
import 'package:grad_project/screens/pages/videosPage.dart';
import 'package:grad_project/screens/signinOptions/chooseFavTeam.dart';
import 'package:grad_project/core/providers/favoritesProvider.dart';
import 'package:grad_project/teamsData/allTeamsScreen.dart';
import 'package:grad_project/teamsData/coaches.dart';
import 'package:grad_project/teamsData/teamSheet.dart';
import 'package:grad_project/core/widgets/buildDrawer.dart';
import 'package:grad_project/teamsData/teamsList.dart';
import 'package:grad_project/core/models/listItem.dart';
import 'package:grad_project/screens/pages/fixturesResultsPage.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  @override
  void initState() {
    super.initState();
    _logMorePageAnalytics();
  }

  Future<void> _logMorePageAnalytics() async {
    String screenName = 'CommunityPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeams = ref.watch(favoriteTeamsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('More', style: Theme.of(context).textTheme.titleLarge),
      ),
      drawer: BuildDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTeams.length > 1
                      ? "Favourite Teams:"
                      : "Favourite Team:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                ...selectedTeams.map((teamName) {
                  final teamData = teams.firstWhere(
                    (team) => team['name'] == teamName,
                    orElse: () => {'name': teamName, 'image': ''},
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (ctx) => TeamSheet(
                                  teamName: teamData['name']!,
                                  logoUrl: teamData['image']!,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            if (teamData['image']!.isNotEmpty)
                              Image.network(
                                teamData['image']!,
                                width: 40,
                                height: 40,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                teamData['name']!,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (ctx) => const ChooseFavTeam(),
                                  ),
                                );
                              },
                              child: Text(
                                "Edit",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text(
                  "Football & More:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                ListItem(
                  label: "Fixtures & Results",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const FixturesResultsPage(),
                      ),
                    );
                  },
                ),
                ListItem(
                  label: "Videos",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const VideosPage()),
                    );
                  },
                ),
                ListItem(
                  label: "Team Sheets",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const AllTeamsScreen(),
                      ),
                    );
                  },
                ),
                ListItem(
                  label: "Coaches",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const CoachesPage()),
                    );
                  },
                ),
                ListItem(
                  label: "Table",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const TablePage()),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(thickness: 1),
                ),
                Text("Other:", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                ListItem(label: "Contact Us", onTap: () {}),
                ListItem(label: "Send Email", onTap: () {}),
                //ListItem(label: "Development Team", onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
