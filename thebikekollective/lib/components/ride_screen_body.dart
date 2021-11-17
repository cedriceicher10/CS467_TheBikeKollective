import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';

class RideFields {
  String? riderName;
  String? bikeId;
  String? bikeCondition;
  int? rideRating;
  double? startLat;
  double? startLong;
  double? endLat;
  double? endLong;
  RideFields({this.riderName, this.bikeId, this.bikeCondition, this.rideRating, this.startLat, this.startLong, this.endLat, this.endLong,});
}

class RideScreenBody extends StatefulWidget {
  const RideScreenBody({ Key? key }) : super(key: key);

  @override
  _RideScreenBodyState createState() => _RideScreenBodyState();
}

class _RideScreenBodyState extends State<RideScreenBody> {
  LocationData? locationData;
  String username = '';

  @override

  void initState() {
    super.initState();
    retrieveLocation();
    retrieveUsername();
  }

  void retrieveLocation() async{
    var locationService = Location();
    locationData = await locationService.getLocation();
    setState(() {});
  }

  void retrieveUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString('username')!;
    setState(() {});
  }

  Future<String> startRide(bikeId, startLat, startLong, riderName) async{
    var rideId = await FirebaseFirestore.instance
        .collection('rides')
        .add({'bike': bikeId, 'startLat' : startLat, 'startLong': startLong, 'rider': riderName, 'startTime': DateTime.now()})
        .then((docRef) {
      return docRef.id;
    });
    return rideId;
  }

  Widget build(BuildContext context) {
    final bikeId = ModalRoute
        .of(context)!
        .settings
        .arguments;
    final startLat = locationData!.latitude;
    final startLong = locationData!.longitude;
    final riderName = username;
    var rideId;


    return FutureBuilder<String>(
        future: startRide(bikeId, startLat, startLong, riderName),
        builder: (context, snapshot) {
          String? returnData;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              returnData = snapshot.data;
              rideId = returnData;
            };
            return Container(
                child: FormattedText(
                  text: riderName + ' ' + rideId,
                  size: s_fontSizeExtraLarge,
                  color: Colors.black,
                  font: s_font_AmaticSC,
                  weight: FontWeight.bold,
                )
            );};
          return Center(child: Text('Loading...'));
        });

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