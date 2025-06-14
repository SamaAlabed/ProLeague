import 'package:flutter/material.dart';

import 'package:grad_project/core/widgets/chats.dart';
import 'package:grad_project/core/firestoreServices/communityServices.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final ChatServices _chatServices = ChatServices();
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _chatServices.currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Chats', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatServices.getUsersSortedByRecentChat(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sortedUsers = snapshot.data!;

          return ListView.builder(
            itemCount: sortedUsers.length,
            itemBuilder: (context, index) {
              final userDoc = sortedUsers[index]['userDoc'];
              final lastMessage = sortedUsers[index]['lastMessage'] as String;
              final userId = userDoc.id;
              final username = userDoc['username'] ?? 'Unknown';
              final imageUrl = userDoc['image_url'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(username),
                subtitle:
                    lastMessage.isNotEmpty
                        ? Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                        : const Text(""),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (ctx) => Chats(
                            key: ValueKey(userId),
                            otherUserId: userId,
                            otherUserName: username,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
