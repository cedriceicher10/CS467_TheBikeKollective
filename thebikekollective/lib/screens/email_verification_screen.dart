import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../components/styles.dart';
import '../components/email_verification_body.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

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
            body: EmailVerificationBody()));
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
