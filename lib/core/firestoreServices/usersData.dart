import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSignupService {
  static Future<String?> signupUser({
    required String username,
    required String email,
    required String password,
    required File pickedImage,
    required String role,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await userCredential.user!.sendEmailVerification();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredential.user!.uid}.jpg');
      await storageRef.putFile(pickedImage);

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': username.trim(),
            'email': email.trim(),
            'role': role,
            'image_url': imageUrl,
            'created_at': Timestamp.now(),
          });

      await userCredential.user!.updateDisplayName(username.trim());

      return null; // Success (no error message)
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        return 'This email address is already in use.';
      } else if (error.code == 'weak-password') {
        return 'The password is too weak.';
      } else if (error.code == 'invalid-email') {
        return 'The email address is invalid.';
      } else {
        return 'Authentication failed. Please try again.';
      }
    } catch (e) {
      print('Signup error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

class UserProfileService {
  static Future<Map<String, String?>> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found.');
      return {'imageUrl': null, 'username': null};
    }

    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return {'imageUrl': data?['image_url'], 'username': data?['username']};
      } else {
        print('User document not found for UID: ${user.uid}');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }

    return {'imageUrl': null, 'username': null};
  }

  static Future<void> updateUserProfile({
    required String username,
    required String email,
    File? newImageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No authenticated user.");
    }

    String? imageUrl;

    if (newImageFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');
      await storageRef.putFile(newImageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    final updatedData = {'username': username.trim(), 'email': email.trim()};

    if (imageUrl != null) {
      updatedData['image_url'] = imageUrl;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(updatedData);

    await user.updateDisplayName(username.trim());
    await user.verifyBeforeUpdateEmail(email.trim());
  }
}

class PostService {
  static Future<void> uploadPost({
    required String text,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    String? imageUrl;
    if (imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'uid': user.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
      'likes': [],
      'shares': 0,
    });
  }
}
