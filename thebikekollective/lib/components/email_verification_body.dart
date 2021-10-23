import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'styles.dart';
import '/../screens/email_verification_screen.dart';

class EmailVerificationBody extends StatelessWidget {
  const EmailVerificationBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Email Verification Screen',
        home: Scaffold(
            appBar: AppBar(
              title: emailVerificationTitle(),
              backgroundColor: Color(s_jungleGreen),
              centerTitle: true,
            ),
            body: EmailVerificationScreen()));
  }

  Widget emailVerificationTitle() {
    return FormattedText(
      text: 'Email Verification',
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}
