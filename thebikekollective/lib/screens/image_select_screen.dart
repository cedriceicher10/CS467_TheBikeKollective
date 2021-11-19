import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/image_select_body.dart';

class ImageSelectScreen extends StatelessWidget {
  const ImageSelectScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: imageSelectTitle(),
        backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
      ),
      body: ImageSelectBody(),
    );
  }

  Widget imageSelectTitle() {
    return FormattedText(
      text: 'Select Bike Image',
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}