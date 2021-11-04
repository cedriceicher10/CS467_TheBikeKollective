import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/interest_form_body.dart';

class InterestFormScreen extends StatelessWidget {
  const InterestFormScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: addInterestFormTitle(),
        backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
      ),
      body: InterestFormBody(),
    );
  }

  Widget addInterestFormTitle() {
    return FormattedText(
      text: 'Release of Interest',
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}
