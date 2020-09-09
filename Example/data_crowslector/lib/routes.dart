import 'package:flutter/cupertino.dart';
import 'package:data_crowslector/pages/home.dart';
import 'package:data_crowslector/pages/login_page.dart';
import 'package:data_crowslector/pages/reset_password.dart';
import 'package:data_crowslector/pages/signup_page.dart';

/// The application's top-level routing table.
///
/// When a named route is pushed with Navigator.pushNamed,
/// the route name is looked up in this map.
final appRoutes = {
  MyHomePage.route: (BuildContext context) => MyHomePage(),
  MyHomePage.routeAuth: (BuildContext context) => MyHomePage(
        isAuth: true,
      ),

  // User
  LoginPage.route: (BuildContext context) => LoginPage(),
  SignUpPage.route: (BuildContext context) => SignUpPage(),
  ResetPasswordPage.route: (BuildContext context) => ResetPasswordPage(),

};
