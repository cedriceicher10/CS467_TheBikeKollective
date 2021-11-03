import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/email_verification_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  double headSpace = 30;
  double edgePadding = 50;
  double searchBarWidth = 0;
  double searchBarHeight = 0;
  double mapWidth = 0;
  double mapHeight = 0;
  double addBikeWidth = 0;
  double addBikeHeight = 0;
  double spacerHeight = 10;

  @override
  Widget build(BuildContext context) {
    collectResponsiveDims(context);
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(edgePadding),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    placeholderBoxes(
                        '(not a placeholder, just pointing out the settings gear in the upper right)',
                        searchBarWidth,
                        searchBarHeight),
                    SizedBox(height: spacerHeight),
                    placeholderBoxes('Search Bar Placeholder', searchBarWidth,
                        searchBarHeight),
                    SizedBox(height: spacerHeight),
                    placeholderBoxes('Map Placeholder', mapWidth, mapHeight),
                    SizedBox(height: spacerHeight),
                    placeholderBoxes(
                        'Add Bike Placeholder', addBikeWidth, addBikeHeight),
                    SizedBox(height: spacerHeight)
                  ]),
            )));
  }

  Widget placeholderBoxes(String text, double width, double height) {
    return Container(
      child: Text(text),
      width: width,
      height: height,
      decoration:
          BoxDecoration(border: Border.all(color: Color(s_lightPurple))),
    );
  }

  void collectResponsiveDims(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    searchBarWidth = screenWidth * 0.80;
    searchBarHeight = screenHeight * 0.05;
    mapWidth = screenWidth * 0.80;
    mapHeight = screenHeight * 0.45;
    addBikeWidth = screenWidth * 0.50;
    addBikeHeight = screenHeight * 0.05;
  }
}
