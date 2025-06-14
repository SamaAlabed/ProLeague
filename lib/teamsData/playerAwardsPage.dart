import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerAwardsScreen extends StatefulWidget {
  const PlayerAwardsScreen({super.key});

  @override
  State<PlayerAwardsScreen> createState() => _PlayerAwardsScreenState();
}

class _PlayerAwardsScreenState extends State<PlayerAwardsScreen> {
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
                            'playerName': award['PlayerName'],
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
          'Player Awards',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Awards')
                .where('AwardType', isEqualTo: 'Player')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          }

          var awards = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: awards.length,
            itemBuilder: (context, index) {
              var award = awards[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: award['picture'],
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    const LinearProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
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
                          // Player Picture
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: CachedNetworkImageProvider(
                              award['PlayerPicture'],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        award['PlayerName'],
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed:
                                          () =>
                                              _shareAwardToChat(context, award),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  award['AwardName'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Team: ${award['TeamName']} - Season: ${award['Season']}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
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
