import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'styles.dart';
import 'add_bike_form.dart';
import 'formatted_text.dart';

class ImageSelectBody extends StatefulWidget {
  const ImageSelectBody({ Key? key }) : super(key: key);

  @override
  _ImageSelectBodyState createState() => _ImageSelectBodyState();
}

class _ImageSelectBodyState extends State<ImageSelectBody> {
  @override
  final double buttonHeight = 60;
  final double buttonWidth = 175;

  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cameraButton(context, 'Take a Picture', buttonWidth, buttonHeight),
          SizedBox(width: 20),
          galleryButton(context, 'From Gallery', buttonWidth, buttonHeight),
        ],
      ),
    );
  }

  Widget cameraButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    bool cameraChosen = true;
    return ElevatedButton(
        onPressed: () async {
          final url = await getImage(cameraChosen);
          Navigator.of(context).pushNamed('addBike', arguments: url);
        },
        child: cameraButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget galleryButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    bool cameraChosen = false;
    return ElevatedButton(
        onPressed: () async {
          final url = await getImage(cameraChosen);
          Navigator.of(context).pushNamed('addBike', arguments: url);
        },
        child: cameraButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Future getImage(bool cameraChosen) async {
    File? image;
    final picker = ImagePicker();
    if (cameraChosen) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      image = File(pickedFile!.path);
    }
    else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      image = File(pickedFile!.path);
    }

    var fileName = DateTime.now().toString() + '.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    final url = await storageReference.getDownloadURL();
    return url;
  }

  Widget cameraButtonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}



