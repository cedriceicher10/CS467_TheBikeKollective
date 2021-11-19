import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';

class RideFields {
  String? riderName;
  String? bikeId;
  String? bikeCondition;
  int? rideRating;
  double? startLat;
  double? startLong;
  double? endLat;
  double? endLong;
  RideFields({
    this.riderName,
    this.bikeId,
    this.bikeCondition,
    this.rideRating,
    this.startLat,
    this.startLong,
    this.endLat,
    this.endLong,
  });
}

class RideScreenBody extends StatefulWidget {
  const RideScreenBody({ Key? key }) : super(key: key);

  @override
  _RideScreenBodyState createState() => _RideScreenBodyState();
}

class _RideScreenBodyState extends State<RideScreenBody> {
  var locationService = Location();
  LocationData? locationData;
  String username = '';
  var rideId;

  @override

  void initState() {
    super.initState();
    retrieveLocation();
    retrieveUsername();
  }

  void retrieveLocation() async{

    locationData = await locationService.getLocation();
    setState(() {});
  }

  void retrieveUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString('username')!;
    setState(() {});
  }

Future<int> retrieveCombo(bikeId) async{
    var req = await FirebaseFirestore.instance
        .collection('bikes')
        .doc(bikeId).get();
    if(req.exists){
      Map<String, dynamic>? data = req.data();
      var c = data?['Combination'];
      return c;
    } else {
      return -1;
    }
  }

  Future<String> startRide(bikeId, startLat, startLong, riderName) async{
    var rideId = await FirebaseFirestore.instance
        .collection('rides')
        .add({'bike': bikeId, 'startLat' : startLat, 'startLong': startLong, 'rider': riderName, 'startTime': DateTime.now()})
        .then((docRef) {
          return docRef.id;
    });
    await FirebaseFirestore.instance
        .collection('bikes')
        .doc(bikeId)
        .update({
          'checkedOut': true
        });
    return rideId;
  }

  Widget build(BuildContext context) {
    final double imageHeadSpace = 20;
    final double textHorizPadding = 15;
    final double buttonHeight = 60;
    final double buttonWidth = 175;
    final double buttonSpacing = 10;

    final bikeId = ModalRoute
        .of(context)!
        .settings
        .arguments;
    final startLat = locationData!.latitude;
    final startLong = locationData!.longitude;
/*    if( startLat == null || startLong == null){
      return new Container();
    }*/
    final riderName = username;
    var comboNum;



    return Scaffold(
      body: Column(children: [
        Column(
          children: [

        Row(
          children: [FutureBuilder<int>(
              future: retrieveCombo(bikeId),
              builder: (context, snapshot) {
                int? returnData;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    returnData = snapshot.data;
                    comboNum = returnData;
                  };
                  return Container(
                      child: Column(
                        children: [
                          SizedBox(height: imageHeadSpace),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: textHorizPadding),
                              child: rideScreenText('Combination: ' + comboNum.toString())),
                          SizedBox(height: buttonSpacing * 5)
                        ],
                      ));
                  return Container(
                      child: FormattedText(
                        text: 'Bike combination: ' + comboNum.toString(),
                        size: s_fontSizeMedLarge,
                        color: Colors.black,
                        font: s_font_AmaticSC,
                        weight: FontWeight.bold,
                      )
                  );};
                return Center(child: Text('Loading...'));
              })
      ]),
            FutureBuilder<String>(
                future: startRide(bikeId, startLat, startLong, riderName),
                builder: (context, snapshot) {
                  String? returnData;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      returnData = snapshot.data;
                      rideId = returnData;
                    };
                    return Container(
                        child: Column(
                          children: [
                            SizedBox(height: imageHeadSpace * 3),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: textHorizPadding),
                                child: rideScreenTextSmaller('Username: ' + riderName + '\n' + 'Ride ID: ' + rideId + '\n')),
                            SizedBox(height: buttonSpacing),
                            endRideButton(context, rideId, bikeId, 'End Ride', buttonWidth, buttonHeight),
                          ],
                        ));
                    return Container(
                        child: FormattedText(
                          text: 'Username: ' + riderName + '\n' + 'Ride ID: ' + rideId,
                          size: s_fontSizeMedLarge,
                          color: Colors.black,
                          font: s_font_AmaticSC,
                          weight: FontWeight.bold,
                        )
                    );};
                  return Center(child: Text('Loading...'));
                }),
          ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          ],
        ),]
    ));

  }

  Widget rideScreenText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedLarge,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextSmaller(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      weight: FontWeight.bold,
    );
  }

  Widget endRideButton(BuildContext context, rideId, bikeId, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          print(rideId);
          locationData = await locationService.getLocation();
          await FirebaseFirestore.instance
              .collection('rides')
              .doc(rideId)
              .update({
                'ended': true,
                'endLat': locationData!.latitude,
                'endLong': locationData!.longitude
              });
          await FirebaseFirestore.instance
              .collection('bikes')
              .doc(bikeId)
              .update({
                'Latitude': locationData!.latitude,
                'Longitude': locationData!.longitude,
                'checkedOut': false
              });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(map: true)),
          );
        },
        child: endRideText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_declineRed),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget endRideText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }


/*
      NOTE: THIS IS ALL ROUGH DRAFT CODE TO GET YOU STARTED CONNOR - THIS IS ROUGHLY WHAT SHOULD BE HAPPENING DATABASE-WISE
<<<<<<< Updated upstream
          final bikeId = ModalRoute.of(context)!.settings.arguments;
          final startLat = locationData!.latitude;
          final startLong = locationData!.longitude;
          final riderName = //THIS NEEDS TO BE IMPLEMENTED - NEED TO PULL USER'S USERNAME
          String? rideId = '';

          //TO DO: timeStart and timeEnd
          await FirebaseFirestore.instance
            .collection('rides')
            .add({'bike': bikeId, 'startLat' : startLat, 'startLong': startLong, 'rider': riderName})
            .then(function(docRef) {
              rideId = docRef.id;
            });
          await FirebaseFirestore.instance
            .collection('bikes').doc('bikeId')
            .update({'checkedOut': true, 'Latitude' : startLat, 'Longitude': startLong});
          Navigator.of(context).pushNamed('completeRideForm', arguments: rideId);
        }
      },
=======
      //TO DO: timeStart and timeEnd

      await FirebaseFirestore.instance
          .collection('bikes').doc('bikeId')
          .update({'checkedOut': true, 'Latitude' : startLat, 'Longitude': startLong});
      Navigator.of(context).pushNamed('completeRideForm', arguments: rideId);
>>>>>>> Stashed changes
  */
}

