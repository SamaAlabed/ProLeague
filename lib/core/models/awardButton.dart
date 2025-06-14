import 'package:flutter/material.dart';

class AwardButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final Widget destinationPage;

  const AwardButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.destinationPage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => destinationPage),
          ),
      child: Container(
        width: 314,
        height: 186,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(label, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}