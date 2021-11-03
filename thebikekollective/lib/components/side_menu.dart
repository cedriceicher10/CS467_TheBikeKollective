import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/authentication.dart';
import '../screens/splash_screen.dart';
import '../screens/email_verification_screen.dart';
import 'styles.dart';
import 'formatted_text.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String username = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: retrieveUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                      height: 175,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          color: Color(s_jungleGreen),
                        ),
                        child: Column(children: [
                          settingsText('Settings'),
                          usernameText('$username')
                        ]),
                      )),
                  ListTile(
                    title: menuItemsText('Ride History'),
                    onTap: () {},
                  ),
                  ListTile(
                      title: menuItemsText('Email Verification'),
                      onTap: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        String? username = preferences.getString('username');
                        if (username == 'no username') {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(testUserSnackBar());
                        } else {
                          var snapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .where('username', isEqualTo: username)
                              .get();
                          snapshot.docs.forEach((result) {
                            if (result.data()['verified'] == true) {
                              print('EMAIL ALREADY VERIFIED');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(alreadyVerifiedSnackBar());
                            } else {
                              print('EMAIL IS NOT VERIFIED');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EmailVerificationScreen()));
                            }
                          });
                        }
                      }),
                  ListTile(
                    title: menuItemsText('Change Account Info'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: signOutText('Sign Out'),
                    onTap: () async {
                      await Authentication.signOut(context: context);
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setBool('loggedIn', false);
                      preferences.setString('username', 'no username');
                      print('SIGNED OUT');
                      print(preferences.getBool('loggedIn'));
                      print(preferences.getString('username'));
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(s_jungleGreen)),
            ));
          }
        });
  }

  Future<void> retrieveUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString('username')!;
  }

  SnackBar alreadyVerifiedSnackBar() {
    return SnackBar(
        backgroundColor: Color(s_jungleGreen),
        content: FormattedText(
          text: 'Email is already verified!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
  }

  SnackBar testUserSnackBar() {
    return SnackBar(
        backgroundColor: Color(s_declineRed),
        content: FormattedText(
          text: 'You are using the test user bypass!',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
          align: TextAlign.center,
        ));
  }

  Widget settingsText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
      align: TextAlign.center,
    );
  }

  Widget usernameText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeMedium,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
      align: TextAlign.center,
    );
  }

  Widget menuItemsText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Color(s_jungleGreen),
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }

  Widget signOutText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeLarge,
      color: Color(s_declineRed),
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}
