import 'styles.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import 'complete_ride_form.dart';

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
  final newRide;

  const RideScreenBody({ Key? key, this.newRide }) : super(key: key);

  @override
  _RideScreenBodyState createState() => _RideScreenBodyState();
}

class _RideScreenBodyState extends State<RideScreenBody> {
  var locationService = Location();
  LocationData? locationData;
  String username = '';
  var rideId;
  var startTime;
  Timer? timer;
  Timer? timeLeftTimer;
  var timeLeft;

  ValueNotifier<int> _notifier = ValueNotifier(9999999999);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timeLeftTimer?.cancel();

    super.dispose();
  }

  Future<String> retrieveUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString('username')!;
    return username;
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

  Future<String> retrieveImageUrl(bikeId) async{
    var req = await FirebaseFirestore.instance
        .collection('bikes')
        .doc(bikeId).get();
    if(req.exists){
      Map<String, dynamic>? data = req.data();
      var c = data?['imageURL'];
      return c;
    } else {
      return '';
    }
  }

  Future<String> startRide(bikeId, newRide) async{
    var r = locationService.getLocation().then((locationData) async {
      final startLat = locationData.latitude;
      final startLong = locationData.longitude;
      String? rideId;
      var riderName = await retrieveUsername();
      if( newRide != false ){
        var time = DateTime.now();
        startTime = (time.millisecondsSinceEpoch / 1000).floor();
        rideId = await FirebaseFirestore.instance
            .collection('rides')
            .add({
          'bike': bikeId,
          'startLat' : startLat,
          'startLong': startLong,
          'rider': riderName,
          'startTime': time,
          'ended': false,
          'rating': 1.0
            })
            .then((docRef) {
          return docRef.id;
        });
        await FirebaseFirestore.instance
            .collection('bikes')
            .doc(bikeId)
            .update({
          'checkedOut': true
        });
      } else {
        var q = await FirebaseFirestore.instance
            .collection('rides')
            .where('rider', isEqualTo: riderName)
            .get();
        for( var i=0; i<q.docs.length; i++ ){
          if( q.docs[i]['ended'] == false ){
            rideId = q.docs[i].id;
            print(q.docs[i]['startTime'].seconds);
            startTime = q.docs[i]['startTime'].seconds;
          }
        }

      }

      return rideId!;
    });
    return r;
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

    final riderName = username;
    var comboNum;
    var imageURL;



    return Center(
      child: Column(
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<int>(
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
                          rideScreenText('Combination: ' + comboNum.toString()),
                          SizedBox(height: buttonSpacing)
                        ],
                      ));
                };
                return Center(child: Text('Loading...'));
              })
        ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                    future: retrieveImageUrl(bikeId),
                    builder: (context, snapshot) {
                      String? returnData;
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          returnData = snapshot.data;
                          imageURL = returnData;
                        };
                        return Expanded(
                            child: FractionallySizedBox(
                                widthFactor: imageSizeFactor(context),
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 3, color: Color(s_jungleGreen)),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Image(
                                      image: NetworkImage(imageURL),
                                      loadingBuilder: (BuildContext context, Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                              AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ));
                                      },
                                    ))));
                      };
                      return Center();
                    })
              ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [FutureBuilder<String>(
                    future: startRide(bikeId, widget.newRide),
                    builder: (context, snapshot) {
                      String? returnData;
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          returnData = snapshot.data;
                          rideId = returnData;
                          var currentTime = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
                          timeLeft = ((startTime + (60 * 60 * 8)) - currentTime).toInt();
                          _notifier.value = timeLeft;
                          print(currentTime);
                          if (timeLeft > 0){
                            timer = Timer(Duration(seconds: ((startTime + (60 * 60 * 8)) - currentTime).toInt()), ()=>{
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                        title: Text("You're late!"),
                                        content: SingleChildScrollView(
                                            child: ListBody(
                                                children: <Widget>[
                                                  Text("You've kept the bike for more than "
                                                      "8 hours and are now late to return it. "
                                                      "If you keep the bike longer than 24 "
                                                      "hours, you will be banned from the Kollective.")
                                                ]
                                            )
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Got it'),
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ]
                                    );
                                  }
                              )
                            });
                          }

                          timeLeftTimer = Timer.periodic(Duration(seconds: 1), (t) {
                            timeLeft--;
                            _notifier.value = timeLeft;
                          });
                          print(((startTime + (60 * 60 * 8)) - currentTime).toString());
                        };
                        return Container(
                            child: Column(
                              children: [
                                SizedBox(height: imageHeadSpace * 3),
                                SizedBox(height: buttonSpacing),
                                endRideButton(context, rideId, bikeId, 'End Ride', buttonWidth, buttonHeight),
                                SizedBox(height: buttonSpacing * 2),
                                rideScreenTextSmaller("Time Left to Ride:"),
                                SizedBox(height: buttonSpacing),
                                ValueListenableBuilder(valueListenable: _notifier, builder: (BuildContext context, int tL, child){
                                  // Format function from Frank Treacy's answer to 'Formatting a Duration like HH:mm:ss'
                                  // on StackOverflow
                                  // https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss#answer-57897328
                                  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
                                  if( tL >= 0 ){
                                    return rideScreenText(format(Duration(seconds: tL)));
                                  } else {
                                    return Column(
                                      children: [
                                        rideScreenTextRed(format(Duration(seconds: tL))),
                                        SizedBox(height: buttonSpacing),
                                        rideScreenTextRedSmall("LATE")
                                      ],
                                    );
                                  }

                                })

                              ],
                            ));
                      };
                      return Center(child: Text('Loading...'));
                    }),]
            )


          ],)
    );

  }

  Widget rideScreenText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedLarge,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextRed(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeMedLarge,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextRedSmall(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeSmall,
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
          Navigator.of(context).pushNamedAndRemoveUntil('completeRideScreen', (_) => false, arguments: rideId);
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

  double imageSizeFactor(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return 0.8;
    } else {
      return 0.85;
    }
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

