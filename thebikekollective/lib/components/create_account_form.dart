import 'package:flutter/material.dart';
import '../screens/waiver_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class NewAccountFields {
  String? email;
  String? password;
  String toString() {
    return 'Email: $email, Password: $password';
  }
}

class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({Key? key}) : super(key: key);

  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;

    return Form(
        key: formKey,
        child: Column(children: [
          Container(width: 325, child: emailEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: passwordEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: passwordConfirmEntry()),
          SizedBox(height: 10),
          createAccountButton(buttonWidth, buttonHeight),
        ]));
  }

  Widget emailEntry() {
    return TextFormField(
        autofocus: true,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'E.g. bike4.life33@gmail.com',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          NewAccountFields().email = value;
        },
        validator: (value) {
          // TO DO: Query to ensure email is unique

          if ((value!.isEmpty) | !(value.contains('@'))) {
            return 'Please enter a valid email address.';
          } else if (value.contains(' ')) {
            return 'Email may not contain spaces.';
          } else if (value.length > 30) {
            return 'Email may not be greater than 30 characters.';
            // } else if !(uniqueEmail) {
            //   return 'Email is already registered.';
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
          NewAccountFields().password = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a password.';
          } else if (value.length < 8) {
            return 'Password must be at least 8 characters.';
          } else {
            return null;
          }
        });
  }

  Widget passwordConfirmEntry() {
    return TextFormField(
        autofocus: true,
        obscureText: true,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Confirm Password',
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
          NewAccountFields().password = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please confirm your password.';
          } else if (value != passwordKey.currentState!.value) {
            return 'Password and confirmation must match.';
          } else {
            return null;
          }
        });
  }

  Widget createAccountButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();

            // TO DO: Add new account info to database

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaiverScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Create Account',
          size: s_fontSizeLarge,
          color: Colors.white,
          font: s_font_AmaticSC,
          weight: FontWeight.bold,
        ));
  }
}
