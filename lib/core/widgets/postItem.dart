import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grad_project/core/firestoreServices/communityServices.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostItem({super.key, required this.postData});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final PostServices _postService = PostServices();
  late final String currentUserId;
  bool hasReported = false;

  @override
  void initState() {
    super.initState();
    currentUserId = _postService.currentUserId;
    _checkIfReported();
  }

  void _checkIfReported() async {
    final reported = await _postService.hasUserReported(widget.postData['id']);
    if (mounted) {
      setState(() => hasReported = reported);
    }
  }

  void _showCommentDialog(String postId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text(
              'Add Comment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type your comment...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final userData = await _postService.getUserData();
                    if (userData != null) {
                      await _postService.addComment(
                        postId,
                        controller.text,
                        userData,
                      );
                      Navigator.of(ctx).pop();
                    }
                  }
                },
                child: Text(
                  'Post',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
    );
  }

  void _shareToChat(BuildContext context) async {
    final users = await _postService.getAllUsers();

    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      context: context,
      builder:
          (ctx) => ListView(
            children:
                users.where((doc) => doc.id != currentUserId).map((user) {
                  final uid = user.id;
                  final username = user['username'] ?? 'User';
                  return ListTile(
                    title: Text(username),
                    onTap: () async {
                      final chatId = _getChatId(currentUserId, uid);
                      await _postService.sharePostToChat(
                        chatId: chatId,
                        postData: widget.postData,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post shared to chat')),
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
    final postId = widget.postData['id'];

    return StreamBuilder<DocumentSnapshot>(
      stream: _postService.postStream(postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final postData = snapshot.data!.data() as Map<String, dynamic>?;
        if (postData == null) return const SizedBox();

        final likes = postData['likes'] ?? [];
        final isLiked = likes.contains(currentUserId);
        final username = postData['username'] ?? 'Unknown';
        final userImage = postData['userImage'] ?? '';
        final text = postData['text'] ?? '';
        final postImage = postData['imageUrl'];
        final timestamp = postData['timestamp']?.toDate();

        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    if (timestamp != null)
                      Text(
                        '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (text.isNotEmpty)
                  Text(text, style: Theme.of(context).textTheme.bodyLarge),
                if (postImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        postImage,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed:
                              () => _postService.toggleLike(postId, isLiked),
                        ),
                        Text('${likes.length}'),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () => _showCommentDialog(postId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _shareToChat(context),
                    ),
                    if (postData['uid'] == currentUserId)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                    'Are you sure you want to delete this post?',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed:
                                          () => Navigator.of(ctx).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed:
                                          () => Navigator.of(ctx).pop(true),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await _postService.deletePostAndRelated(postId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Post and all related data deleted',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      )
                    else
                      IconButton(
                        icon: Icon(
                          hasReported ? Icons.flag : Icons.flag_outlined,
                          color: hasReported ? Colors.orange : null,
                        ),
                        onPressed: () async {
                          if (hasReported) {
                            await _postService.removeReport(postId);
                            if (mounted) setState(() => hasReported = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report removed')),
                            );
                            return;
                          }
                          final reasonController = TextEditingController();
                          await showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  title: Text(
                                    'Report Post',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  content: TextField(
                                    controller: reasonController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reason for reporting',
                                      hintText:
                                          'Describe the issue with this post',
                                    ),
                                    maxLines: 3,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text(
                                        'Cancel',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final reason =
                                            reasonController.text.trim();
                                        if (reason.isNotEmpty) {
                                          await _postService.submitReport(
                                            postId: postId,
                                            reason: reason,
                                            postData: widget.postData,
                                          );
                                          if (mounted)
                                            setState(() => hasReported = true);
                                          Navigator.of(ctx).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Post reported. Thank you!',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Submit',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _postService.commentStream(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(
                                  comment['userImage'] ?? '',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['username'] ?? 'User',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(comment['text'] ?? ''),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
