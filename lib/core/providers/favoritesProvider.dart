import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteTeamsNotifier extends StateNotifier<Set<String>> {
  FavoriteTeamsNotifier() : super({});

  void toggleTeam(String team) {
    if (state.contains(team)) {
      state = {...state}..remove(team);
    } else {
      state = {...state, team};
    }
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('favorite_teams')
        .doc(user.uid)
        .get();

    final teams = doc.data()?['teams'] as List<dynamic>? ?? [];
    state = teams.map((e) => e.toString()).toSet();
  }
}

final favoriteTeamsProvider =
    StateNotifierProvider<FavoriteTeamsNotifier, Set<String>>((ref) {
      return FavoriteTeamsNotifier();
    });
