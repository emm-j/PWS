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
      else if (dagelijksevoortgang >= 0.61 && dagelijksevoortgang <= 0.81) {
        setState(() {
          kleur = Color.fromRGBO(151, 200, 130, 1);
        });
      }
      else if (dagelijksevoortgang >= 0.81 && dagelijksevoortgang <= 1) {
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
              onPressed: _hogeredagelijksevoortgang,
              child: const Icon(Icons.add)
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
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.pushNamed(context, '/instelling');
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(30, 50, 30, 0),
            width: 400,
            height: 30,
            color: Colors.amber,
            child: TextField(

            ),
          )
        ]
      )
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

