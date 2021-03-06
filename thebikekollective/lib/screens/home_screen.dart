import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../components/styles.dart';
import '../components/home_body.dart';
import '../components/side_menu.dart';
import 'interest_form_screen.dart';
import 'add_bike_screen.dart';
import 'ride_screen.dart';
import 'image_select_screen.dart';
import 'complete_ride_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool map;
  final showWarning;

  const HomeScreen({Key? key, required this.map, this.showWarning}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Home Screen',
        home: Scaffold(
          appBar: AppBar(
            title: mainTitle(),
            backgroundColor: Color(s_jungleGreen),
            centerTitle: true,
          ),
          drawer: SideMenu(),
          body: HomeBody(map: widget.map, showWarning: widget.showWarning),
        ),
        routes: {
          'addBike': (context) => AddBikeScreen(),
          'interestForm': (context) => InterestFormScreen(),
          'rideScreen': (context) => RideScreen(),
          'rideScreenNotNew': (context) => RideScreen(newRide: false),
          'imageSelect': (context) => ImageSelectScreen(),
          'completeRideScreen': (context) => CompleteRideScreen()
        });
  }
}

Widget mainTitle() {
  return FormattedText(
    text: 'The Bike Kollective',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
