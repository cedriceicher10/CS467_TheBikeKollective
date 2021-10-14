import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'login_form.dart';
import 'styles.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final double imageHeadSpace = 60;
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    final double buttonSpacing = 8;

    return Center(
        child: Column(children: [
      SizedBox(height: imageHeadSpace),
      LoginForm(),
      SizedBox(height: buttonSpacing * 2),
      FractionallySizedBox(
          widthFactor: 0.5,
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
              )))
    ]));
  }
}
