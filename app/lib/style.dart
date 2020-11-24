import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wfhmovement/pages/settings.dart';

class AppColors {
  static Color main = Colors.yellow[600];
  static Color mainPressed = Colors.yellow[700];
  static Color secondary = Colors.blueGrey[700];
  static Color secondaryPressed = Colors.blueGrey[800];
  static Color danger = Colors.red[700];
  static Color dangerPressed = Colors.red[800];

  static Color primaryText = Colors.blueGrey[900];
  static Color secondaryText = Colors.grey[600];

  static LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Colors.blueGrey[900],
      Colors.blueGrey[800],
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}

class AppWidgets {
  static AppBar appBar(BuildContext context, [String title, bool settings]) {
    return AppBar(
      backgroundColor: AppColors.main,
      centerTitle: true,
      title: Text(
        title != null ? title : 'WFH Movement',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
      actions: [
        if (settings)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Settings(),
                settings: RouteSettings(name: 'Settings'),
              ));
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.settings,
                color: AppColors.primaryText,
              ),
            ),
          )
      ],
    );
  }

  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: flightDirection == HeroFlightDirection.pop ? 0.5 : 1,
        end: 1,
      )
          .chain(Tween<double>(
            begin: 1,
            end: 1,
          ))
          .animate(animation),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: fromHeroContext.widget,
        ),
      ),
    );
  }

  static Widget chartDescription(text, [double fontSize]) {
    return Container(
      padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize != null ? fontSize : 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static void showAlert(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext alertContext) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          FlatButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(alertContext).pop();
            },
          )
        ],
      ),
    );
  }

  static void showConfirmDialog(
      BuildContext context, String title, String text, Function onComplete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                onComplete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
