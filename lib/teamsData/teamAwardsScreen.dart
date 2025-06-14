import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamAwardsScreen extends StatefulWidget {
  const TeamAwardsScreen({super.key});

  @override
  State<TeamAwardsScreen> createState() => _TeamAwardsScreenState();
}

class _TeamAwardsScreenState extends State<TeamAwardsScreen> {
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _shareAwardToChat(
    BuildContext context,
    Map<String, dynamic> award,
  ) async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => ListView(
            children:
                usersSnapshot.docs.where((doc) => doc.id != currentUserId).map((
                  user,
                ) {
                  final uid = user.id;
                  final username = user['username'] ?? 'User';

                  return ListTile(
                    title: Text(username),
                    onTap: () async {
                      final chatId = _getChatId(currentUserId, uid);
                      await FirebaseFirestore.instance
                          .collection('messages')
                          .doc(chatId)
                          .collection('chat')
                          .add({
                            'awardShared': true,
                            'awardName': award['AwardName'],
                            'awardImage': award['picture'],
                            'teamName': award['TeamName'],
                            'season': award['Season'],
                            'createdAt': Timestamp.now(),
                            'userId': currentUserId,
                            'username':
                                FirebaseAuth
                                    .instance
                                    .currentUser
                                    ?.displayName ??
                                'Me',
                            'profileImage':
                                FirebaseAuth.instance.currentUser?.photoURL ??
                                '',
                          });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Award shared to chat')),
                      );
                    },
                  );
                }).toList(),
          ),
    );
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'Team Awards',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Awards')
                .where('AwardType', isEqualTo: 'Team')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var awards = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: awards.length,
            itemBuilder: (context, index) {
              var award = awards[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: award['picture'],
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    const LinearProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.image_not_supported),
                          ),
                        ),
                        // Team Logo top right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            backgroundImage: CachedNetworkImageProvider(
                              award['TeamLogo'],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  award['TeamName'],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  award['AwardName'],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (award['Season'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Season: ${award['Season']}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _shareAwardToChat(context, award),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
