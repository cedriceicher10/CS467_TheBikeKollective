import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'utils/preload_image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]);
  await Firebase.initializeApp();
  SharedPreferences preferences = await SharedPreferences.getInstance();

  // Manual sign out (Turn this on to DISABLE persistent login)
  // preferences.setBool('loggedIn', false);
  // preferences.setString('username', 'no username');

  print(preferences.getBool('loggedIn'));
  print(preferences.getString('username'));
  await loadImage(AssetImage('assets/images/elena-m.jpg'));
  runApp(App());
}
