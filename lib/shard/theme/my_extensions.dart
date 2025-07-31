import 'package:flutter/material.dart';
//================================= double Helper===============================
extension SizeHelper on BuildContext {
  double getHight(int value) => (MediaQuery.of(this).size.height / 100) * value;
  double getWidth(int value) => (MediaQuery.of(this).size.width / 100) * value;
  double getScreenWidth() => MediaQuery.of(this).size.width;
  double getScreenHeight() => MediaQuery.of(this).size.height;
}


