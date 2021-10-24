import 'package:flutter/material.dart';
import 'add_bike_form.dart';
import 'styles.dart';

class AddBikeBody extends StatelessWidget {
  const AddBikeBody({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final double buttonSpacing = 8;

    return SingleChildScrollView(
        child: Center(
            child: Column(children: [
      SizedBox(height: headspaceFactor(context)),
      AddBikeForm(),
      SizedBox(height: buttonSpacing * 2),
      FractionallySizedBox(
          widthFactor: imageSizeFactor(context),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 3, color: Color(s_jungleGreen)),
                  borderRadius: BorderRadius.circular(5)),
              child: Image(
                image: AssetImage('assets/images/bike_clipart.jpg'),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ));
                },
              ))),
      SizedBox(height: buttonSpacing * 2)
    ])));
  }

  double imageSizeFactor(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return 0.5;
    } else {
      return 0.15;
    }
  }

  double headspaceFactor(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return 60;
    } else {
      return 20;
    }
  }
}
