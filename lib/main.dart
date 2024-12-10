import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cron/cron.dart';
import 'custompopup.dart';

var mainGroen = Color.fromRGBO(151, 200, 130, 1);
var mainOranje = Color.fromRGBO(255, 204, 111, 1);
int _doelstappen = 0;
String _doelstappenMetPunt = '10.000';
String _doelstappenweergeven = '10.000';
String _steps = '1';
String userInput = '0';
bool magDoor = false;
int _stepOffset = 0;
List levels = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const Settings(),
        '/levels': (context) => const Levels()
      },
    );
  }
}

@override
Widget build(BuildContext context) {
  return const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  var kleur = mainGroen;
  late int dagelijksestappen = int.parse(_steps);
  double dagelijksevoortgang = 0.0;

  void checkAndResetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastResetDate =
        prefs.getString('lastResetDate'); // Ophalen van opgeslagen datum

    String todayDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // Huidige datum

    if (lastResetDate != todayDate) {
      // Controle of reset nodig is
      resetten(); // Reset stappen
      prefs.setString('lastResetDate', todayDate); // Update de opgeslagen datum
    }
  }
  void resetten() {
    _stepOffset = int.parse(_steps) + _stepOffset; // Werk de offset bij
    setState(() {
      _steps = '0';
      dagelijksevoortgang = 0.0;
    });
    saveOffset(); // Sla de nieuwe offset op
  }
  void saveOffset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stepOffset', _stepOffset);
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('lastResetDate', todayDate); // Sla de datum op
  }
  void loadOffset() async {
    final prefs = await SharedPreferences.getInstance();
    _stepOffset = prefs.getInt('stepOffset') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkAndResetSteps();
    loadOffset();
    haalInvoerop();
  }

  void onStepCount(StepCount event) async {
    setState(() {
      int rawSteps = event.steps;
      _steps = (rawSteps - _stepOffset).toString();
    });
  }
  void onStepCountError(error) {
    setState(() {
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
    }
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void _hogeredagelijksevoortgang() {
    dagelijksevoortgang = dagelijksestappen / _doelstappen;

    setState(() {
      if (dagelijksevoortgang <= 0.25) {
        setState(() {
          kleur = const Color.fromRGBO(255, 28, 0, 1);
        });
      } else if (dagelijksevoortgang >= 0.25 && dagelijksevoortgang <= 0.61) {
        setState(() {
          kleur = const Color.fromRGBO(255, 181, 0, 1);
        });
      } else if (dagelijksevoortgang >= 0.61 && dagelijksevoortgang < 1) {
        setState(() {
          kleur = const Color.fromRGBO(151, 200, 130, 1);
        });
      } else if (dagelijksevoortgang >= 1) {
        setState(() {
          kleur = const Color.fromRGBO(22, 143, 28, 1);
        });
      }
    });    }
  void _updateDoelstappen() {
    setState(() {
      _doelstappenweergeven = _doelstappenMetPunt;
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDoelstappen();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(151, 200, 130, 1),
            title: const DateWidget(),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30, 150, 30, 0),
                child: Center(
                  child: Text(
                    _steps,
                    style: const TextStyle(
                        fontSize: 82.0,
                        fontFamily: 'Tekst',
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(255, 204, 111, 1)),
                  ),
                )),
            Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30, 15, 30, 20),
                child: Center(
                    child: Text('stappen vandaag gezet',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Tekst',
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800])))),
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
                ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("0",
                    style: TextStyle(
                        fontFamily: "Tekst",
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const Padding(padding: EdgeInsets.only(left: 250)),
                Text("$_doelstappenweergeven",
                    style: TextStyle(
                        fontFamily: "Tekst",
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w800))
              ],
            ),
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: mainOranje,
              ),
              child: IconButton(
                  icon: const Icon(Icons.add, size: 30),
                  onPressed: () {
                    _hogeredagelijksevoortgang();
                  }),
            ),
            Spacer(),
            Container(
              height: 80,
              decoration:
              BoxDecoration(color: Color.fromRGBO(151, 200, 130, 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      height: 60,
                      child: IconButton(
                        onPressed: () {Navigator.pushNamed(context, '/levels');}, icon: Icon(Icons.grid_view_rounded),
                        iconSize: 50
                        ,
                      )),
                  Container(
                      height: 60,
                      child: IconButton(
                        onPressed: () {}, icon: Icon(Icons.home, color: Colors.grey[100]),
                        iconSize: 50,
                      )),
                  Container(
                      height: 60,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                          },
                        icon: Icon(Icons.settings),
                        iconSize: 50,
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  late int doelstappen;
  bool magDoor = false;
  String doorgeefWaarde = '';


  void _toonInvoer() {
    String userInput = _controller.text;
    if (int.tryParse(userInput) != null &&
        int.parse(userInput) >= 1000 &&
        int.parse(userInput) <= 50000) {
        slaInvoerop();
        _doelstappen = int.parse(userInput);
        magDoor = true;
        doorgeefWaarde = getalMetPunt(userInput);
        setState(() {
          _doelstappenMetPunt = getalMetPunt(userInput);
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
        child: Column(children: <Widget>[
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
                    ), // Labeltekst
                    hintText:
                        'Kies tussen 1.000 en 50.000', // Plaatshoudertekst
                    border: OutlineInputBorder()),
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
              )),
          IconButton(onPressed: _toonInvoer, icon: const Icon(Icons.send)),
          Container(
              padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
              child: Text('Je doelstappen zijn: $_doelstappenMetPunt',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20.0,
                      fontFamily: 'Tekst',
                      fontWeight: FontWeight.w800))),
          Spacer(),

          Container(
            height: 80,
            decoration:
            BoxDecoration(color: Color.fromRGBO(151, 200, 130, 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: 60,
                    child: IconButton(
                        onPressed: () {Navigator.pushNamed(context, '/levels');},
                      icon: Icon(Icons.grid_view_rounded),
                      iconSize: 50
                    )),
                Container(
                    height: 60,
                    child: IconButton(
                      onPressed: () {
                        print(_doelstappen);
                        if (_doelstappen >= 1000 && _doelstappen <= 50000) {
                          _doelstappenMetPunt = getalMetPunt(_doelstappen.toString());
                          Navigator.pushNamed(context, '/');
                          didChangeDependencies();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Sla je keuze op'),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      },
                      icon: Icon(Icons.home),
                      iconSize: 50,
                    )),
                Container(
                    height: 60,
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.settings, color: Colors.grey[100]),
                        iconSize: 50
                    )),
              ],
            ),
          ),
        ]),

      ),

    );
  }
}

class Levels extends StatefulWidget {
  const Levels({super.key});

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  List levelgetal = ['test','1','2','3', '4','5','6','7','8','9','10','11','12'];
  List leveltext = ['test','Dit is level 1', 'Dit is level 2', 'Dit is level 3','Dit is level 4','Dit is level 5','Dit is level 6','test','test','test','test','test','test','test','test',];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            SizedBox(
              height: 50
            ),
            Column(
              children: [
                for (int i = 1; i < 7; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int index=((i-1)*3) + 1; index < (((i - 1)*3+3)+1); index++)
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: mainOranje,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomPopup(
                                  title: levelgetal[index],
                                  content: leveltext[index],
                                  buttonText: 'Sluiten',
                                  onButtonPressed: () {
                                    print('Popup gesloten!');
                                  },
                                );
                              },
                            );
                          },
                          child: Text('$index',
                          style: TextStyle(
                            fontFamily: "Tekst",
                            fontSize: 50,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),),
                        ),
                      ),
                        ],
                      ),

              ],

            ),
            Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10)
            ),
            Spacer(),
            Container(
              height: 80,
              decoration:
                  BoxDecoration(color: Color.fromRGBO(151, 200, 130, 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 60,
                      child: IconButton(
                          onPressed: () {}, icon: Icon(Icons.grid_view_rounded, color: Colors.grey[100]),
                        iconSize: 50
                        ,
                      )),
                  Container(
                      height: 60,
                      child: IconButton(
                        onPressed: () {Navigator.pushNamed(context, '/');}, icon: Icon(Icons.home),
                        iconSize: 50,
                      )),
                  Container(
                      height: 60,
                      child: IconButton(
                        onPressed: () {Navigator.pushNamed(context, '/settings');}, icon: Icon(Icons.settings),
                        iconSize: 50,
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}

class DateWidget extends StatelessWidget {
  const DateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('d MMMM').format(now);

    return Text('$formattedDate',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontFamily: 'Tekst',
            fontWeight: FontWeight.w800));
  }
}

getalMetPunt(getal) {
  final formatter = NumberFormat("#,###", "nl_NL");
  String _getalMetPunt = formatter.format(int.parse(getal));

  return _getalMetPunt;
}
void haalInvoerop() async {
  final prefs = await SharedPreferences.getInstance();
  String waarde = prefs.getString('invoer').toString();
  _doelstappen = int.parse(waarde);
}
void slaInvoerop() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('invoer', userInput);
}