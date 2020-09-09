
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget seraphinButton(BuildContext context, Function onPressed, String text, Icon icon,
    { double fontSizeFactor = 1.0,
      Color color,
      double width,
      bool light = false,
      bool enabled = true}) {

      Color primaryColor = Theme.of(context).accentColor;
      return Container(
        child: FloatingActionButton.extended(
          onPressed: enabled ? onPressed : null,
          backgroundColor: !light ? primaryColor : Colors.white,
          icon: icon,
          label: Text(text)
        ),
      );
}