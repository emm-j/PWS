import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;

  final VoidCallback? onButtonPressed;

  const CustomPopup({
    Key? key,
    required this.title,
    required this.content,
    this.buttonText = 'OK',
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Sluit de popup
            if (onButtonPressed != null) {
              onButtonPressed!();
            }
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}