import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/login_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      home: Scaffold(
        appBar: AppBar(
          title: loginTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: LoginBody(),
      ),
    );
  }
}

Widget loginTitle() {
  return FormattedText(
    text: 'Login',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
