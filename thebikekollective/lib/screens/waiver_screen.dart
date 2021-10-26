import 'package:flutter/material.dart';
import '../components/formatted_text.dart';
import '../components/styles.dart';
import '../components/waiver_body.dart';

class WaiverScreen extends StatelessWidget {
  const WaiverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waiver Screen',
      home: Scaffold(
        appBar: AppBar(
          title: waiverTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: WaiverBody(),
      ),
    );
  }
}

Widget waiverTitle() {
  return FormattedText(
    text: 'Liability Waiver',
    size: s_fontSizeExtraLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
