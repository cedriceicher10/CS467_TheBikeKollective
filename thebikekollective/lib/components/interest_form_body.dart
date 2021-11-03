import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/add_bike_screen.dart';
import '../screens/splash_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

const INTERESTFORM_TEXT_PATH = 'assets/text/interestform.txt';

class InterestFormBody extends StatefulWidget {
  const InterestFormBody({Key? key}) : super(key: key);

  @override
  _InterestFormBodyState createState() => _InterestFormBodyState();
}

class _InterestFormBodyState extends State<InterestFormBody> {
  bool isLoading = true;
  String interestFormTextFromFile = "null";

  void loadInterestFormText() async {
    interestFormTextFromFile = await rootBundle.loadString(INTERESTFORM_TEXT_PATH);
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

    loadInterestFormText();
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
                child: waiverText(interestFormTextFromFile)),
            SizedBox(height: buttonSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                acceptButton(context, 'Accept', buttonWidth, buttonHeight),
                SizedBox(width: 20),
                declineButton(context, 'Decline', buttonWidth, buttonHeight),
              ],
            ),
            SizedBox(height: buttonSpacing * 10)
          ],
        ));
      }
  }

  Widget acceptButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('addBike', arguments: url);
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
}

