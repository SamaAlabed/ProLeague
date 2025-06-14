import 'package:flutter/material.dart';

import 'package:grad_project/teamsData/playerAwardsPage.dart';
import 'package:grad_project/teamsData/teamAwardsScreen.dart';
import 'package:grad_project/core/models/awardButton.dart';

class AwardsTab extends StatelessWidget {
  const AwardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('2024/2025 Awards:', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        AwardButton(
          imagePath: 'assets/images/soccerplayer.png',
          label: 'Player Awards',
          destinationPage: const PlayerAwardsScreen(),
        ),
        const SizedBox(height: 20),
        AwardButton(
          imagePath: 'assets/images/soccerTeam.png',
          label: 'Team Awards',
          destinationPage: const TeamAwardsScreen(),
        ),
      ],
    );
  }
}


