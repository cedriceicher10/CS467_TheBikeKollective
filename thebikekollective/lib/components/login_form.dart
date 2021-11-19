import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> usernameKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();
  String username = '';
  String password = '';

  bool loginSuccessful = false;

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;

    return Form(
        key: formKey,
        child: Column(children: [
          Container(width: 325, child: usernameEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: passwordEntry()),
          SizedBox(height: 10),
          loginButton(buttonWidth, buttonHeight),
        ]));
  }

  Widget usernameEntry() {
    return TextFormField(
        autofocus: true,
        key: usernameKey,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'E.g. BikeLover3000@tires.com',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          username = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter an email.';
          } else if (!loginSuccessful) {
            return 'Incorrect login or password!';
          } else {
            return null;
          }
        });
  }

  Widget passwordEntry() {
    return TextFormField(
        autofocus: true,
        key: passwordKey,
        obscureText: true,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          password = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a password.';
          } else if (!loginSuccessful) {
            return 'Incorrect login or password!';
          } else {
            return null;
          }
        });
  }

  Widget loginButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          loginSuccessful = await loginCheck(
              usernameKey.currentState!.value, passwordKey.currentState!.value);
          setState(() {});
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setBool('loggedIn', true);
            preferences.setString('username', usernameKey.currentState!.value);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(map: true)),
                (Route<dynamic> route) => false);
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Login',
          size: s_fontSizeLarge,
          color: Colors.white,
          font: s_font_AmaticSC,
          weight: FontWeight.bold,
        ));
  }

  Future<bool> loginCheck(String? username, String? password) async {
    bool successfulLogin = false;
    var snapshotUsername = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    snapshotUsername.docs.forEach((result) {
      if (result.data()['password'] == password) {
        if (result.data()['lockedOut'] == true) {
          print('Account is locked!');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: lockedAccountTitleText('Account Has Been Locked'),
                content: lockedAccountDescriptionText(
                    "Your account is currently locked after keeping a bike our for greater than 24 hours. You have been removed from the Kollective."),
                actions: [
                  acceptButton(),
                ],
              );
            },
          );
        } else {
          successfulLogin = true;
        }
      }
    });
    return successfulLogin;
  }

  Widget acceptButton() {
    return ElevatedButton(
      child: FormattedText(
        text: 'Accept',
        size: s_fontSizeSmall,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold,
      ),
      style: ElevatedButton.styleFrom(primary: Color(s_declineRed)),
      onPressed: () {
        // Get rid of alert
        Navigator.of(context, rootNavigator: true).pop('dialog');
        // Go back to splash screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (Route<dynamic> route) => false);
      },
    );
  }

  Widget lockedAccountTitleText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeMedium,
      color: Color(s_declineRed),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget lockedAccountDescriptionText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.black,
      font: s_font_BonaNova,
    );
  }
}
