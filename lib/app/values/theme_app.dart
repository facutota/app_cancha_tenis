import 'package:app_cancha_tenis/app/values/text_style_app.dart';
import 'package:flutter/material.dart';

class ThemeApp {
  TextStyleApp? textStyleApp;

  ThemeApp() {
    textStyleApp = TextStyleApp();
  }

  TextTheme get textTheme => TextTheme(
      titleLarge: textStyleApp?.title1, titleMedium: textStyleApp?.title2);
}
