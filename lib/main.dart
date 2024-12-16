import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projecten/gedeeldelijsten.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'custompopup.dart';

var mainGroen = Color.fromRGBO(151, 200, 130, 1);
var mainOranje = Color.fromRGBO(255, 204, 111, 1);
int _doelstappen = 0;
List _volgenddoel = [100,250,500,1000,2500,5000,7500,10000,15000,20000,25000,30000,35000,40000,45000,50000,60000,70000,80000,100000];
String _doelstappenMetPunt = '0';
List _volgenddoelMetPunt = ['100','250','500','1.000','2.500','5.000','7.500', '10.000', '15.000', '20.000', '25.000''30.000','40.000','45.000','50.000', '60.000', '70.000', '80.000', '100.000'];
String _doelstappenweergeven = '0';
String _volgenddoelweergeven = '0';
String totalSteps = '0';
String _steps = '0';
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
      debugShowCheckedModeBanner: false,
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
  var kleur2 = mainGroen;
  late int dagelijksestappen = int.parse(_steps);
  double dagelijksevoortgang = 0.0;
  double voortgangsindsdoel = 0.0;
  void checkAndResetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastResetDate =
        prefs.getString('lastResetDate');

    String todayDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // Huidige datum

    if (lastResetDate != todayDate) {
      resetten(); // Reset stappen
      prefs.setString('lastResetDate', todayDate); // Update de opgeslagen datum
    }
  }
  void resetten() async {
     // Werk de offset bij
    setState(() {
      _stepOffset = int.parse(_steps) + _stepOffset;
      _steps = '0';
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
    loadStappen();
    haalInvoerop();
    didChangeDependencies();
  }

  void onStepCount(StepCount event) async {
    checkAndResetSteps();
    loadStappen();
    if (doelgehaald == false && int.parse(totalSteps) >= _volgenddoel[isdoelgehaald.length-1]) {
      doelgehaald = true;
      isdoelgehaald.add('gehaald');
      saveLijst();
      print(isdoelgehaald);
    }
    if (int.parse(_steps) <= 0) {
      _stepOffset = 0;
      saveOffset();
    }
    setState(() {
      _volgenddoelweergeven = _volgenddoelMetPunt[isdoelgehaald.length-1];
      int rawSteps = event.steps;
      totalSteps = (int.parse(totalSteps) - int.parse(_steps)).toString();
      _steps = (rawSteps - _stepOffset).toString();
      totalSteps = (int.parse(_steps) + int.parse(totalSteps)).toString();
    });
    saveStappen();
    _hogeredagelijksevoortgang();
    _hogerevoortgangsindsdoel();
    didChangeDependencies();
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
    if (_doelstappen == 0) {
      setState(() {
        dagelijksevoortgang = 0.0; // Voortgang kan niet worden berekend
      });
      return;
    }
    dagelijksevoortgang = int.parse(_steps) / _doelstappen;

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

  void _hogerevoortgangsindsdoel() {
    if (_volgenddoel == 0) {
      setState(() {
        voortgangsindsdoel = 0.0; // Voortgang kan niet worden berekend
      });
      return;
    }
    voortgangsindsdoel = int.parse(totalSteps) / _volgenddoel[isdoelgehaald.length-1];

    setState(() {
      if (voortgangsindsdoel <= 0.25) {
        setState(() {
          kleur2 = const Color.fromRGBO(255, 28, 0, 1);
        });
      } else if (voortgangsindsdoel >= 0.25 && voortgangsindsdoel <= 0.61) {
        setState(() {
          kleur2 = const Color.fromRGBO(255, 181, 0, 1);
        });
      } else if (voortgangsindsdoel >= 0.61 && voortgangsindsdoel < 1) {
        setState(() {
          kleur2 = const Color.fromRGBO(151, 200, 130, 1);
        });
      } else if (voortgangsindsdoel >= 1) {
        setState(() {
          kleur2 = const Color.fromRGBO(22, 143, 28, 1);
        });
      }
    });    }
  void _updateDoelstappen() {
    setState(() {
      _doelstappenweergeven = _doelstappenMetPunt;
    });
  }
  void _updateVolgenddoel() {
    setState(() {
      _volgenddoelweergeven = _volgenddoelMetPunt[isdoelgehaald.length-1];
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDoelstappen();
    _updateVolgenddoel();
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
                    const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                child: Center(
                  child: Text(
                    _steps,
                    style: const TextStyle(
                        fontSize: 65.0,
                        fontFamily: 'Tekst',
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(255, 204, 111, 1)),
                  ),
                )),
            Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30, 8, 30, 20),
                child: Center(
                    child: Text('stappen vandaag gezet',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Tekst',
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800])))),
            Padding(
                padding: const EdgeInsetsDirectional.all(10.0),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const Padding(padding: EdgeInsets.only(left: 250)),
                Text("$_doelstappenweergeven",
                    style: TextStyle(
                        fontFamily: "Tekst",
                        color: Colors.grey[800],
                        fontSize: 15,
                        fontWeight: FontWeight.w800))
              ],
            ),
            Padding(
                padding:
                const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                child: Center(
                  child: Text(
                    '$totalSteps',
                    style: const TextStyle(
                        fontSize: 65.0,
                        fontFamily: 'Tekst',
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(255, 204, 111, 1)),
                  ),
                )),
            Padding(
                padding:
                const EdgeInsetsDirectional.fromSTEB(30, 8, 30, 20),
                child: Center(
                    child: Text('stappen sinds vorige uitdaging',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Tekst',
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800])))),
            Padding(
                padding: const EdgeInsetsDirectional.all(10.0),
                child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: voortgangsindsdoel,
                        valueColor: AlwaysStoppedAnimation(kleur2),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const Padding(padding: EdgeInsets.only(left: 250)),
                Text("$_volgenddoelweergeven",
                    style: TextStyle(
                        fontFamily: "Tekst",
                        color: Colors.grey[800],
                        fontSize: 15,
                        fontWeight: FontWeight.w800))
              ],
            ),
            IconButton(onPressed: () {
              totalSteps = (int.parse(totalSteps) + 10000).toString();
              saveStappen();
              didChangeDependencies();
              totalSteps = (int.parse(totalSteps) + 10000).toString();
              if (doelgehaald == false && int.parse(totalSteps) >= _volgenddoel[isdoelgehaald.length-1]) {
                  print('jippie');
                  isdoelgehaald.add('gehaald');
                  saveLijst();
                  print(isdoelgehaald);
                  doelgehaald = true;
              }
              },
    icon: Icon(Icons.add)),
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
                    ),
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

  void loadLijst() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gehaaldeChallenge = prefs.getStringList('gehaald')!;
      isdoelgehaald = prefs.getStringList('doelen')!;
      print(isdoelgehaald);
    });
  }

  void resetLijst() async {
    gehaaldeChallenge = [];
    isdoelgehaald = ['test'];
    saveLijst();
  }
  List levelgetal = ['test','1','2','3', '4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'];
  List leveltext = ['test',
    "Loop 100 stappen om de challenge te ontgrendelen",
    "Loop 250 stappen om de challenge te ontgrendelen",
    "Loop 500 stappen om de challenge te ontgrendelen",
    "Loop 1.000 stappen om de challenge te ontgrendelen",
    "Loop 2.500 stappen om de challenge te ontgrendelen",
    "Loop 5.000 stappen om de challenge te ontgrendelen",
    "Loop 10.000 stappen om de challenge te ontgrendelen",
    "Loop 15.000 stappen om de challenge te ontgrendelen",
    "Loop 20.000 stappen om de challenge te ontgrendelen",
    "Loop 25.000 stappen om de challenge te ontgrendelen",
    "Loop 30.000 stappen om de challenge te ontgrendelen",
    "Loop 35.000 stappen om de challenge te ontgrendelen",
    "Loop 40.000 stappen om de challenge te ontgrendelen",
    "Loop 45.000 stappen om de challenge te ontgrendelen",
    "Loop 50.000 stappen om de challenge te ontgrendelen",
    "Loop 60.000 stappen om de challenge te ontgrendelen",
    "Loop 70.000 stappen om de challenge te ontgrendelen",
    "Loop 80.000 stappen om de challenge te ontgrendelen",
    "Loop 100.000 stappen om de challenge te ontgrendelen",
    ];
  @override
  void initState() {
    super.initState();
    loadLijst();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: ListView(
          children: [
            SizedBox(
              height: 50
            ),
            Column(
              children: [
                for (int i = 1; i < 8; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int index=((i-1)*3) + 1; index < (((i - 1)*3+3)+1) && index != 21; index++)
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: (index < gehaaldeChallenge.length + 1
                              ? mainGroen
                                  :
                              index <= isdoelgehaald.length
                              ? mainOranje
                                  :
                              index == gehaaldeChallenge.length + 1 && int.parse(totalSteps) < _volgenddoel[isdoelgehaald.length-1]
                              ? Color.fromRGBO(255, 56, 112, 0.8)
                              : Color.fromRGBO(255, 56, 112, 0.8)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextButton(
                          onPressed: () {
                              if (index <= isdoelgehaald.length) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomPopup(
                                      title: levelgetal[index],
                                      content: leveltext[index],
                                      index: index,
                                      knopText: index > isdoelgehaald.length
                                        ? ''
                                              :
                                          index ==
                                          gehaaldeChallenge.length + 1
                                          ? 'Voltooien'
                                          : (index < gehaaldeChallenge.length + 1
                                          ? 'Voltooid'
                                          : 'Voltooi eerst het vorige level'),
                                      buttonText: 'Sluiten',
                                      challengeSteps: _steps,
                                      tijd: DateTime.now().toString(),
                                      onButtonPressed: () {
                                        setState(() {
                                          Navigator.pushNamed(
                                              context, '/levels');
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Voltooi eerst het level hiervoor'),
                                      backgroundColor: Colors.redAccent,
                                    ));
                              }
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
          ],
        ),
        bottomNavigationBar: Container(
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
    );

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
  int? waarde = prefs.getInt('invoer');
  _doelstappen = waarde ?? 10000;
  _doelstappenMetPunt = getalMetPunt(_doelstappen.toString());
}
void slaInvoerop() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('invoer', _doelstappen);
}
void saveStappen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('stappen', totalSteps);
}
void loadStappen() async {
  final prefs = await SharedPreferences.getInstance();
  String? opgehaald = prefs.getString('stappen');
  totalSteps = opgehaald ?? '0';
}

void resetTotaal() async {
  totalSteps = await (int.parse(totalSteps) - _volgenddoel[isdoelgehaald.length-1]).toString();
  saveStappen();
}

void saveLijst() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('gehaald', gehaaldeChallenge);
  await prefs.setStringList('doelen', isdoelgehaald);
}

