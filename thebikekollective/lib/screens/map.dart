import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/create_map_body.dart';
import '../screens/ride_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Screen',
      home: Scaffold(
        appBar: AppBar(
          title: createMapTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: CreateMapBody(),
      ),
      routes: {
        'rideScreen': (context) => RideScreen(),
      }
    );
  }
}

Widget createMapTitle() {
  return FormattedText(
    text: 'Map',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}


