import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Future<void> _deletePostAndReports(String postId) async {
    final postDocRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId);

    final commentsSnapshot = await postDocRef.collection('comments').get();
    for (var comment in commentsSnapshot.docs) {
      await comment.reference.delete();
    }

    final reportsSnapshot =
        await FirebaseFirestore.instance
            .collection('reports')
            .where('postId', isEqualTo: postId)
            .get();
    for (var report in reportsSnapshot.docs) {
      await report.reference.delete();
    }

    await postDocRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(title: const Text('Reports')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reports')
                .orderBy('reportedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return Center(
              child: Text(
                'No reports found.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final uniqueReportsMap = <String, QueryDocumentSnapshot>{};
          for (var report in reports) {
            final data = report.data() as Map<String, dynamic>;
            final postId = data['postId'];
            if (postId != null && !uniqueReportsMap.containsKey(postId)) {
              uniqueReportsMap[postId] = report;
            }
          }

          final uniqueReports = uniqueReportsMap.values.toList();

          return ListView.builder(
            itemCount: uniqueReports.length,
            itemBuilder: (context, index) {
              final report = uniqueReports[index];
              final data = report.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.flag, color: Colors.orange),
                  title: Text(
                    data['postText'] ?? 'No content',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Post ID: ${data['postId'] ?? ''}'),
                      Text('Reported Reason: ${data['reason'] ?? 'N/A'}'),
                      Text(
                        'Reported At: ${data['reportedAt']?.toDate().toLocal() ?? ''}',
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text(
                                'Are you sure you want to delete this post?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'Cancel',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'Delete',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _deletePostAndReports(data['postId']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post deleted')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
