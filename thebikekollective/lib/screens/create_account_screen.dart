import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/create_account_body.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Account Screen',
      home: Scaffold(
        appBar: AppBar(
          title: createAccountTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: CreateAccountBody(),
      ),
    );
  }
}

Widget createAccountTitle() {
  return FormattedText(
    text: 'Create Account',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
