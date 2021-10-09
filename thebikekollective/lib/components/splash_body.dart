import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
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
    loginButton(buttonWidth, buttonHeight),
    SizedBox(height: buttonSpacing),
    createAccountButton(buttonWidth, buttonHeight),
    SizedBox(height: buttonSpacing),
    googleAuthButton(buttonWidth, buttonHeight),
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
          loginButton(buttonWidth, buttonHeight),
          SizedBox(height: buttonSpacing),
          createAccountButton(buttonWidth, buttonHeight),
          SizedBox(height: buttonSpacing),
          googleAuthButton(buttonWidth, buttonHeight),
        ]))
  ]);
}

Widget loginButton(double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {},
      child: loginText(),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget createAccountButton(double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {},
      child: createAccountText(),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget googleAuthButton(double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {},
      child: googleAuthText(),
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

Widget loginText() {
  return FormattedText(
    text: 'Login',
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget createAccountText() {
  return FormattedText(
    text: 'Create Account',
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget googleAuthText() {
  return FormattedText(
    text: 'Sign in with Google',
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
