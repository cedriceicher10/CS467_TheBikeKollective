import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/waiver_screen.dart';
import '../screens/map.dart';
import 'formatted_text.dart';
import 'styles.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({Key? key}) : super(key: key);

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return oneColumn(context);
      } else {
        return twoColumn(context);
      }
    });
  }

  Widget oneColumn(BuildContext context) {
    final double imageHeadSpace = 60;
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    final double buttonSpacing = 8;

    return Center(
        child: Column(children: [
      SizedBox(height: imageHeadSpace),
      FractionallySizedBox(
          widthFactor: imageSizeFactor(context),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 3, color: Color(s_jungleGreen)),
                  borderRadius: BorderRadius.circular(5)),
              child: Image(
                image: AssetImage('assets/images/bike_clipart.jpg'),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ));
                },
              ))),
      SizedBox(height: buttonSpacing * 2),
      loginButton(context, 'Login', buttonWidth, buttonHeight),
      SizedBox(height: buttonSpacing),
      createAccountButton(context, 'Create Account', buttonWidth, buttonHeight),
      SizedBox(height: buttonSpacing),
      googleAuthButton(
          context, 'Sign in with Google', buttonWidth, buttonHeight),
      SizedBox(height: buttonSpacing),
      mapButton(context, 'Map', buttonWidth, buttonHeight),
      SizedBox(height: buttonSpacing),
      addBikeButton(context, 'Add Bike', buttonWidth, buttonHeight),
      testUserButton(context, 'Test User', buttonWidth / 2, buttonHeight / 2),
      SizedBox(height: buttonSpacing)
    ]));
  }

  Widget twoColumn(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;
    final double buttonSpacing = 6;

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          child: FractionallySizedBox(
              widthFactor: imageSizeFactor(context),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Color(s_jungleGreen)),
                      borderRadius: BorderRadius.circular(5)),
                  child: Image(
                    image: AssetImage('assets/images/bike_clipart.jpg'),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ));
                    },
                  )))),
      SingleChildScrollView(
          child: Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: buttonSpacing),
                        loginButton(
                            context, 'Login', buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        createAccountButton(context, 'Create Account',
                            buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        googleAuthButton(context, 'Sign in with Google',
                            buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        mapButton(context, 'Map', buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        addBikeButton(
                            context, 'Add Bike', buttonWidth, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        testUserButton(context, 'Test User', buttonWidth / 2,
                            buttonHeight / 2),
                      ]))))
    ]);
  }

  Widget loginButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: loginText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget createAccountButton(BuildContext context, String text,
      double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WaiverScreen(google: false)),
          );
        },
        child: createAccountText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget googleAuthButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaiverScreen(google: true)),
          );
        },
        child: createAccountText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget testUserButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: testUserLogin(text),
        style: ElevatedButton.styleFrom(
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget mapButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        },
        child: mapText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget addBikeButton(BuildContext context, String text, double buttonWidth,
      double buttonHeight) {
    File? image;
    final picker = ImagePicker();

    Future getImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      image = File(pickedFile!.path);

      var fileName = DateTime.now().toString() + '.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(image!);
      await uploadTask;
      final url = await storageReference.getDownloadURL();
      return url;
    }

    return ElevatedButton(
        onPressed: () async {
          final url = await getImage();
          Navigator.of(context).pushNamed('addBike', arguments: url);
        },
        child: addBikeText(text),
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  double imageSizeFactor(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return 0.8;
    } else {
      return 0.85;
    }
  }

  Widget loginText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget createAccountText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget testUserLogin(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}

Widget mapText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}

Widget addBikeText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeLarge,
    color: Colors.white,
    font: s_font_AmaticSC,
    weight: FontWeight.bold,
  );
}
