import 'package:flutter/material.dart';

import 'package:grad_project/core/models/coachItem.dart';

class CoachCard extends StatelessWidget {
  final Coach coach;

  const CoachCard(this.coach, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            coach.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(coach.picture),
          ),
          Row(
            children: [
              Expanded(child: Image.network(coach.logo, width: 35, height: 35)),
              Expanded(
                child: Text(
                  coach.team,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
