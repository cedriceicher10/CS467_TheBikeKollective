//TO DO: Ride needs to "start" on map screen or list screen when button is clicked. At that time the start time should be stored and the document ID should be passed here so we can update instead of add?
//TO DO: Need to get bikeId which is the bike's documentId to update bike collection in database to change the condition and location based on results from this form
//TO DO: Need to finalize adding to rides collection making sure we pull lat long from the bike and store as startlat startlong also need start and end time for ride
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/home_screen.dart';

class RideFields {
  String? rideId;
  String? bikeCondition;
  int? rideRating;
  double? endLat;
  double? endLong;
  RideFields({
    this.rideId,
    this.bikeCondition,
    this.rideRating,
    this.endLat,
    this.endLong,
  });
}

class CompleteRideForm extends StatefulWidget {
  const CompleteRideForm({Key? key}) : super(key: key);

  @override
  _CompletRideForm createState() => _CompletRideForm();
}

class _CompletRideForm extends State<CompleteRideForm> {
  final formKey = GlobalKey<FormState>();
  var rideFields = RideFields();
  LocationData? locationData;

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    var locationService = Location();
    locationData = await locationService.getLocation();
    setState(() {});
  }

  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    final rideId = ModalRoute.of(context)!.settings.arguments as String?;

    return Form(
        key: formKey,
        child: Column(children: [
          Container(
              width: 325,
              child: anythingWrongText(
                  'Anything wrong? Please note it in the Bike\'s Condition for other users!')),
          SizedBox(height: 10),
          Container(width: 325, child: bikeConditionEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: rideRatingEntry()),
          SizedBox(height: 10),
          completeRideButton(buttonWidth, buttonHeight),
        ]));
  }

  Widget anythingWrongText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Color(s_jungleGreen),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
      align: TextAlign.center,
    );
  }

  Widget bikeConditionEntry() {
    String? value;
    List<String> conditionList = [
      'Totaled',
      'Poor',
      'Fair',
      'Good',
      'Great',
      'Excellent'
    ];
    return DropdownButtonFormField(
      value: value,
      //decoration: InputDecoration(autofocus: true,
      style: TextStyle(color: Color(s_jungleGreen)),
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
          rideFields.bikeCondition = value as String?;
        });
      },
      onSaved: (value) {
        rideFields.bikeCondition = value as String?;
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a Condition for the Bike';
        }
      },
      items: conditionList.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget rideRatingEntry() {
    return TextFormField(
        keyboardType: TextInputType.number,
        autofocus: false,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Ride Rating',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'Rate your ride from 1 - 5!',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          rideFields.rideRating = int.parse(value!);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a rating from 1-5.';
          } else if (int.parse(value) > 5) {
            return 'The rating may not be greater than 5.';
          } else if (int.parse(value) < 1) {
            return 'The rating may not be lower than 1.';
          } else {
            return null;
          }
        });
  }

  Widget completeRideButton(double buttonWidth, double buttonHeight) {
    String? rideId = ModalRoute.of(context)!.settings.arguments as String;
    String? bikeId;

    return ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();

            rideFields.endLat = locationData!.latitude;
            rideFields.endLong = locationData!.longitude;

            print(Text(rideFields.toString()));

            //TO DO: timeStart and timeEnd, startLat and startLong
            final rideDoc = await FirebaseFirestore.instance
                .collection('rides')
                .doc(rideId)
                .get();
            bikeId = rideDoc['bike'];
            await FirebaseFirestore.instance
                .collection('rides')
                .doc(rideId)
                .update({
              'endLat': rideFields.endLat,
              'endLong': rideFields.endLong,
              'rating': rideFields.rideRating,
              'endTime': DateTime.now()
            });
            await FirebaseFirestore.instance
                .collection('bikes')
                .doc(bikeId)
                .update({
              'Condition': rideFields.bikeCondition,
              'Latitude': rideFields.endLat,
              'Longitude': rideFields.endLong,
              'checkedOut': false
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(map: true)),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Complete Ride',
          size: s_fontSizeLarge,
          color: Colors.white,
          font: s_font_AmaticSC,
          weight: FontWeight.bold,
        ));
  }
}
