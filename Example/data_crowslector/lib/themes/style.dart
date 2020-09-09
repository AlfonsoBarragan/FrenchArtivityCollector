import 'package:flutter/material.dart';

abstract class CustomTheme {
  // Define the default brightness and colors.
  //https://dribbble.com/shots/3470934-Chat-App-Freebies

  //static const Color primaryColor = Color(0xff8B66E5);
  static const Color primaryColor = Color(0xFF3d82a7);

  //static const Color primaryColorDark = Color(0xff16164A);
  static const Color primaryColorDark = Color(0xFF005678);

  //static const Color primaryColorLight = Color(0xffBCB1FF);
  static const Color primaryColorLight = Color(0xFF71b1d9);
  static const Color backgroundColor = Colors.white; //Color(0xffF5F5F6);


  // Secondary colors
  static const Color secondaryColor = Color(0xFF4ccad0);
  static const Color secondaryColorLight = Color(0xFF85fdff);
  static const Color secondaryColorDark = Color(0xFF00999f);

  // Terciary colors
  static const Color terciaryColor = Color(0xFFc985d6);
  static const Color terciaryColorLight = Color(0xFFfdb6ff);
  static const Color terciaryColorDark = Color(0xFF9757a4);


  // Define the default font family
  static const String fontFamily = 'Balsamiq Sans';

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.

  static ThemeData buildBlueTheme() {
    final ThemeData base = ThemeData.light();
    final TextTheme textBase = base.textTheme.apply(fontFamily: fontFamily);

    return base.copyWith(
      // Define the default brightness and colors.
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      primaryColorLight: primaryColorLight,
      accentColor: primaryColorLight,
      scaffoldBackgroundColor: backgroundColor,

      // Define the default font family
      textTheme: textBase.copyWith(
        bodyText2: textBase.bodyText2.copyWith(color: Colors.black54),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(),
        textTheme: ButtonTextTheme.primary,
      ),
      cursorColor: primaryColorLight,
      appBarTheme: AppBarTheme(
        elevation: 2.0,
        color: Colors.white,
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
              color: primaryColor,
              fontFamily: fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
