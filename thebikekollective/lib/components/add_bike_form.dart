import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';

class BikeFields {
  String? bikeName;
  String? bikeDescription;
  String? bikeCondition;
  String? bikeCombination;
  String? latitude;
  String? longitude;
}

class AddBikeForm extends StatefulWidget {
  const AddBikeForm({ Key? key }) : super(key: key);

  @override
  _AddBikeFormState createState() => _AddBikeFormState();
}

class _AddBikeFormState extends State <AddBikeForm> {
  
  final formKey = GlobalKey<FormState>();
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
    final double buttonHeight = 60;
    final double buttonWidth = 260;

    return Form(
      key: formKey,
      child: Column(children: [
        Container(width: 325, child: bikeNameEntry()),
        SizedBox(height: 10),
        //Container(width: 325, child: bikeConditionEntry()),
        SizedBox(height: 10),
        //Container(width: 325, child: bikeCombinationEntry()),
        SizedBox(height: 10),
        //Container(width: 325, child: bikeDescriptionEntry()),
        SizedBox(height: 10),
        //addBikeButton(buttonWidth, buttonHeight),
      ])
    );
  }

  Widget bikeNameEntry() {
    return TextFormField(
      autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
        labelText: 'Bike Name',
        labelStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        hintText: 'Please enter the name of the Bike',
        hintStyle: TextStyle(color: Color(s_jungleGreen)),
        errorStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
            const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
    onSaved: (value) {
      BikeFields().bikeName = value;
    },
    validator: (value) {
      // TO DO: Query database for value, to check if the bike's name is already taken
      // bool alreadyTaken = false;

      if (value!.isEmpty) {
        return 'Please enter a name for the Bike.';
        // } else if (alreadyTaken) {
        //   return 'Bike Name is already taken!';
      } 
      else if (value.length > 20) {
        return 'The name of the Bike may not be greater than 20 characters.';
      } 
      else {
        return null;
      }
    }
  );}
}

