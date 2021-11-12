import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final serviceId = 'service_k5j0ufv'; // per EmailJS/Email Services
  final templateId = 'template_svjbi9l'; // per EmailJS/Email Templates
  final userId = 'user_lbirH0qOMwQ1RghLQ9LrB'; // per EmailJS/Integration

  double buttonWidth = 275;
  double buttonHeight = 65;
  double headSpace = 100;
  double buttonSpace = 5;
  int otpCodeOrig = 0;
  String optCodeUser = '0';

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
                Container(width: 200, child: optCodeUserEntry()),
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

  Widget optCodeUserEntry() {
    return TextFormField(
        autofocus: false,
        keyboardType: TextInputType.number,
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
          optCodeUser = value!;
        },
        validator: (value) {
          final result = num.tryParse(value!);
          if (value.isEmpty) {
            return 'Please enter a verification code.';
          } else if (result == null) {
            return 'Code must be integers.';
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
            verifyOTP(email!, optCodeUser);
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
    var seed = new Random();
    otpCodeOrig = seed.nextInt(899999) + 100000; // Ensure 6 digit code

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'otp_code': otpCodeOrig,
          'to_email': email,
        },
      }),
    );
    print("http response: ${response.statusCode}:${response.body}");
    if (response.statusCode <= 200) {
      print('EMAIL OTP SENT SUCCESSFULLY');
      ScaffoldMessenger.of(context)
          .showSnackBar(emailSentSuccessSnackBar(email));
    } else {
      print('EMAIL NOT SENT SUCCESSFULLY');
      ScaffoldMessenger.of(context).showSnackBar(emailSentFailSnackBar(email));
    }
  }

  void verifyOTP(String email, String userOPT) async {
    if (int.parse(userOPT) == otpCodeOrig) {
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
      ScaffoldMessenger.of(context).showSnackBar(otpVerfieidSnackBar(email));
      await Future.delayed(Duration(seconds: 2)); // Lets the snackbar show
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomeScreen(map: true)));
    } else {
      print('EMAIL NOT VERIFIED VIA OTP, BAD CODE');
      ScaffoldMessenger.of(context).showSnackBar(otpFailedSnackBar());
    }
  }

  SnackBar emailSentSuccessSnackBar(String email) {
    return SnackBar(
        backgroundColor: Color(s_periwinkleBlue),
        content: FormattedText(
          text: 'Email verification code sent successfully to $email!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
  }

  SnackBar emailSentFailSnackBar(String email) {
    return SnackBar(
        backgroundColor: Color(s_declineRed),
        content: FormattedText(
          text: 'Error sending email to $email!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
  }

  SnackBar otpVerfieidSnackBar(String email) {
    return SnackBar(
        backgroundColor: Color(s_periwinkleBlue),
        content: FormattedText(
          text: 'The email $email has been verified!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
  }

  SnackBar otpFailedSnackBar() {
    return SnackBar(
        backgroundColor: Color(s_declineRed),
        content: FormattedText(
          text: 'Incorrect verification code!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
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
