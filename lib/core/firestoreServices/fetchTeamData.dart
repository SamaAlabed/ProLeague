import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:grad_project/core/firestoreServices/firestoreHelper.dart';

class CoachService {
  static Future<List<Map<String, dynamic>>> fetchAllCoaches() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Coaches').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching coaches: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchCoachByTeam(String teamName) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Coaches').get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if ((data['TeamName'] ?? '').toString().toLowerCase() ==
            teamName.toLowerCase()) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class TeamService {
  static Future<Map<String, List<Map<String, dynamic>>>> fetchPlayersByRole(
    String teamName,
  ) async {
    try {
      final teamsSnapshot =
          await FirebaseFirestore.instance.collection('teams').get();

      final cleanedInput = teamName.toLowerCase().replaceAll(
        RegExp(r'[\s\-]'),
        '',
      );

      for (final doc in teamsSnapshot.docs) {
        final rawName = (doc.data()['TeamName'] ?? '').toString();
        final normalizedName = rawName.toLowerCase().replaceAll(
          RegExp(r'[\s\-]'),
          '',
        );

        if (normalizedName.contains(cleanedInput)) {
          final membersSnapshot =
              await doc.reference.collection('Members').get();

          final Map<String, List<Map<String, dynamic>>> roles = {
            "Goalkeepers": [],
            "Defenders": [],
            "Midfielders": [],
            "Forwards": [],
          };

          for (final playerDoc in membersSnapshot.docs) {
            final data = playerDoc.data();
            final roleRaw =
                (FirestoreHelper.getField(data, 'Role') ?? '').toLowerCase();

            if (roleRaw.contains('goal')) {
              roles['Goalkeepers']!.add(data);
            } else if (roleRaw.contains('defend')) {
              roles['Defenders']!.add(data);
            } else if (roleRaw.contains('mid')) {
              roles['Midfielders']!.add(data);
            } else if (roleRaw.contains('forward') ||
                roleRaw.contains('striker')) {
              roles['Forwards']!.add(data);
            }
          }

          return roles;
        }
      }

      return {
        "Goalkeepers": [],
        "Defenders": [],
        "Midfielders": [],
        "Forwards": [],
      };
    } catch (e) {
      return {
        "Goalkeepers": [],
        "Defenders": [],
        "Midfielders": [],
        "Forwards": [],
      };
    }
  }
}

class FixtureService {
  static Future<List<Map<String, dynamic>>> fetchFixtures(
    String teamName,
  ) async {
    try {
      final allTeamsSnapshot =
          await FirebaseFirestore.instance.collection('fixtures').get();

      DocumentSnapshot? matchedTeamDoc;
      final normalizedInputName = teamName.toLowerCase().replaceAll(
        RegExp(r'[\s\-]'),
        '',
      );

      for (final doc in allTeamsSnapshot.docs) {
        final data = doc.data();
        final rawName = data['TeamName']?.toString() ?? '';
        final normalizedFirestoreName = rawName.toLowerCase().replaceAll(
          RegExp(r'[\s\-]'),
          '',
        );

        if (normalizedFirestoreName.contains(normalizedInputName) ||
            normalizedInputName.contains(normalizedFirestoreName)) {
          matchedTeamDoc = doc;
          break;
        }
      }

      if (matchedTeamDoc == null) {
        return [];
      }

      final teamData = matchedTeamDoc.data() as Map<String, dynamic>;
      final docId = matchedTeamDoc.id;
      final display = teamData['Display'] ?? 'HOM';
      final teamLogo = teamData['TeamLogo'] ?? '';

      final fixturesSnapshot =
          await FirebaseFirestore.instance
              .collection('fixtures')
              .doc(docId)
              .collection('TeamFixtures')
              .get();

      return fixturesSnapshot.docs.map((doc) {
        final data = doc.data();

        if (data['DateTime'] is Timestamp) {
          final formatter = DateFormat('d MMM yyyy • hh:mm a');
          data['DateTime'] = formatter.format(
            (data['DateTime'] as Timestamp).toDate(),
          );
        }

        data['Display'] = display;
        data['TeamLogo'] = teamLogo;

        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchResults(
    String teamName,
  ) async {
    try {
      final allTeamsSnapshot =
          await FirebaseFirestore.instance.collection('results').get();

      DocumentSnapshot? matchedTeamDoc;
      final normalizedInputName = teamName.toLowerCase().replaceAll(
        RegExp(r'[\s\-]'),
        '',
      );

      for (final doc in allTeamsSnapshot.docs) {
        final teamData = doc.data();
        final rawName = teamData['TeamName']?.toString() ?? '';
        final normalizedFirestoreName = rawName.toLowerCase().replaceAll(
          RegExp(r'[\s\-]'),
          '',
        );

        if (normalizedFirestoreName.contains(normalizedInputName) ||
            normalizedInputName.contains(normalizedFirestoreName)) {
          matchedTeamDoc = doc;
          break;
        }
      }

      if (matchedTeamDoc == null) {
        return [];
      }

      final teamData = matchedTeamDoc.data() as Map<String, dynamic>;
      final docId = matchedTeamDoc.id;

      final display = teamData['Display'] ?? 'HOM';
      final teamLogo = teamData['TeamLogo'] ?? '';

      final resultsSnapshot =
          await FirebaseFirestore.instance
              .collection('results')
              .doc(docId)
              .collection('TeamResults')
              .get();

      return resultsSnapshot.docs.map((doc) {
        final data = doc.data();

        if (data['DateTime'] is Timestamp) {
          final formatter = DateFormat('d MMM yyyy • hh:mm a');
          data['DateTime'] = formatter.format(
            (data['DateTime'] as Timestamp).toDate(),
          );
        }

        data['Display'] = display;
        data['TeamLogo'] = teamLogo;

        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserFavorites(List<String> selectedTeams) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final username = userDoc.data()?['username'] ?? 'Unknown';

    await _firestore.collection('favorite_teams').doc(user.uid).set({
      'userId': user.uid,
      'username': username,
      'teams': selectedTeams,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
