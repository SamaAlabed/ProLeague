import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<void> toggleLike(String postId, bool isLiked) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({
      'likes':
          isLiked
              ? FieldValue.arrayRemove([currentUserId])
              : FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    return userDoc.data();
  }

  Future<void> addComment(
    String postId,
    String text,
    Map<String, dynamic> userData,
  ) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'text': text.trim(),
          'userId': currentUserId,
          'timestamp': Timestamp.now(),
          'username': userData['username'] ?? 'User',
          'userImage': userData['image_url'] ?? '',
        });
  }

  Future<List<QueryDocumentSnapshot>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs;
  }

  Future<void> sharePostToChat({
    required String chatId,
    required Map<String, dynamic> postData,
  }) async {
    await _firestore.collection('messages').doc(chatId).collection('chat').add({
      'postShared': true,
      'postText': postData['text'] ?? '',
      'postImage': postData['imageUrl'] ?? '',
      'createdAt': Timestamp.now(),
      'userId': currentUserId,
      'username': _auth.currentUser?.displayName ?? 'Me',
      'profileImage': _auth.currentUser?.photoURL ?? '',
    });
  }

  Future<bool> hasUserReported(String postId) async {
    final reportDoc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('reports')
            .doc(currentUserId)
            .get();
    return reportDoc.exists;
  }

  Future<void> submitReport({
    required String postId,
    required String reason,
    required Map<String, dynamic> postData,
  }) async {
    final reportDoc = _firestore
        .collection('reports')
        .doc('$postId\_$currentUserId');
    await reportDoc.set({
      'reportedAt': Timestamp.now(),
      'userId': currentUserId,
      'postId': postId,
      'postText': postData['text'] ?? '',
      'postImage': postData['imageUrl'] ?? '',
      'postOwnerId': postData['uid'] ?? '',
      'reason': reason,
    });
  }

  Future<void> removeReport(String postId) async {
    final reportDoc = _firestore
        .collection('reports')
        .doc('$postId\_$currentUserId');
    await reportDoc.delete();
  }

  Future<void> deletePostAndRelated(String postId) async {
    final postDocRef = _firestore.collection('posts').doc(postId);

    final commentsSnapshot = await postDocRef.collection('comments').get();
    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    final reportsSnapshot =
        await _firestore
            .collection('reports')
            .where('postId', isEqualTo: postId)
            .get();
    for (var report in reportsSnapshot.docs) {
      await report.reference.delete();
    }

    await postDocRef.delete();
  }

  Stream<DocumentSnapshot> postStream(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots();
  }

  Stream<QuerySnapshot> commentStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> allPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> incrementMetric(String screenName) async {
    await _firestore.collection('dashboard_metrics').doc('screen_views').set({
      screenName: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
}

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<Map<String, dynamic>> _getLastMessageAndUser(
    DocumentSnapshot userDoc,
  ) async {
    final userId = userDoc.id;
    final participants = [currentUserId, userId]..sort();
    final chatId = '${participants[0]}_${participants[1]}';

    final query =
        await _firestore
            .collection('messages')
            .doc(chatId)
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    Timestamp? lastTimestamp;
    String lastMessage = '';

    if (query.docs.isNotEmpty) {
      final msgData = query.docs.first.data();
      lastTimestamp = msgData['createdAt'];
      lastMessage = msgData['text'] ?? '';
    }

    return {
      'userDoc': userDoc,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
    };
  }

  Future<List<Map<String, dynamic>>> getUsersSortedByRecentChat() async {
    final usersSnapshot = await _firestore.collection('users').get();

    final otherUsers =
        usersSnapshot.docs.where((doc) => doc.id != currentUserId).toList();

    final futures = otherUsers.map(_getLastMessageAndUser).toList();

    final result = await Future.wait(futures);

    result.sort((a, b) {
      final aTime = a['lastTimestamp'] as Timestamp?;
      final bTime = b['lastTimestamp'] as Timestamp?;
      return (bTime?.compareTo(aTime ?? Timestamp(0, 0)) ?? 0);
    });

    return result;
  }
}
