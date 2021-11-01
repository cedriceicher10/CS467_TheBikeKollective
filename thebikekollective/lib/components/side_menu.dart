import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/authentication.dart';
import '../screens/splash_screen.dart';
import 'styles.dart';
import 'formatted_text.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(s_jungleGreen),
                ),
                child: headerText('Settings'),
              )),
          ListTile(
            title: menuItemsText('Change Account Info'),
            onTap: () {},
          ),
          ListTile(
            title: menuItemsText('Sign Out'),
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
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget headerText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeExtraLarge,
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
}
