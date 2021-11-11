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
      heroTag: "Toggle FAB",
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
      tooltip: 'Toggle View',
      backgroundColor: toggleColor(),
      child: toggleIcon(),
    );
  }

  Icon toggleIcon() {
    if (widget.map) {
      return Icon(Icons.location_on, size: 30);
    } else {
      return Icon(Icons.view_list, size: 30);
    }
  }

  Color toggleColor() {
    if (widget.map) {
      return Color(s_periwinkleBlue);
    } else {
      return Color(s_cadmiumOrange);
    }
  }
}
