import 'package:flutter/material.dart';
import 'package:projecten/main.dart';

class CustomNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  const CustomNavigator({required Key key, required this.navigatorKey, required this.tabItem}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget child = HomePage();

    if(tabItem == "Levels")
      child = Levels();
    else if(tabItem == "Home")
      child = HomePage();
    else if(tabItem == "Settings")
      child = Settings();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
            builder: (context) => child
        );
      },
    );
  }
}