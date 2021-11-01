import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../components/styles.dart';
import '../components/home_body.dart';
import '../components/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Screen',
      home: Scaffold(
        appBar: AppBar(
          title: mainTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        drawer: SideMenu(),
        body: HomeBody(),
      ),
    );
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
