import 'package:flutter/material.dart';

class TextStyleApp {
  TextStyleApp();

  TextStyle get textBase => const TextStyle(
        color: Colors.blueGrey,
        fontFamily: "Geologica",
      );

  TextStyle get title1 =>
      textBase.copyWith(fontWeight: FontWeight.w700, fontSize: 20);

  TextStyle get title2 => title1.copyWith(fontSize: 15);

  TextStyle get body1 =>
      textBase.copyWith(fontWeight: FontWeight.w600, fontSize: 15);
}
