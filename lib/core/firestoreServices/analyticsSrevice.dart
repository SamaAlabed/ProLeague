import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static Future<void> logScreenView(String screenName) async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }
}
