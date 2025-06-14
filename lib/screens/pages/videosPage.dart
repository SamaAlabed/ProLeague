import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/link.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  late Future<List<Map<String, dynamic>>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = fetchVideos();
    _logVideosPageAnalytics();
  }

  Future<void> _logVideosPageAnalytics() async {
    String screenName = 'VideosPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchVideos() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Vid').get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Videos', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Link(
              uri: Uri.parse('https://www.youtube.com/@JFA-TV'),
              target: LinkTarget.defaultTarget,
              builder:
                  (context, followLink) => InkWell(
                    onTap: followLink,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Jordan Football official channel >>',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _videosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No videos found.'));
                  }

                  final videos = snapshot.data!;

                  return ListView.separated(
                    itemCount: videos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      final imageUrl = (video['image'] ?? '').toString().trim();
                      final title =
                          (video['Name'] ?? 'No title').toString().trim();
                      final link =
                          (video['link'] ?? '')
                              .toString()
                              .replaceAll('"', '')
                              .trim();

                      return Link(
                        uri: Uri.parse(link),
                        target: LinkTarget.defaultTarget,
                        builder:
                            (context, followLink) => InkWell(
                              onTap: followLink,
                              splashColor:
                                  Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 150,
                                      height: 100,
                                      fit: BoxFit.fill,
                                      placeholder:
                                          (context, url) => const SizedBox(
                                            width: 120,
                                            height: 80,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title.isNotEmpty ? title : 'No title',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
