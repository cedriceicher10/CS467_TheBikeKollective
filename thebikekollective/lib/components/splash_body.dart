import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/waiver_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({Key? key}) : super(key: key);

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return oneColumn(context);
      } else {
        return twoColumn(context);
      }
    });
  }

  Widget oneColumn(BuildContext context) {
    final double imageHeadSpace = 60;
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    final double buttonSpacing = 8;

    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/elena-m.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(s_disabledGray),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ],
                    border: Border.all(width: 3, color: Color(s_jungleGreen)),
                    borderRadius: BorderRadius.circular(5)),
                child: Container(
                    color: Colors.white,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: buttonSpacing * 2),
                          FractionallySizedBox(
                              widthFactor: imageSizeFactor(context),
                              child: Container(
                                  child: Image(
                                image: AssetImage(
                                    'assets/images/bike_clipart.jpg'),
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                      child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(s_jungleGreen)),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ));
                                },
                              ))),
                          SizedBox(height: buttonSpacing * 2),
                          loginButton(
                              context, 'Login', buttonWidth, buttonHeight),
                          SizedBox(height: buttonSpacing),
                          createAccountButton(context, 'Create Account',
                              buttonWidth, buttonHeight),
                          SizedBox(height: buttonSpacing),
                          googleAuthButton(context, 'Sign in with Google',
                              buttonWidth, buttonHeight),
                          SizedBox(height: buttonSpacing * 2),
                          // Login bypass for testing
                          // testUserButton(context, 'Test User', buttonWidth / 2, buttonHeight / 2),
                          // SizedBox(height: buttonSpacing * 2),
                        ])))));
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
      SingleChildScrollView(
          child: Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: buttonSpacing),
                        loginButton(
                            context, 'Login', buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        createAccountButton(context, 'Create Account',
                            buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        googleAuthButton(context, 'Sign in with Google',
                            buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        // Login bypass for testing
                        // testUserButton(context, 'Test User', buttonWidth / 2,
                        //     buttonHeight / 2),
                      ]))))
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
            MaterialPageRoute(
                builder: (context) => WaiverScreen(google: false)),
          );
        },
        child: createAccountText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget googleAuthButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaiverScreen(google: true)),
          );
        },
        child: createAccountText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget testUserButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(map: true)),
          );
        },
        child: testUserLogin(text),
        style: ElevatedButton.styleFrom(
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)));
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

  Widget testUserLogin(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_IBMPlexSans,
      weight: FontWeight.w500,
    );
  }
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

Widget addBikeText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
