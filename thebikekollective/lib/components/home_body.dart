import 'package:flutter/material.dart';
import 'package:practice1/components/styles.dart';
import 'list_view_body.dart';
import 'create_map_body.dart';
import '../utils/late_bike_check.dart';
import 'late_notice.dart';
import '../utils/user_is_riding_check.dart';
import '../screens/ride_screen.dart';
import '../screens/home_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class HomeBody extends StatefulWidget {
  final bool map;
  final showWarning;

  const HomeBody({Key? key, required this.map, this.showWarning}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  bool? isLate;
  String? lateType;
  String? userRiding;

  final double imageHeadSpace = 20;
  final double textHorizPadding = 15;
  final double buttonHeight = 60;
  final double buttonWidth = 175;
  final double buttonSpacing = 10;

  @override

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: LateBikeCheck(),
        builder: (context, snapshot) {
          String? returnData;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              returnData = snapshot.data;
              lateType = returnData;
            }
            if (lateType == 'banned'){
              return Center(
                child: bannedText("You are banned from the Kollective for keeping a "
                    "bike over 24 hours! Get lost!")
              );
            }
            else if (lateType == 'warning' && widget.showWarning != false){
              return LateNotice();
            }
            else return FutureBuilder<String>(
                future: UserIsRiding(),

                builder: (context, snapshot) {
                  String? isRidingData;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      isRidingData = snapshot.data;
                      userRiding = isRidingData;
                    }
                    if (userRiding != 'none') {
                      return Center(
                        child: goToRideButton(context, userRiding, "Go To Ride", buttonWidth, buttonHeight)
                      );

                    }
                    else if (widget.map) {
                      return CreateMapBody();
                    } else {
                      return ListViewBody();
                    }
                  }
                  return Center();
                }

            );
          }
          return Center();
        });
    }

  Widget goToRideButton(BuildContext context, rideId, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          Navigator.of(context).pushNamedAndRemoveUntil('rideScreenNotNew', (_) => false, arguments: userRiding);
        },
        child: goToRideText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
   }

  Widget goToRideText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget bannedText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeLarge,
      color: Colors.black,
    );
  }
  }
