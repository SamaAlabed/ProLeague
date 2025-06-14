import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatelessWidget {
  FAQPage({super.key});

  static Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ProLeagueJordan@gmail.com',
      query: 'subject=App Support&body=Hello, I need help with...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client.';
    }
  }

  static Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '0797850883');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch phone dialer.');
    }
  }

  final List<Map<String, String>> faqs = [
    {
      "question": "What is Pro League?",
      "answer":
          "Pro League is a platform dedicated to celebrating and advancing Jordanian football. We connect players, teams, and fans to create a supportive and competitive community.",
    },
    {
      "question": "Who can use the Pro League app?",
      "answer":
          "Players, teams, coaches, scouts, and fans can all use the app. It's designed to connect every part of the Jordanian football community.",
    },
    {
      "question": "Is Pro League free to use?",
      "answer":
          "Yes, basic features are free. Premium features may be offered later to enhance your experience.",
    },
    {
      "question": "How do I report inappropriate content or behavior?",
      "answer":
          "You can report content or users within the app. Our team reviews all reports to ensure a respectful environment.",
    },
    {
      "question": "Can I follow multiple teams or players?",
      "answer":
          "Yes, you can follow as many teams and players as you want to get updates on their progress and activity.",
    },
    {
      "question": "How do I reset my password?",
      "answer":
          "On the login screen, tap 'Forgot Password?' and follow the instructions to reset it via your email.",
    },
    {
      "question": "Can I use the app outside of Jordan?",
      "answer":
          "Yes, the app works globally, but its main focus is on Jordanian football. Jordanians abroad are welcome!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text(
          'FAQs:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.map((faq) {
            return Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ExpansionTile(
                collapsedIconColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  faq['question']!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faq['answer']!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
          Divider(color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 10),
          Text(
            "If you have more questions feel free to reach out at:",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _launchEmail,
            child: Row(
              children: [
                Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 10),
                Text(
                  "ProLeagueJordan@gmail.com",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _launchPhone,
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 10),
                Text(
                  "0797850883",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
