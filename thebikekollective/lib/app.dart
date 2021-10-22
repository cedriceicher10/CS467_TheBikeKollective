import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/splash_screen.dart';
import '/screens/waiver_screen.dart';
import '/components/styles.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loginCheck(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (loggedIn) {
            return SplashScreen(); // When LIVE, turn this to WaiverScreen()
          } else {
            return SplashScreen();
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
          ));
        }
      },
    );
  }

  Future<void> loginCheck() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    loggedIn = preferences.getBool('loggedIn')!;
  }
}
