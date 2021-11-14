import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
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

    /*
      NOTE: THIS IS ALL ROUGH DRAFT CODE TO GET YOU STARTED CONNOR - THIS IS ROUGHLY WHAT SHOULD BE HAPPENING DATABASE-WISE
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
  */
}