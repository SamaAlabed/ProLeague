import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Chats extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const Chats({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _subscribeToChatTopic();
  }

  void _subscribeToChatTopic() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatId = chatIdFromUsers(currentUser.uid, widget.otherUserId);
      FirebaseMessaging.instance.subscribeToTopic(chatId);
      debugPrint('Subscribed to topic: $chatId');
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    final currentUser = _auth.currentUser;

    if (text.isEmpty || currentUser == null) return;

    final chatId = chatIdFromUsers(currentUser.uid, widget.otherUserId);

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final currentUsername = userDoc.data()?['username'] ?? 'Unknown';
    final profileImage = userDoc.data()?['image_url'] ?? '';

    await _firestore.collection('messages').doc(chatId).collection('chat').add({
      'text': text,
      'createdAt': Timestamp.now(),
      'userId': currentUser.uid,
      'username': currentUsername,
      'profileImage': profileImage,
    });

    _controller.clear();
  }

  String chatIdFromUsers(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<QuerySnapshot> _getMessages() {
    final currentUser = _auth.currentUser!;
    final chatId = chatIdFromUsers(currentUser.uid, widget.otherUserId);

    return _firestore
        .collection('messages')
        .doc(chatId)
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _unsubscribeFromChatTopic();
    _controller.dispose();
    super.dispose();
  }

  void _unsubscribeFromChatTopic() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatId = chatIdFromUsers(currentUser.uid, widget.otherUserId);
      FirebaseMessaging.instance.unsubscribeFromTopic(chatId);
      debugPrint('Unsubscribed from topic: $chatId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.otherUserName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['userId'] == currentUser.uid;

                      final data = msg.data() as Map<String, dynamic>;
                      final isSharedPost = data['postShared'] == true;
                      final isSharedAward = data['awardShared'] == true;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe
                                    ? const Color.fromARGB(255, 79, 136, 183)
                                    : Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              isSharedPost
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ' Shared Post:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if ((data['postText'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            data['postText'],
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      if ((data['postImage'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              data['postImage'],
                                              height: 200,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.6,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                  : isSharedAward
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Shared Award:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if ((data['awardName'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '${data['awardName']}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      if ((data['teamName'] ?? '')
                                              .toString()
                                              .isNotEmpty ||
                                          (data['season'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            'Team: ${data['teamName']} | Season: ${data['season']}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ),
                                      if ((data['awardImage'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              data['awardImage'],
                                              height: 200,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.6,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                  : Text(
                                    data['text'] ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
