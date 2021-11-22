import 'package:flutter/material.dart';
import 'styles.dart';
import 'formatted_text.dart';
import '../screens/home_screen.dart';
import 'create_map_body.dart';



class LateNotice extends StatelessWidget {
  const LateNotice({Key? key}) : super(key: key);

  final double imageHeadSpace = 20;
  final double textHorizPadding = 15;
  final double buttonHeight = 60;
  final double buttonWidth = 175;
  final double buttonSpacing = 10;

  Widget build(BuildContext context) {
/*    return SingleChildScrollView(
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
            SizedBox(height: buttonSpacing * 10)
          ],
        ));*/
    return AlertDialog(
      title: const Text("You're Late!"),
      content: const Text("Your current bike has been checked out for "
          "8 hours. If you do not return it within 24 hours, you will be "
          "banned from the platform. Hurry up!"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(map: true, showWarning: false)),
          ),
          child: const Text('OK')
        )
      ]
    );
  }

/*  Widget okButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          return CreateMapBody();
        },
        child: okButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget okButtonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget lateTitleText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeLarge,
      color: Color(s_declineRed),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget lateText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      color: Colors.black,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }*/

}