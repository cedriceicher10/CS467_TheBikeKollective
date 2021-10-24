import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';

class AddBikeScreen extends StatefulWidget {
  const AddBikeScreen({ Key? key }) : super(key: key);

  @override
  _AddBikeScreenState createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends State<AddBikeScreen> {
  
  final formKey = GlobalKey<FormState>();
  var postFields = Post();
  LocationData? locationData;

  @override

  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async{
    var locationService = Location();
    locationData = await locationService.getLocation();
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
