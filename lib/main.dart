import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
  double dagelijksevoortgang = 0.0;
  String weergavedoelstappen = "0";
  var kleur = Color.fromRGBO(151, 200, 130, 1);

  void _hogeredagelijksevoortgang() {
    setState(() {
      dagelijksevoortgang = dagelijksevoortgang + 0.1;
      if (dagelijksevoortgang >= 1.0) {
        dagelijksevoortgang = 0.0;
      }
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
      else if (dagelijksevoortgang >= 0.61 && dagelijksevoortgang <= 0.91) {
        setState(() {
          kleur = Color.fromRGBO(151, 200, 130, 1);
        });
      }
      else if (dagelijksevoortgang >= 0.91 && dagelijksevoortgang <= 1) {
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
                final result = await Navigator.pushNamed(context, '/instelling');
                if (result != null && result is String) {
                  setState(() {
                    weergavedoelstappen = result;
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
                  const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 150, 30, 0),
                      child: Center(
                        child: Text(
                          '3.338',
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
                      Text("$weergavedoelstappen",
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
  TextEditingController _controller = TextEditingController();
  late int doelstappen;

  void _toonInvoer() {
    String userInput = _controller.text;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Je invoer is: $userInput')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(30, 100, 30, 0),
            height: 200,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Voer iets in',
                  labelStyle: TextStyle(
                    fontFamily: "Tekst",
                    fontSize: 30,
                  ),// Labeltekst
                  hintText: 'Bijvoorbeeld: Naam', // Plaatshoudertekst
                  border: OutlineInputBorder()
            ),
          )
          ),
          IconButton(
            onPressed: _toonInvoer,
            icon: Icon(Icons.send)
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
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