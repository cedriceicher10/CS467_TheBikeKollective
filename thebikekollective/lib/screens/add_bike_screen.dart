import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';

class AddBikeScreen extends StatelessWidget {
  const AddBikeScreen({ Key? key }) : super(key: key);

  @override
    return MaterialApp(
      title: 'Add your Bike',
      home: Scaffold(
        appBar: AppBar(
          title: addBikeTitle(),
          backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
        ),
        body: AddBikeForm(),
      ),
    );
  }
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
