import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:grad_project/core/widgets/buildDrawer.dart';
import 'package:grad_project/core/widgets/postItem.dart';
import 'package:grad_project/screens/pages/allusersPage.dart';
import 'package:grad_project/screens/pages/createPostPage.dart';
import 'package:grad_project/core/firestoreServices/communityServices.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final PostServices _postServices = PostServices();

  @override
  void initState() {
    super.initState();
    _logPageAnalytics();
  }

  Future<void> _logPageAnalytics() async {
    const screenName = 'CommunityPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await _postServices.incrementMetric(screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Community', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const CreatePostPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.chat_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Users()),
              );
            },
          ),
        ],
      ),
      drawer: BuildDrawer(),
      body: StreamBuilder(
        stream: _postServices.allPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ));
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = posts[index];
              final rawData = doc.data();
              if (rawData == null) return const SizedBox();

              final postData = rawData as Map<String, dynamic>;
              postData['id'] = doc.id;

              return PostItem(postData: postData);
            },
          );
        },
      ),
    );
  }
}
