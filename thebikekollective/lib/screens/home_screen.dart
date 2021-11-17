import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../components/styles.dart';
import '../components/home_body.dart';
<<<<<<< Updated upstream
import '../components/side_menu.dart';
import 'interest_form_screen.dart';
import 'add_bike_screen.dart';
=======
<<<<<<< Updated upstream
=======
import '../components/side_menu.dart';
import 'interest_form_screen.dart';
import 'add_bike_screen.dart';
import 'ride_screen.dart';
>>>>>>> Stashed changes
>>>>>>> Stashed changes

class HomeScreen extends StatefulWidget {
  final bool map;

  const HomeScreen({Key? key, required this.map}) : super(key: key);

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
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings, color: Color(s_lightPurple)),
                  onPressed: () {})
            ]),
        body: HomeBody(),
      ),
    );
=======
>>>>>>> Stashed changes
          ),
          drawer: SideMenu(),
          body: HomeBody(map: widget.map),
        ),
        routes: {
          'addBike': (context) => AddBikeScreen(),
          'interestForm': (context) => InterestFormScreen(),
<<<<<<< Updated upstream
        });
=======
          'rideScreen': (context) => RideScreen(),
        });
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
