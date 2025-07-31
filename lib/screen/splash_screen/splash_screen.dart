import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import '../home_screen/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedSplashScreen(
      splash:  const Image(
        image: AssetImage('assets/images/thekr.png') ,
        fit: BoxFit.fill,
      ),
      splashIconSize: MediaQuery.of(context).size.height /3,
      nextScreen: const HomeScreen(),
    ));
  }
}

