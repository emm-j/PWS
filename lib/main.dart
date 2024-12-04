import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
int _doelstappen = 0;
String _doelstappenweergeven = '0';
String _steps = '0';
String userInput = '0';
bool magDoor = false;


void main() {
  runApp(const MyApp(
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        '/instelling': (context) => const Instellingen(),
      },
    );
  }


}

@override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage()
        );
  }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      print('Step Count not available');
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      print('geen toestemming');
    }
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  late int dagelijksestappen = int.parse(_steps);
  double dagelijksevoortgang = 0.0;
  var kleur = Color.fromRGBO(151, 200, 130, 1);

  void _hogeredagelijksevoortgang() {
    dagelijksevoortgang = dagelijksestappen / _doelstappen;

    setState(() {
      if (dagelijksevoortgang <= 0.25) {
        setState(() {
          kleur = Color.fromRGBO(255, 28, 0, 1);
        });
      }
      else if (dagelijksevoortgang >= 0.25 && dagelijksevoortgang <= 0.61) {
        setState(() {
          kleur = Color.fromRGBO(255, 181, 0, 1);
        });
      }
      else if (dagelijksevoortgang >= 0.61 && dagelijksevoortgang < 1) {
        setState(() {
          kleur = Color.fromRGBO(151, 200, 130, 1);
        });
      }
      else if (dagelijksevoortgang >= 1) {
        setState(() {
          kleur = Color.fromRGBO(22, 143, 28, 1);
        });
      }
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                magDoor = false;
                final result = await Navigator.pushNamed(context, '/instelling');
                if (result != null && result is String) {
                  setState(() {
                    _doelstappenweergeven = result;
                  });
                }
              },

              child: const Icon(Icons.arrow_forward)
          ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: AppBar(
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(151, 200, 130, 1),
              title: DateWidget(),
            ),
          ),
          body: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(30, 40, 30, 40),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 150, 30, 0),
                      child: Center(
                        child: Text(
                          _steps,
                          style: TextStyle(
                              fontSize: 82.0,
                              fontFamily: 'Tekst',
                              fontWeight: FontWeight.w800,
                              color: Colors.amber
                          ),
                        ),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          30, 15, 30, 20),
                      child: Center(
                          child: Text('stappen vandaag gezet',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Tekst',
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey[800])

                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: dagelijksevoortgang,
                              valueColor: AlwaysStoppedAnimation(kleur),
                              minHeight: 30,


                            ),
                          )
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("0",
                      style: TextStyle(
                        fontFamily: "Tekst",
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w800
                      )),
                      Padding(
                        padding: EdgeInsets.only(left: 250)
                      ),
                      Text("$_doelstappenweergeven",
                          style: TextStyle(
                              fontFamily: "Tekst",
                              color: Colors.grey[800],
                              fontSize: 20,
                              fontWeight: FontWeight.w800
                          ))
                    ],
                  ),
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.amber,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add,
                      size: 30),
                      onPressed: () {
                        _hogeredagelijksevoortgang();
                      }
                    )
                  )


                ],
              )

          )

      );
    }
  }

class Instellingen extends StatefulWidget {
  const Instellingen({super.key});

  @override
  State<Instellingen> createState() => _InstellingenState();
}

class _InstellingenState extends State<Instellingen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  late int doelstappen;
  late String gewichtLatenZien = ' ';
  bool magDoor = false;
  String doorgeefWaarde = '';

  void _toonInvoer() {
    String userInput = _controller.text;
    if (int.tryParse(userInput) != null && int.parse(userInput) >= 1000 && int.parse(userInput) <= 50000) {
      _doelstappen = int.parse(userInput);
      magDoor = true;
      doorgeefWaarde = getalMetPunt(userInput);
      setState(() {
        gewichtLatenZien = getalMetPunt(userInput);
      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vul een geldig getal tussen 1.000 en 50.000 in'),
            backgroundColor: Colors.redAccent,
          ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(30, 100, 30, 0),
              height: 200,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Voer je doelstappen in',
                    labelStyle: TextStyle(
                      fontFamily: "Tekst",
                      fontSize: 30,
                    ),// Labeltekst
                    hintText: 'Kies tussen 1.000 en 50.000', // Plaatshoudertekst
                    border: OutlineInputBorder()
              ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dit veld mag niet leeg zijn.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Voer een geldig getal in.';
                  }
                  if (int.parse(value) <= 1) {
                    return 'Kies meer dan 1000 stappen voor een resultaat (dikzak)';
                  }
                  if (int.parse(value) >= 50000) {
                    return 'Wees een beetje lief voor jezelf en kies een haalbaar doel';
                  }
                  return null;
                },
            )
            ),
            IconButton(
              onPressed: _toonInvoer,
              icon: Icon(Icons.send)
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(30,30,30,30),
              child: Text(
                  'Je doelstappen zijn: $gewichtLatenZien',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20.0,
                      fontFamily: 'Tekst',
                      fontWeight: FontWeight.w800
                  )
              )
            )
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
    if (magDoor == true) {
    Navigator.pop(context, doorgeefWaarde.toString());
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sla je keuze op'),
            backgroundColor: Colors.redAccent,
          ));
    }
    },
            child: const Icon(Icons.arrow_back)

      ),
    );
  }
}


class DateWidget extends StatelessWidget {
  const DateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('d MMMM').format(now);

    return Text(
        '$formattedDate',
        style: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontFamily: 'Tekst',
            fontWeight: FontWeight.w800
        )
    );

  }
}

getalMetPunt(getal) {
  final formatter = NumberFormat("#,###", "nl_NL"); // "nl_NL" voor Nederlandse notatie
  String _getalMetPunt = formatter.format(int.parse(getal));

  return _getalMetPunt;
}