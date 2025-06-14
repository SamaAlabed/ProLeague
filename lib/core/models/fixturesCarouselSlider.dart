import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FixturesCarouselSlider extends StatelessWidget {
  final List<Map<String, dynamic>> fixtures;

  const FixturesCarouselSlider({super.key, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.95,
      ),
      items:
          fixtures.map((fixture) {
            final homeDisplay = fixture['Display'] ?? 'HOM';
            final homeLogo = fixture['TeamLogo'] ?? '';
            final awayDisplay = fixture['OpDisplay'] ?? 'AWY';
            final awayLogo = fixture['OpponentLogo'] ?? '';
            final stadium = fixture['Stadium'] ?? 'Unknown Stadium';
            final dateTimeRaw = fixture['DateTime'] ?? '';
            final matchTime = dateTimeRaw.split('•').last.trim();
            final matchDate = dateTimeRaw.split('•').first.trim();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(matchDate, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home team
                      _buildTeamColumn(
                        context,
                        label: homeDisplay,
                        logoUrl: homeLogo,
                      ),
                      // Match time & stadium
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              matchTime,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stadium,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      // Away team
                      _buildTeamColumn(
                        context,
                        label: awayDisplay,
                        logoUrl: awayLogo,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTeamColumn(
    BuildContext context, {
    required String label,
    required String logoUrl,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            logoUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Icon(
                  Icons.error,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ],
    );
  }
}
