import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grad_project/core/models/CustomButtons.dart';
import 'package:grad_project/core/providers/favoritesProvider.dart';
import 'package:grad_project/teamsData/teamsList.dart';
import 'package:grad_project/core/widgets/tabs.dart';
import 'package:grad_project/core/firestoreServices/fetchTeamData.dart';

class ChooseFavTeam extends ConsumerStatefulWidget {
  const ChooseFavTeam({super.key});

  @override
  ConsumerState<ChooseFavTeam> createState() => _ChooseFavTeamState();
}

class _ChooseFavTeamState extends ConsumerState<ChooseFavTeam> {
  bool _isSaving = false;

  void _start() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => Tabs()));
  }

  void _toggleSelection(String team) {
    ref.read(favoriteTeamsProvider.notifier).toggleTeam(team);
  }

  Future<void> saveFavorites() async {
    final selectedTeams = ref.read(favoriteTeamsProvider);

    setState(() {
      _isSaving = true;
    });

    try {
      await FavoriteService().saveUserFavorites(selectedTeams.toList());
      _start();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save favorites')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeams = ref.watch(favoriteTeamsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Choose Your Favorite Team'),
        actions: [
          TextButton(
            onPressed: _start,
            child: Text(
              'Skip >',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: teams.length,
                  itemBuilder: (ctx, index) {
                    final team = teams[index];
                    final isSelected = selectedTeams.contains(team['name']);

                    return GestureDetector(
                      onTap: () => _toggleSelection(team['name']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  team['image']!,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.error),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              team['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child:
                  _isSaving
                      ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      )
                      : CustomElevatedButton(
                        title: 'Continue >',
                        onPressed: saveFavorites,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
