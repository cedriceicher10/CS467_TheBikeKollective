import 'package:flutter/material.dart';
import 'package:practice1/components/styles.dart';

class MainBody extends StatefulWidget {
  const MainBody({Key? key}) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  double headSpace = 30;
  double edgePadding = 50;
  double searchBarWidth = 0;
  double searchBarHeight = 0;
  double mapWidth = 0;
  double mapHeight = 0;
  double addBikeWidth = 0;
  double addBikeHeight = 0;

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
                    SizedBox(height: 30),
                    placeholderBoxes('Search Bar Placeholder', searchBarWidth,
                        searchBarHeight),
                    SizedBox(height: 30),
                    placeholderBoxes('Map Placeholder', mapWidth, mapHeight),
                    SizedBox(height: 30),
                    placeholderBoxes(
                        'Add Bike Placeholder', addBikeWidth, addBikeHeight)
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
    mapHeight = screenHeight * 0.50;
    addBikeWidth = screenWidth * 0.50;
    addBikeHeight = screenHeight * 0.05;
  }
}
