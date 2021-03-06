import '../utils/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../screens/splash_screen.dart';
import '../utils/preload_image.dart';

const WARNING_ALERT_TIME = 8 * 60 * 60; // Official: 8 hr, Testing: 10 sec
const MAX_ALERT_TIME = 24 * 60 * 60; // Official: 24 hr, Testing: 30 sec
const TIME_TO_BAN = MAX_ALERT_TIME - WARNING_ALERT_TIME;

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

  const RideScreenBody({Key? key, this.newRide}) : super(key: key);

  @override
  _RideScreenBodyState createState() => _RideScreenBodyState();
}

class _RideScreenBodyState extends State<RideScreenBody> {
  var locationService = Location();
  LocationData? locationData;
  String username = '';
  String bikeName = '';
  var rideId;
  var startTime;
  Timer? eightHourTimer;
  Timer? twentyFourHourTimer;
  Timer? timeLeftTimer;
  Timer? timeUntilBanTimer;
  var timeLeft;
  var timeUntilBan;

  ValueNotifier<int> _notifier = ValueNotifier(9999999999);
  ValueNotifier<int> _banNotifier = ValueNotifier(9999999999);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    eightHourTimer?.cancel();
    twentyFourHourTimer?.cancel();
    timeLeftTimer?.cancel();
    timeUntilBanTimer?.cancel();
    _notifier.dispose();
    _banNotifier.dispose();

    super.dispose();
  }

  Future<String> retrieveUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString('username')!;
    return username;
  }

  Future<int> retrieveCombo(bikeId) async {
    var req =
        await FirebaseFirestore.instance.collection('bikes').doc(bikeId).get();
    if (req.exists) {
      Map<String, dynamic>? data = req.data();
      var c = data?['Combination'];
      bikeName = data?['Name'];
      return c;
    } else {
      return -1;
    }
  }

  Future<String> retrieveImageUrl(bikeId) async {
    var req =
        await FirebaseFirestore.instance.collection('bikes').doc(bikeId).get();
    if (req.exists) {
      Map<String, dynamic>? data = req.data();
      var c = data?['imageURL'];
      // await loadImage(NetworkImage(c));
      return c;
    } else {
      return '';
    }
  }

  Future<String> startRide(bikeId, newRide) async {
    var r = locationService.getLocation().then((locationData) async {
      final startLat = locationData.latitude;
      final startLong = locationData.longitude;
      String? rideId;
      var riderName = await retrieveUsername();
      if (newRide != false) {
        var time = DateTime.now();
        startTime = (time.millisecondsSinceEpoch / 1000).floor();
        rideId = await FirebaseFirestore.instance.collection('rides').add({
          'bike': bikeId,
          'startLat': startLat,
          'startLong': startLong,
          'rider': riderName,
          'startTime': time,
          'ended': false,
          'rating': 1.0
        }).then((docRef) {
          return docRef.id;
        });
        await FirebaseFirestore.instance
            .collection('bikes')
            .doc(bikeId)
            .update({'checkedOut': true});
      } else {
        var q = await FirebaseFirestore.instance
            .collection('rides')
            .where('rider', isEqualTo: riderName)
            .get();
        for (var i = 0; i < q.docs.length; i++) {
          if (q.docs[i]['ended'] == false) {
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

    final bikeId = ModalRoute.of(context)!.settings.arguments.toString();

    final riderName = username;
    var comboNum;
    var imageURL;

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FutureBuilder<int>(
              future: retrieveCombo(bikeId),
              builder: (context, snapshot) {
                int? returnData;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    returnData = snapshot.data;
                    comboNum = returnData;
                  }
                  ;
                  return Container(
                      child: Column(
                    children: [
                      rideScreenText(bikeName),
                      Container(
                          decoration: BoxDecoration(),
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    rideScreenTextSmall('Combination: '),
                                    rideScreenTextSmall('${comboNum}')
                                  ],
                                )),
                          )),
                      SizedBox(height: imageHeadSpace),
                    ],
                  ));
                }
                ;
                return Center();
              })
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FutureBuilder<String>(
              future: retrieveImageUrl(bikeId),
              builder: (context, snapshot) {
                String? returnData;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    returnData = snapshot.data;
                    imageURL = returnData;
                  }
                  ;
                  return Expanded(
                      child: FractionallySizedBox(
                          widthFactor: imageSizeFactor(context),
                          child: Column(children: [
                            Container(
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FutureBuilder<String>(
                                          future:
                                              startRide(bikeId, widget.newRide),
                                          builder: (context, snapshot) {
                                            Widget child;
                                            String? returnData;
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              if (snapshot.hasData) {
                                                returnData = snapshot.data;
                                                rideId = returnData;
                                                print(rideId);

                                                var currentTime = (DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch /
                                                        1000)
                                                    .floor();
                                                timeLeft = ((startTime +
                                                            (WARNING_ALERT_TIME)) -
                                                        currentTime)
                                                    .toInt();
                                                _notifier.value = timeLeft;
                                                if (timeLeft > -(TIME_TO_BAN)) {
                                                  eightHourTimer =
                                                      makeEightHourTimer(
                                                          context, currentTime);
                                                }
                                                timeUntilBan = ((startTime +
                                                            (MAX_ALERT_TIME)) -
                                                        currentTime)
                                                    .toInt();
                                                twentyFourHourTimer =
                                                    makeTwentyFourHourTimer(
                                                        context,
                                                        currentTime,
                                                        bikeId);

                                                timeLeftTimer =
                                                    makeCountdownTicker(context,
                                                        _notifier, timeLeft);
                                                timeUntilBanTimer =
                                                    makeCountdownTicker(
                                                        context,
                                                        _banNotifier,
                                                        timeUntilBan);
                                              }
                                              ;
                                              child = Column(
                                                children: [
                                                  Container(
                                                    height: 300,
                                                    width: 300,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(
                                                              s_disabledGray),
                                                          spreadRadius: 2,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 3),
                                                        )
                                                      ],
                                                      border: Border.all(
                                                          width: 5,
                                                          color: Color(
                                                              s_jungleGreen)),
                                                      image:
                                                          new DecorationImage(
                                                        fit: BoxFit.fitHeight,
                                                        image: NetworkImage(
                                                            imageURL),
                                                      ),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color: Color(
                                                                            s_jungleGreen)),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(
                                                                            s_disabledGray),
                                                                        spreadRadius:
                                                                            2,
                                                                        blurRadius:
                                                                            7,
                                                                        offset: Offset(
                                                                            0,
                                                                            3),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    color: Color(
                                                                        s_raisinBlack),
                                                                    child: Padding(
                                                                        padding: EdgeInsets.all(8),
                                                                        child: Column(
                                                                          children: [
                                                                            countdownTextSmall("TIME LEFT"),
                                                                            countdownBuilder(context,
                                                                                buttonSpacing)
                                                                          ],
                                                                        )),
                                                                  )),
                                                            ],
                                                          )
                                                        ]),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          buttonSpacing * 3),
                                                  endRideButton(
                                                      context,
                                                      rideId,
                                                      bikeId,
                                                      "End Ride",
                                                      buttonWidth,
                                                      buttonHeight),
                                                ],
                                              );
                                            } else
                                              child = SizedBox(
                                                  width: 300, height: 400);
                                            ;
                                            return AnimatedSwitcher(
                                              duration: Duration(seconds: 1),
                                              child: child,
                                            );
                                          }),
                                    ])
                              ]),
                            ),
                          ])));
                }
                ;
                return Center();
              })
        ]),
      ],
    ));
  }

  ValueListenableBuilder countdownBuilder(BuildContext context, buttonSpacing) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (BuildContext context, tL, child) {
          // Format function from Frank Treacy's answer to 'Formatting a Duration like HH:mm:ss'
          // on StackOverflow
          // https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss#answer-57897328
          format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
          if (tL >= 0 && tL > (60 * 60 * 2)) {
            return countdownText(format(Duration(seconds: tL)));
          } else if (tL >= 0) {
            return countdownTextYellow(format(Duration(seconds: tL)));
          } else {
            return Column(
              children: [
                countdownTextRed(format(Duration(seconds: 0))),
                rideScreenTextRedSmall("LATE"),
                ValueListenableBuilder(
                    valueListenable: _banNotifier,
                    builder: (BuildContext context, int tL, child) {
                      format(Duration d) =>
                          d.toString().split('.').first.padLeft(8, "0");
                      if (tL <= 0) {
                        return Column(
                          children: [
                            SizedBox(height: buttonSpacing),
                            countdownTextRedSmallest(
                                "BANNED IN " + format(Duration(seconds: 0))),
                          ],
                        );
                      } else if (tL <= (TIME_TO_BAN)) {
                        return Column(
                          children: [
                            SizedBox(height: buttonSpacing),
                            countdownTextRedSmallest(
                                "BANNED IN " + format(Duration(seconds: tL))),
                          ],
                        );
                      } else
                        return Center();
                    })
              ],
            );
          }
        });
  }

  void handleBan(BuildContext context, bikeId) async {
    final q1 = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final userId = q1.docs[0].id;
    final q2 = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lockedOut': true});
    final q3 = await FirebaseFirestore.instance
        .collection('bikes')
        .doc(bikeId)
        .update({'Condition': 'Stolen', 'checkedOut': false});
    await Authentication.signOut(context: context);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('loggedIn', false);
    preferences.setString('username', 'no username');
    print('SIGNED OUT');
    //dispose(); // Removed dispose call
    Navigator.of(context).pop();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SplashScreen()),
    // );
    // Added to remove stack of navigation
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false);
  }

  Timer makeCountdownTicker(BuildContext context, notifier, val) {
    return Timer.periodic(Duration(seconds: 1), (t) {
      val--;
      notifier.value = val;
    });
  }

  Timer makeTwentyFourHourTimer(BuildContext context, currentTime, bikeId) {
    return Timer(
        Duration(
            seconds: ((startTime + (MAX_ALERT_TIME)) - currentTime).toInt()),
        () => {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WillPopScope(
                        child: AlertDialog(
                            title: Text("You're banned!"),
                            content: SingleChildScrollView(
                                child: ListBody(children: <Widget>[
                              Text("You've kept the bike for more than "
                                  "24 hours and are now banned from The Kollective. "
                                  "Begone thief!")
                            ])),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Accept Banishment'),
                                onPressed: () async =>
                                    handleBan(context, bikeId),
                              )
                            ]),
                        onWillPop: () async => false);
                  })
            });
  }

  Timer makeEightHourTimer(BuildContext context, currentTime) {
    return Timer(
        Duration(
            seconds:
                ((startTime + (WARNING_ALERT_TIME)) - currentTime).toInt()),
        () => {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("You're late!"),
                        content: SingleChildScrollView(
                            child: ListBody(children: <Widget>[
                          Text("You've kept the bike for more than "
                              "8 hours and are now late to return it. "
                              "If you keep the bike longer than 24 "
                              "hours, you will be banned from the Kollective.")
                        ])),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Got it'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ]);
                  })
            });
  }

  Widget rideScreenText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedLarge,
      font: s_font_IBMPlexSans,
      weight: FontWeight.w500,
    );
  }

  Widget countdownText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Colors.white70,
      size: s_fontSizeMedLarge,
      font: s_font_NovaMono,
      weight: FontWeight.w500,
    );
  }

  Widget countdownTextSmall(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Colors.white70,
      size: s_fontSizeSmall,
      font: s_font_NovaMono,
      weight: FontWeight.bold,
    );
  }

  Widget countdownTextRed(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeMedLarge,
      font: s_font_NovaMono,
      weight: FontWeight.bold,
    );
  }

  Widget countdownTextRedSmallest(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeSmall,
      font: s_font_NovaMono,
      weight: FontWeight.bold,
    );
  }

  Widget countdownTextOrange(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_cadmiumOrange),
      size: s_fontSizeMedLarge,
      font: s_font_NovaMono,
      weight: FontWeight.bold,
    );
  }

  Widget countdownTextYellow(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_mustard),
      size: s_fontSizeMedLarge,
      font: s_font_NovaMono,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextRed(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeMedLarge,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextOrange(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_cadmiumOrange),
      size: s_fontSizeMedLarge,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextRedSmall(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      color: Color(s_declineRed),
      size: s_fontSizeSmall,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextSmall(String text) {
    return FormattedText(
        text: text,
        align: TextAlign.center,
        size: s_fontSizeSmall,
        font: s_font_IBMPlexSans,
        weight: FontWeight.w500,
        color: Color(s_darkGray));
  }

  Widget rideScreenTextExtraSmall(String text) {
    return FormattedText(
        text: text,
        align: TextAlign.center,
        size: s_fontSizeExtraSmall,
        font: s_font_IBMPlexSans,
        weight: FontWeight.w500,
        color: Color(s_darkGray));
  }

  Widget rideScreenTextSmaller(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
    );
  }

  Widget rideScreenTextSmallerNorm(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      font: s_font_IBMPlexSans,
      weight: FontWeight.w500,
    );
  }

  Widget endRideButton(BuildContext context, rideId, bikeId, String text,
      double buttonWidth, double buttonHeight) {
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
          Navigator.of(context).pushNamedAndRemoveUntil(
              'completeRideScreen', (_) => false,
              arguments: rideId);
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
