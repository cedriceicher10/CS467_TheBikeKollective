import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'styles.dart';

class HomeScreenToggle extends StatefulWidget {
  final bool map;

  const HomeScreenToggle({Key? key, required this.map}) : super(key: key);

  @override
  _HomeScreenToggle createState() => _HomeScreenToggle();
}

class _HomeScreenToggle extends State<HomeScreenToggle> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomeScreen(map: widget.map),
            transitionDuration: Duration.zero,
          ),
        );
      },
      tooltip: 'List View',
      backgroundColor: Color(s_lightPurple),
      child: Icon(Icons.view_list),
    );
  }
}
