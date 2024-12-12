import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:projecten/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gedeeldelijsten.dart';

class CustomPopup extends StatefulWidget {
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
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  void saveLijst() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gehaald', gehaaldeDoelen);
  }

  void loadLijst() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gehaaldeDoelen = prefs.getStringList('gehaald')!;
    });
  }

  void resetLijst() async {
    gehaaldeDoelen = [];
    saveLijst();
  }
  late String currentKnopText;
  late int currentIndex;

  void initState() {
    super.initState();
    currentKnopText = widget.knopText;
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    var achtergrondkleur = currentIndex == gehaaldeDoelen.length + 1
        ? Colors.amber[100]
        : (currentIndex < gehaaldeDoelen.length + 1
        ? Colors.green[100]
        : Colors.red[100]);
    return AlertDialog(
      backgroundColor: achtergrondkleur,
      title: Center(
        child: Text(
          widget.title,
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
             Text(widget.content,
               style: TextStyle(
               fontFamily: "Tekst",
               fontSize: 20,
               fontWeight: FontWeight.w400,
               color: Colors.grey[800],
             ),
             ),
             TextButton(onPressed: () async {
               if (widget.index == gehaaldeDoelen.length + 1) {
                 gehaaldeDoelen.add((widget.index).toString());
                 setState(() {
                   currentKnopText = 'Voltooid';
                   achtergrondkleur = Colors.green[100];
                   resetTotaal();
                   saveLijst();
                 });
               }
               else if (widget.index <= gehaaldeDoelen.length) {
                 print('Al voltooid');
                 resetLijst();
               }
               }, child: Text('$currentKnopText'))
           ],
         ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Sluit de popup
            if (widget.onButtonPressed != null) {
              widget.onButtonPressed!();
            }
          },
          child: Center(
            child: Text(widget.buttonText,
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