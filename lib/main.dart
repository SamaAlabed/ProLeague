import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'package:grad_project/screens/pages/splashScreen.dart';
import 'package:grad_project/core/providers/themeProvider.dart';
import 'package:grad_project/core/models/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro League',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      home: SplashScreen(),
    );
  }
}
