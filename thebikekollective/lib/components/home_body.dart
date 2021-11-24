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
            future: UserIsRiding(),

            builder: (context, snapshot) {
              String? isRidingData;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  isRidingData = snapshot.data;
                  userRiding = isRidingData;
                }
                if (userRiding != 'none') {
                  return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/elena-m.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    child: Center(
                        child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Padding(
                                padding: EdgeInsets.all(20),
                                child:  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 3, color: Color(s_jungleGreen)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(s_disabledGray),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Container(
                                        color: Colors.white,
                                        child:
                                        Padding(
                                            padding: EdgeInsets.all(24),
                                            child: Column(
                                              children: [
                                                rideAlertText("You currently have a ride in progress."),
                                                SizedBox(height: buttonSpacing*3),
                                                goToRideButton(context, userRiding, "Go To Ride", buttonWidth, buttonHeight)
                                              ],
                                            )
                                        )
                                    )
                                ),
                              ),



                            ]
                        )
                    )
                  );

                }
                else if (widget.map) {
                  return CreateMapBody();
                } else {
                  return ListViewBody();
                }
              }
              return Container(
                  decoration: BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage("assets/images/elena-m.jpg"),
                  fit: BoxFit.cover,
              ),
              ));
            }

        );
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

  Widget rideAlertText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeLarge,
      font: s_font_IBMPlexSans,
      color: Colors.black,
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
