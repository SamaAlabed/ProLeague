import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  int signInCount = 0;
  Map<String, int> screenViewCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final signInSnapshot =
          await firestore
              .collection('dashboard_metrics')
              .doc('user_signins')
              .get();

      final screenViewSnapshot =
          await firestore
              .collection('dashboard_metrics')
              .doc('screen_views')
              .get();

      setState(() {
        signInCount = signInSnapshot.data()?['count'] ?? 0;
        screenViewCounts = Map<String, int>.from(
          screenViewSnapshot.data() ?? {},
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics data: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildSignInCard(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              LucideIcons.logIn,
              size: 36,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Sign-ins',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '$signInCount',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScreenViewsCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.layoutDashboard,
                  size: 24,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 10),
                Text(
                  'Most Viewed Screens',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (screenViewCounts.isEmpty)
              const Text('No screen view data available.')
            else
              Column(
                children:
                    screenViewCounts.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    buildSignInCard(context),
                    buildScreenViewsCard(context),
                  ],
                ),
              ),
    );
  }
}
