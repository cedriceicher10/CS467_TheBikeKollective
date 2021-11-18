import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'styles.dart';

class AddBikeFAB extends StatefulWidget {
  const AddBikeFAB({Key? key}) : super(key: key);

  @override
  _AddBikeFab createState() => _AddBikeFab();
}

class _AddBikeFab extends State<AddBikeFAB> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "Add Bike FAB",
      onPressed: () async {
        //final url = await getImage();
        Navigator.of(context).pushNamed('interestForm');
      },
      tooltip: 'Toggle View',
      backgroundColor: Color(s_lightPurple),
      child: Icon(Icons.add, size: 30),
    );
  }

  /*
  Future getImage() async {
    File? image;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    image = File(pickedFile!.path);

    var fileName = DateTime.now().toString() + '.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    final url = await storageReference.getDownloadURL();
    return url;
  }
  */
}
