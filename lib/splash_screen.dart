import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/home_screen.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      durationInSeconds: 6,
      navigator: HomePage(),
      backgroundColor: Colors.cyan,
      loaderColor: Colors.red,
      showLoader: true,
      loadingText: const Text(
        "Loading...",
        style: TextStyle(color: Colors.white),
      ),
      logo: Image.network(
          fit: BoxFit.fitWidth,
          'https://as2.ftcdn.net/v2/jpg/02/29/35/31/1000_F_229353193_BC16gWbME4TWVG9WhBOaP5kXXFRfg4Ci.jpg'),
    );
  }
}
