import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsCleanSheets extends StatefulWidget {
  const TeamsCleanSheets({super.key});

  @override
  State<TeamsCleanSheets> createState() => _TeamsCleanSheetsState();
}

class _TeamsCleanSheetsState extends State<TeamsCleanSheets> {
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllTeams();
  }

  Future<void> fetchAllTeams() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('teams').get();
      final List<Map<String, dynamic>> loaded = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final cleanSheets =
            int.tryParse(data['CleanSheets']?.toString() ?? '0') ?? 0;

        if (cleanSheets > 0) {
          loaded.add({
            'name': data['TeamName'] ?? '',
            'logo': data['TeamLogo'] ?? '',
            'sheets': cleanSheets,
          });
        }
      }

      loaded.sort((a, b) => b['sheets'].compareTo(a['sheets']));

      setState(() {
        teams = loaded;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching clean sheets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'Clean Sheets',
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
              : ListView.builder(
                itemCount: teams.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final top = teams[0];
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
                              top['logo'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              top['name'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            top['sheets'].toString(),
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
                              'Team',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'CS',
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
                    if (index == 2)
                      rowColor = const Color(0xFFFFD700);
                    else if (index == 3)
                      rowColor = const Color(0xFFC0C0C0);
                    else if (index == 4)
                      rowColor = const Color(0xFFCD7F32);

                    return TweenAnimationBuilder<Offset>(
                      tween: Tween(
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
                                        borderRadius: BorderRadius.circular(8),
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
                                    team['sheets'].toString(),
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
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
