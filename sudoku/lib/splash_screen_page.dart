import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'constants.dart';
import 'main.dart';
import 'styles.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: ANIMATION_DURATION_SPLASH.inSeconds,
      navigateAfterSeconds: const HomePage(),
      title: Text(
        '\n$APP_TITLE',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
            color: Styles.foregroundColor),
      ),
      image: Image.asset('assets/icon/icon_foreground.png'),
      photoSize: 50,
      backgroundColor: Styles.primaryBackgroundColor,
      useLoader: true,
      loaderColor: Styles.primaryColor,
      loadingText: const Text(
        DEVELOPER_NAME,
        style: TextStyle(color: Colors.grey),
      ),
      loadingTextPadding: const EdgeInsets.only(top: 10.0),
      styleTextUnderTheLoader: const TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }
}
