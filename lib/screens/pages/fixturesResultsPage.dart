import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/core/firestoreServices/fetchTeamData.dart';
import 'package:grad_project/core/models/fixturesCarouselSlider.dart';
import 'package:grad_project/core/models/resultsCarouselSlider.dart';

class FixturesResultsPage extends StatefulWidget {
  const FixturesResultsPage({super.key});

  @override
  State<FixturesResultsPage> createState() => _FixturesResultsPageState();
}

class _FixturesResultsPageState extends State<FixturesResultsPage> {
  late Future<List<String>> _allTeamNames;

  @override
  void initState() {
    super.initState();
    _allTeamNames = _fetchAllTeamNames();
    _logFixturesAndResultsPageAnalytics();
  }

  Future<void> _logFixturesAndResultsPageAnalytics() async {
    String screenName = 'Fixtures&ResultsPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<List<String>> _fetchAllTeamNames() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('fixtures').get();
      return snapshot.docs
          .map((doc) => doc.data()['TeamName']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      print('❗ Error fetching team names: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: const Text('Fixtures & Results'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'Fixtures'), Tab(text: 'Results')],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            // --- Fixtures Tab ---
            FutureBuilder<List<String>>(
              future: _allTeamNames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No teams available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                final teams = snapshot.data!;
                return ListView.builder(
                  itemCount: teams.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final teamName = teams[index];
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: FixtureService.fetchFixtures(teamName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final fixtures = snapshot.data!;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          color: Theme.of(context).colorScheme.tertiary,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FixturesCarouselSlider(fixtures: fixtures),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            // --- Results Tab ---
            FutureBuilder<List<String>>(
              future: _allTeamNames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No teams available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                final teams = snapshot.data!;
                return ListView.builder(
                  itemCount: teams.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final teamName = teams[index];
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: FixtureService.fetchResults(teamName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final results = snapshot.data!;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          color: Theme.of(context).colorScheme.tertiary,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ResultsCarouselSlider(results: results),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
