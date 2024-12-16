import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:projecten/gedeeldelijsten.dart';
import 'package:projecten/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await prefs.setStringList('gehaald', gehaaldeChallenge);
  }

  void loadLijst() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gehaaldeChallenge = prefs.getStringList('gehaald')!;
    });
  }

  void resetLijst() async {
    gehaaldeChallenge = [];
    saveLijst();
  }
  late String currentKnopText;
  late int currentIndex;

  void initState() {
    super.initState();
    currentKnopText = widget.knopText;
    currentIndex = widget.index;
  }

  String getChallenge() {
    List Challenges = ['test',"Het is gelukt",
      "Loop 1500 stappen binnen 20 minuten.",
      "Loop 2000 stappen binnen 25 minuten.",
      "Loop 2500 stappen binnen 30 minuten.",
      "Loop 3000 stappen binnen 35 minuten.",
      "Loop 3500 stappen binnen 40 minuten.",
      "Loop 4000 stappen binnen 45 minuten.",
      "Loop 4500 stappen binnen 50 minuten.",
      "Loop 5000 stappen binnen 55 minuten.",
      "Loop 5500 stappen binnen 60 minuten.",
      "Loop 6000 stappen binnen 65 minuten.",
      "Loop 7000 stappen binnen 75 minuten.",
      "Loop 8000 stappen binnen 85 minuten.",
      "Loop 10000 stappen binnen 100 minuten.",
      "Loop 12000 stappen binnen 120 minuten.",
      "Loop 13000 stappen binnen 130 minuten.",
      "Loop 14000 stappen binnen 140 minuten.",
      "Loop 15000 stappen binnen 150 minuten.",
      "Loop 20000 stappen binnen 120 minuten.",
      "Loop 42.195 km binnen 5 uur (300 minuten)."];
    if (currentIndex <= isdoelgehaald.length) {
      return Challenges[currentIndex];
    }
    if (currentIndex > isdoelgehaald.length) {
      return '';
    }
    return 'Something went wrong!';
  }

  @override
  Widget build(BuildContext context) {
    var achtergrondkleur = currentIndex == gehaaldeChallenge.length + 1
        ? Colors.amber[100]
        : (currentIndex < gehaaldeChallenge.length + 1
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
             Text(getChallenge(),
               style: TextStyle(
                 fontFamily: "Tekst",
                 fontSize: 15,
                 fontWeight: FontWeight.w400,
                 color: Colors.grey[800],
               ),),
             TextButton(onPressed: () async {
               if (widget.index == gehaaldeChallenge.length + 1) {
                 gehaaldeChallenge.add((widget.index).toString());
                 doelgehaald = false;
                 setState(() {
                   currentKnopText = 'Voltooid';
                   achtergrondkleur = Colors.green[100];
                   resetTotaal();
                   saveLijst();
                 });
               }
               else if (widget.index <= gehaaldeChallenge.length) {
                 print('Al voltooid');
               }
               }, child: Container(
                 padding: EdgeInsetsDirectional.fromSTEB(10,10,10,10),
                 margin: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 30),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(Radius.circular(15))
                 ),
                 child: Text('$currentKnopText',
                 style: TextStyle(
                   decoration: TextDecoration.underline,
                 fontFamily: "Tekst",
                 fontSize: 20,
                 fontWeight: FontWeight.w600,
                 color: Colors.grey[800],
                              ),),
               ))
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