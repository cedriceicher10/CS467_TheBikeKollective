import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
import 'formatted_text.dart';
import '../screens/home_screen.dart';

class EmailVerificationBody extends StatefulWidget {
  const EmailVerificationBody({Key? key}) : super(key: key);

  @override
  _EmailVerificationBodyState createState() => _EmailVerificationBodyState();
}

class _EmailVerificationBodyState extends State<EmailVerificationBody> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EmailAuth emailAuth = EmailAuth(sessionName: "Email Verification Session");
  double buttonWidth = 275;
  double buttonHeight = 65;
  double headSpace = 100;
  double buttonSpace = 5;
  String otpCode = '0';

  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    if (codeSent) {
      return SingleChildScrollView(
        child: Center(
            child: Column(children: [
          SizedBox(height: headSpace),
          sendOTPButton(
              context, 'Send Verification Code', buttonWidth, buttonHeight),
          SizedBox(height: buttonSpace * 10),
          Form(
              key: formKey,
              child: Column(children: [
                Container(width: 200, child: otpCodeEntry()),
                SizedBox(height: buttonSpace),
                verifyButton(buttonWidth * 0.4, buttonHeight * 0.4),
              ])),
        ])),
      );
    } else {
      return SingleChildScrollView(
        child: Center(
            child: Column(children: [
          SizedBox(height: headSpace),
          sendOTPButton(
              context, 'Send Verification Code', buttonWidth, buttonHeight),
          SizedBox(height: buttonSpace * 10)
        ])),
      );
    }
  }

  Widget sendOTPButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String? email = preferences.getString('username');
          sendOTP(email!);
          codeSent = true;
          setState(() {});
        },
        child: sendOTPButtonText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget otpCodeEntry() {
    return TextFormField(
        autofocus: false,
        style: TextStyle(color: Color(s_periwinkleBlue)),
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
            labelText: 'Verification Code',
            labelStyle: TextStyle(
                color: Color(s_periwinkleBlue), fontWeight: FontWeight.bold),
            errorStyle: TextStyle(
                color: Color(s_declineRed), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color(s_periwinkleBlue), width: 2.0))),
        onSaved: (value) {
          otpCode = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a verification code.';
          } else {
            return null;
          }
        });
  }

  Widget verifyButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            String? email = preferences.getString('username');
            verifyOTP(email!, otpCode);
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_periwinkleBlue),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Verify',
          size: s_fontSizeMedium,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
        ));
  }

  void sendOTP(String email) async {
    var response = await emailAuth.sendOtp(recipientMail: email);
    if (response) {
      print('EMAIL OTP SENT SUCCESSFULLY');
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(s_periwinkleBlue),
          content: FormattedText(
            text: 'Email verification code sent!',
            size: s_fontSizeSmall,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('EMAIL NOT SENT SUCCESSFULLY');
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(s_declineRed),
          content: FormattedText(
            text: 'Error sending email address!',
            size: s_fontSizeSmall,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void verifyOTP(String email, String userOPT) async {
    bool response =
        await emailAuth.validateOtp(recipientMail: email, userOtp: userOPT);
    if (response) {
      print('EMAIL VERIFIED VIA OTP');
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: email)
          .get();
      var docId = snapshot.docs[0].id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'verified': true});
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(s_periwinkleBlue),
          content: FormattedText(
            text: 'Email has been verified!',
            size: s_fontSizeSmall,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print('EMAIL NOT VERIFIED VIA OTP, BAD CODE');
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(s_declineRed),
          content: FormattedText(
            text: 'Incorrect verification code!',
            size: s_fontSizeSmall,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget sendOTPButtonText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: s_fontSizeMedium,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }
}
