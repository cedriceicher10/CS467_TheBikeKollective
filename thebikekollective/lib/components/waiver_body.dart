import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_verification_body.dart';
import '../screens/splash_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

const WAIVER_TEXT_PATH = 'assets/text/waiver.txt';

class WaiverBody extends StatefulWidget {
  const WaiverBody({Key? key}) : super(key: key);

  @override
  _WaiverBodyState createState() => _WaiverBodyState();
}

class _WaiverBodyState extends State<WaiverBody> {
  bool isLoading = true;
  String waiverTextFromFile = "null";

  void loadWaiverText() async {
    waiverTextFromFile = await rootBundle.loadString(WAIVER_TEXT_PATH);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeadSpace = 20;
    final double textHorizPadding = 15;
    final double buttonHeight = 60;
    final double buttonWidth = 175;
    final double buttonSpacing = 10;

    loadWaiverText();
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: Color(s_jungleGreen),
      ));
    } else {
      return SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: imageHeadSpace),
          importantText('IMPORTANT'),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: textHorizPadding),
              child: waiverText(waiverTextFromFile)),
          SizedBox(height: buttonSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              acceptButton(context, 'Accept', buttonWidth, buttonHeight),
              SizedBox(width: 20),
              declineButton(context, 'Decline', buttonWidth, buttonHeight),
            ],
          ),
          SizedBox(height: buttonSpacing * 10),
          emailVerificationButton(
              context, 'Email Verification', buttonWidth, buttonHeight / 2)
        ],
      ));
    }
  }

  Widget acceptButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => MainUIScreen()),
          // );
        },
        child: acceptButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget declineButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
              (Route<dynamic> route) => false);
        },
        child: declineButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_declineRed),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget emailVerificationButton(BuildContext context, String text,
      double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String? username = preferences.getString('username');
          var snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
          snapshot.docs.forEach((result) {
            if (result.data()['verified'] == true) {
              print('EMAIL ALREADY VERIFIED');
              final snackBar = SnackBar(
                  backgroundColor: Color(s_periwinkleBlue),
                  content: FormattedText(
                    text: 'Email is already verified!',
                    size: s_fontSizeSmall,
                    color: Colors.white,
                    font: s_font_BonaNova,
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                  ));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              print('EMAIL IS NOT VERIFIED');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmailVerificationBody()));
            }
          });
        },
        child: emailVerificationButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget importantText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeLarge,
      color: Color(s_declineRed),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget waiverText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      color: Colors.black,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget acceptButtonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget declineButtonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget emailVerificationButtonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }
}
