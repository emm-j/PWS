import 'package:flutter/material.dart';
List gehaaldeDoelen = [1,2,3,4,5];

class CustomPopup extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final int index;
  final String knopText;

  final VoidCallback? onButtonPressed;

  const CustomPopup({
    Key? key,
    required this.title,
    required this.content,
    required this.index,
    required this.knopText,
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
         child: Column(
           children: [
             Text(content,
               style: TextStyle(
               fontFamily: "Tekst",
               fontSize: 20,
               fontWeight: FontWeight.w400,
               color: Colors.grey[800],
             ),
             ),
             TextButton(onPressed: () {
               if (index == gehaaldeDoelen.length) {
                 gehaaldeDoelen.add(index);
                 print(gehaaldeDoelen);
               }
               else if (index < gehaaldeDoelen.length) {

               }
               else {
                 print('niks');
               }
             }, child: Text('$knopText'))
           ],
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
          child: Center(
            child: Text(buttonText,
              style: TextStyle(
              fontFamily: "Tekst",
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),),
          ),
        ),
      ],
    );
  }
}