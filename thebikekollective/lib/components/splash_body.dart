import 'package:flutter/material.dart';
import 'formatted_text.dart';
import '../screens/login_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/map.dart';
import 'styles.dart';

class SplashBody extends StatelessWidget {
  const SplashBody({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return oneColumn(context);
      } else {
        return twoColumn(context);
      }
    });
  }
}

Widget oneColumn(BuildContext context) {
  final double imageHeadSpace = 60;
  final double buttonHeight = 60;
  final double buttonWidth = 260;
  final double buttonSpacing = 8;

  return Center(
      child: Column(children: [
    SizedBox(height: imageHeadSpace),
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
    SizedBox(height: buttonSpacing * 2),
    loginButton(context, 'Login', buttonWidth, buttonHeight),
    SizedBox(height: buttonSpacing),
    createAccountButton(context, 'Create Account', buttonWidth, buttonHeight),
    SizedBox(height: buttonSpacing),
    googleAuthButton('Sign in with Google', buttonWidth, buttonHeight),
    SizedBox(height: buttonSpacing),
    mapButton(context, 'Map', buttonWidth, buttonHeight),
  ]));
}

Widget twoColumn(BuildContext context) {
  final double buttonHeight = 60;
  final double buttonWidth = 260;
  final double buttonSpacing = 6;

  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Expanded(
        child: FractionallySizedBox(
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
                )))),
    Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          loginButton(context, 'Login', buttonWidth, buttonHeight),
          SizedBox(height: buttonSpacing),
          createAccountButton(
              context, 'Create Account', buttonWidth, buttonHeight),
          SizedBox(height: buttonSpacing),
          googleAuthButton('Sign in with Google', buttonWidth, buttonHeight),
          SizedBox(height: buttonSpacing),
          mapButton(context, 'Map', buttonWidth, buttonHeight),
        ]))
  ]);
}

Widget loginButton(BuildContext context, String text, double buttonWidth,
    double buttonHeight) {
  return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: loginText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget createAccountButton(BuildContext context, String text,
    double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateAccountScreen()),
        );
      },
      child: createAccountText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget googleAuthButton(String text, double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {},
      child: googleAuthText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget mapButton(BuildContext context, String text,
    double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      },
      child: mapText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

double imageSizeFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 0.8;
  } else {
    return 0.85;
  }
}

Widget loginText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget createAccountText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget googleAuthText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget mapText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}