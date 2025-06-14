import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ResultsCarouselSlider extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const ResultsCarouselSlider({super.key, required this.results});

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
          results.map((result) {
            final dateTime = result['DateTime'] ?? '';
            final matchDate = dateTime.split('•').first.trim();
            final matchTime = dateTime.split('•').last.trim();
            final stadium = result['Stadium'] ?? 'Unknown';
            final teamScore = result['TeamScore']?.toString() ?? '-';
            final opponentScore = result['OpponentScore']?.toString() ?? '-';
            final status = result['Status'] ?? 'N/A';

            final homeLogo = result['TeamLogo'] ?? '';
            final awayLogo = result['OpponentLogo'] ?? '';
            final homeDisplay = result['Display'] ?? 'HOM';
            final awayDisplay = result['OpDisplay'] ?? 'AWY';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    matchDate,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTeamColumn(
                        context,
                        label: homeDisplay,
                        logoUrl: homeLogo,
                      ),
                      Column(
                        children: [
                          Text(
                            '$teamScore - $opponentScore',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Status: $status'),
                          Text('$stadium'),
                          Text(matchTime),
                        ],
                      ),
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
