import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _logAboutAppPageAnalytics();
  }

  Future<void> _logAboutAppPageAnalytics() async {
    String screenName = 'AboutAppPage';

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    await FirebaseFirestore.instance
        .collection('dashboard_metrics')
        .doc('screen_views')
        .set({screenName: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  final List<Map<String, String>> pages = [
    {
      "title": "Stay Updated with Jordan’s Best",
      "subtitle":
          "Never miss a match! Get real-time updates on the Jordan National Football Team’s fixtures, results, and match highlights. Stay ahead with all the action!",
      "icon": Icons.sports_soccer.codePoint.toString(),
    },
    {
      "title": "Meet the Players",
      "subtitle":
          "Explore detailed profiles of Jordan’s top footballers. Learn about their stats, positions, career history, and latest performances in one place!",
      "icon": Icons.person.codePoint.toString(),
    },
    {
      "title": "Get Live Match Insights",
      "subtitle":
          "Follow every game with live scores, in-depth stats, and play-by-play commentary. Experience the thrill of the match, wherever you are!",
      "icon": Icons.sports.codePoint.toString(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('About App', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconData(
                            int.parse(page['icon']!),
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 100,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 14 : 10,
                  height: _currentPage == index ? 14 : 10,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
