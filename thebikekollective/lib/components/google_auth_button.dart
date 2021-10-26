import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/waiver_screen.dart';
import '../utils/authentication.dart';
import 'styles.dart';
import 'formatted_text.dart';

class GoogleAuthButton extends StatefulWidget {
  final String text;
  final double buttonWidth;
  final double buttonHeight;

  const GoogleAuthButton(
      {Key? key,
      required this.text,
      required this.buttonWidth,
      required this.buttonHeight})
      : super(key: key);

  @override
  _GoogleAuthButtonState createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? ElevatedButton(
            onPressed: () {},
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            style: ElevatedButton.styleFrom(
                primary: Color(s_jungleGreen),
                fixedSize: Size(widget.buttonWidth, widget.buttonHeight)))
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isSigningIn = true;
              });
              User? user =
                  await Authentication.signInWithGoogle(context: context);
              setState(() {
                _isSigningIn = false;
              });

              if (user != null) {
                bool emailTaken = await uniqueCheck(user.email);
                if (!emailTaken) {
                  print('SUCCESSFULLY SIGNED IN VIA GOOGLE SIGN-ON!');
                  String? email = user.email;
                  String answer = await user.getIdToken();
                  FirebaseFirestore.instance.collection('users').add({
                    'username': email,
                    'password': answer,
                    'verified': true,
                  });
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool('loggedIn', true);
                  preferences.setString('username', email!);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => WaiverScreen(),
                    ),
                  );
                } else {
                  final snackBar = SnackBar(
                      backgroundColor: Color(s_declineRed),
                      content: FormattedText(
                        text: 'Email is already registered!',
                        size: s_fontSizeSmall,
                        color: Colors.white,
                        font: s_font_BonaNova,
                        weight: FontWeight.bold,
                        align: TextAlign.center,
                      ));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  print(
                      'EMAIL ALREADY REGISTERED! NOT SIGNED IN VIA GOOGLE SIGN-ON!');
                }
              } else {
                print('NOT SIGNED IN VIA GOOGLE SIGN-ON!');
              }
            },
            child: googleAuthText(widget.text),
            style: ElevatedButton.styleFrom(
                primary: Color(s_jungleGreen),
                fixedSize: Size(widget.buttonWidth, widget.buttonHeight)));
  }

  Future<bool> uniqueCheck(String? value) async {
    bool alreadyTaken = false;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: value)
        .get();
    snapshot.docs.forEach((result) {
      alreadyTaken = true;
    });
    return alreadyTaken;
  }

  Widget googleAuthText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}
