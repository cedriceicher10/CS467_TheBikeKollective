import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/add_bike_body.dart';

class AddBikeScreen extends StatelessWidget {
  const AddBikeScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: addBikeTitle(),
        backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
      ),
      body: AddBikeBody(),
    );
  }

  Widget addBikeTitle() {
    return FormattedText(
      text: 'Add your Bike',
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}
