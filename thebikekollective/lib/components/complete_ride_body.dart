import 'package:flutter/material.dart';
import 'complete_ride_form.dart';
import 'styles.dart';

class CompleteRideBody extends StatelessWidget {
  const CompleteRideBody({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final double buttonSpacing = 8;
    final url = ModalRoute.of(context)!.settings.arguments as String?;

    return SingleChildScrollView(
        child: Center(
            child: Column(children: [
      SizedBox(height: headspaceFactor(context)),
      CompleteRideForm(),
      SizedBox(height: buttonSpacing * 2),
      SizedBox(height: buttonSpacing * 2)
    ])));
  }

  double headspaceFactor(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return 60;
    } else {
      return 20;
    }
  }
}