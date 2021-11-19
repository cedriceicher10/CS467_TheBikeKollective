import 'package:flutter/material.dart';
import 'package:practice1/components/complete_ride_form.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/complete_ride_form.dart';

class CompleteRideScreen extends StatelessWidget {
  const CompleteRideScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: completeRideScreenTitle(),
        backgroundColor: Color(s_jungleGreen),
        centerTitle: true,
      ),
      body: CompleteRideForm(),
    );
  }

  Widget completeRideScreenTitle() {
    return FormattedText(
      text: "How'd It Go?",
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}