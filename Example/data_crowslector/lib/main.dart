import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:data_crowslector/routes.dart';

import 'package:data_crowslector/pages/home.dart';
import 'package:data_crowslector/themes/style.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'eMOVI',
        routes: appRoutes,
        theme: CustomTheme.buildBlueTheme(),
        //home: MyHomePage(title: 'Flutter Demo Home Page'),
        home: MyHomePage()
    );
  }
}