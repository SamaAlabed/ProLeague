import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.title,
    this.onPressed,
    this.color,
  });

  final String title;
  final void Function()? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            color ?? Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Text(title),
    );
  }
}

class SocialButtonItem extends StatelessWidget {
  final ButtonType buttonType;
  final VoidCallback onTap;

  const SocialButtonItem({
    super.key,
    required this.buttonType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlutterSocialButton(
        onTap: onTap,
        buttonType: buttonType,
        mini: true,
      ),
    );
  }
}
