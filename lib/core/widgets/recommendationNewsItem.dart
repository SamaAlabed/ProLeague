import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import 'package:grad_project/core/models/newsItem.dart';

class RecommendationNewsItem extends StatelessWidget {
  final NewsItem newsItem;
  const RecommendationNewsItem({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Link(
        target: LinkTarget.self,
        uri: Uri.parse(newsItem.link),
        builder:
            (context, followLink) => InkWell(
              onTap: followLink,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      newsItem.imgUrl,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   newsItem.category,
                        //   style: Theme.of(
                        //     context,
                        //   ).textTheme.bodyLarge!.copyWith(
                        //     color: Theme.of(context).colorScheme.secondary,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        Text(
                          newsItem.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(newsItem.time),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
