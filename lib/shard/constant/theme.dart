import 'package:flutter/material.dart';

class MyTheme {
  static const primaryColor = Color(0xff0e645c);
    static const secondaryColor = Color(0xffff9900);
  static const secondryColor = Color(0xFFffffff);

  static const textStyle10 = TextStyle(
    fontSize: 10,
  );

  static const textStyle12 = TextStyle(
    fontSize: 12,
  );

  static const textStyle14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const textStyle15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const textStyle22 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const textStyle24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const textStyle36 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );


}

 const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE2ECEB),
  100: Color(0xFFB7D0CE),
  200: Color(0xFF87B1AD),
  300: Color(0xFF56928C),
  400: Color(0xFF327A74),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF0C5B53),
  700: Color(0xFF0A5149),
  800: Color(0xFF084740),
  900: Color(0xFF04352F),
});
const int _primaryPrimaryValue = 0xFF0E635B;

 const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF6DFFE8),
  200: Color(_primaryAccentValue),
  400: Color(0xFF07FFD8),
  700: Color(0xFF00ECC7),
});
const int _primaryAccentValue = 0xFF3AFFE0;

///////////