import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../screens/add_bike_screen.dart';
import '../components/styles.dart';
import '../components/splash_body.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      home: Scaffold(
        appBar: AppBar(
          title: splashTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: SplashBody(),
      ),
      routes: {
        'addBike': (context) => AddBikeScreen(),
      }
    );
  }
}

Widget splashTitle() {
  return FormattedText(
    text: 'The Bike Kollective',
    size: s_fontSizeMedLarge,
    color: Colors.white,
    font: s_font_RedOctober,
    weight: FontWeight.bold,
  );
}
