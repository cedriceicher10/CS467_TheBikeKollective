import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/splash_screen.dart';

class BikeFields {
  String? bikeName;
  String? bikeDescription;
  String? bikeCondition;
  int? bikeCombination;
  double? latitude;
  double? longitude;
  String? imageURL;
  BikeFields({this. bikeName, this.bikeDescription, this.bikeCondition, this.bikeCombination, this.latitude, this.longitude, this.imageURL});
}

class AddBikeForm extends StatefulWidget {
  const AddBikeForm({ Key? key }) : super(key: key);

  @override
  _AddBikeFormState createState() => _AddBikeFormState();
}

class _AddBikeFormState extends State <AddBikeForm> {
  
  final formKey = GlobalKey<FormState>();
  var bikeFields = BikeFields();
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
    final url = ModalRoute.of(context)!.settings.arguments as String?;

    return Form(
      key: formKey,
      child: Column(children: [
        Container(width: 325, child: bikeNameEntry()),
        SizedBox(height: 10),
        Container(width: 325, child: bikeConditionEntry()),
        SizedBox(height: 10),
        Container(width: 325, child: bikeCombinationEntry()),
        SizedBox(height: 10),
        Container(width: 325, child: bikeDescriptionEntry()),
        SizedBox(height: 10),
        addBikeButton(buttonWidth, buttonHeight),
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
      bikeFields.bikeName = value;
    },
    validator: (value) {
      // TO DO: Query database for value, to check if the bike's name is already taken
      // bool alreadyTaken = false;

      if (value!.isEmpty) {
        return 'Please enter a name for the Bike';
        // } else if (alreadyTaken) {
        //   return 'Bike Name is already taken!';
      } 
      else if (value.length > 20) {
        return 'The name of the Bike may not be greater than 20 characters';
      } 
      else {
        return null;
      }
    }
  );}

  Widget bikeConditionEntry() {
    String? value;
    List<String> conditionList = ['Totaled', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      //style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
        labelText: 'Bike\'s Condition',
        labelStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        hintText: 'Please select the condition of the Bike',
        hintStyle: TextStyle(color: Color(s_jungleGreen)),
        errorStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
            const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
      onChanged: (value) {
        setState(() {
          bikeFields.bikeCondition = value as String?;
        });
      },
      onSaved: (value) {
        bikeFields.bikeCondition = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a Condition for the Bike';
        } 
      },
      items: conditionList.map((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value)
        );
      }).toList(),
    );
  }

  Widget bikeCombinationEntry() {
    return TextFormField(
      keyboardType: TextInputType.number,
      autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
        labelText: 'Bike Lock Combination',
        labelStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        hintText: 'Please enter the lock\'s combination',
        hintStyle: TextStyle(color: Color(s_jungleGreen)),
        errorStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
            const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
    onSaved: (value) {
      bikeFields.bikeCombination = int.parse(value!);
    },
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please enter a combination.';
      } 
      else if (value.length > 20) {
        return 'The combination may not be greater than 10 numbers.';
      } 
      else {
        return null;
      }
    }
  );}

  Widget bikeDescriptionEntry() {
    return TextFormField(
      autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
      decoration: InputDecoration(
        labelText: 'Bike Description',
        labelStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        hintText: 'Please describe the Bike',
        hintStyle: TextStyle(color: Color(s_jungleGreen)),
        errorStyle: TextStyle(
          color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide:
            const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
    onSaved: (value) {
      bikeFields.bikeDescription = value;
    },
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please enter a description';
      } 
      else if (value.length > 50) {
        return 'The description may not be greater than 50 characters';
      } 
      else {
        return null;
      }
    }
  );}

  Widget addBikeButton(double buttonWidth, double buttonHeight) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    bikeFields.imageURL = url;

    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          bikeFields.latitude = locationData!.latitude;
          bikeFields.longitude = locationData!.longitude;
          bikeFields.imageURL = url;

          print (
            Text(bikeFields.toString())
          );
          await FirebaseFirestore.instance
            .collection('bikes')
            .add({'Name': bikeFields.bikeName, 'Description': bikeFields.bikeDescription, 'Condition': bikeFields.bikeCondition, 'Combination': bikeFields.bikeCombination, 'Latitude': bikeFields.latitude, 'Longitude': bikeFields.longitude, 'imageURL': bikeFields.imageURL});
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Color(s_jungleGreen),
        fixedSize: Size(buttonWidth, buttonHeight)),
      child: FormattedText(
        text: 'Add Bike',
        size: s_fontSizeLarge,
        color: Colors.white,
        font: s_font_AmaticSC,
        weight: FontWeight.bold,
      )
    );
  }
}
