import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grad_project/core/widgets/tableWidgets.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  @override
  void initState() {
    super.initState();
    _logTablePageAnalytics();
  }

  Future<void> _logTablePageAnalytics() async {
    String screenName = 'TablePage';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Table', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Table').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No table data available.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final teams =
              snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

          teams.sort((a, b) {
            final pointsA = a['points'] ?? 0;
            final pointsB = b['points'] ?? 0;
            if (pointsA != pointsB) return pointsB.compareTo(pointsA);

            final gdA = a['goalDifference'] ?? 0;
            final gdB = b['goalDifference'] ?? 0;
            if (gdA != gdB) return gdB.compareTo(gdA);

            final wonA = a['won'] ?? 0;
            final wonB = b['won'] ?? 0;
            return wonB.compareTo(wonA);
          });

          for (final team in teams) {
            print(
              'Team: ${team['team']}, Points: ${team['points']}, Won: ${team['won']}',
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                header(context),
                ...List.generate(teams.length, (index) {
                  final team = teams[index];
                  final rank = index + 1;

                  Color? bgColor;
                  if (rank == 1) {
                    bgColor = const Color(0xFFFFD700);
                  } else if (rank == 2) {
                    bgColor = const Color(0xFFC0C0C0);
                  } else if (rank == 3) {
                    bgColor = const Color(0xFFCD7F32);
                  } else if (rank > teams.length - 4) {
                    final redShades = [600, 700, 800, 900];
                    final indexFromBottom = rank - (teams.length - 4);
                    final shadeIndex = (indexFromBottom - 1).clamp(0, 3);
                    bgColor = Colors.red[redShades[shadeIndex]];
                  }

                  return teamRow(context, team, rank, backgroundColor: bgColor);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
