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
      backgroundColor: Colors.amber[100],
      title: Center(
        child: Text(
          title,
          style: TextStyle(
          fontFamily: "Tekst",
          fontSize: 50,
          fontWeight: FontWeight.w800,
          color: Colors.grey[800],
        ),
        ),
      ),
      content: SizedBox(
        height: 700,
         width: 500,
         child: Text(content,
           style: TextStyle(
           fontFamily: "Tekst",
           fontSize: 20,
           fontWeight: FontWeight.w400,
           color: Colors.grey[800],
         ),
         ),
      ),
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