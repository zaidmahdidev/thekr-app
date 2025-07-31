import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'myColors.dart';

ThemeData dartTheme = ThemeData(
    primarySwatch: Colors.red,
    scaffoldBackgroundColor: HexColor('0xff9900'),
    appBarTheme: const AppBarTheme(
      //backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ),
      backgroundColor: MyColors.orange,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      //Icon search color
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: MyColors.orange,
      unselectedItemColor: Colors.white70,
      elevation: 40.0,
      backgroundColor: MyColors.orange,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    fontFamily: 'Jannah');

ThemeData ligthTheme = ThemeData(
    primarySwatch: MyColors.kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      //backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: MyColors.kPrimaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      backgroundColor: MyColors.orange,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      //Icon search color
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: MyColors.white,
      unselectedItemColor: Colors.black,
      elevation: 40.0,
      backgroundColor: MyColors.kPrimaryColor,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14.0,
        overflow: TextOverflow.ellipsis,
        color: Colors.black,
      ),
    ),
    fontFamily: 'Jannah');
