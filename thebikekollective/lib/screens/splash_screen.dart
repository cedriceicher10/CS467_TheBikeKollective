import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
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
    );
  }
}

Widget splashTitle() {
  return FormattedText(
    text: 'The Bike Kollective',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
