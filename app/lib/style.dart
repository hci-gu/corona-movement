import 'package:wfhmovement/config.dart';
import 'package:wfhmovement/i18n.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wfhmovement/pages/settings.dart';
import 'package:wfhmovement/widgets/language-select.dart';

class AppColors {
  static Color main = Colors.yellow[600];
  static Color mainPressed = Colors.yellow[700];
  static Color secondaryLight = Colors.blueGrey[400];
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
  static AppBar appBar({
    BuildContext context,
    String title,
    bool settings = false,
    bool language = false,
  }) {
    return AppBar(
      backgroundColor: AppColors.main,
      centerTitle: true,
      title: Text(
        title != null ? title : EnvironmentConfig.APP_NAME,
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
          ),
        if (language)
          LanguageSelect(
            inAppBar: true,
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
        content: Text(
          text,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Close'.i18n),
            onPressed: () {
              Navigator.of(alertContext).pop();
            },
          )
        ],
      ),
    );
  }

  static void showConfirmDialog({
    BuildContext context,
    String title,
    String text,
    String completeButtonText = 'Ok',
    String cancelButtonText = 'Cancel',
    Function onComplete,
    Function onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            if (onCancel != null)
              FlatButton(
                child: Text(cancelButtonText.i18n),
                onPressed: () {
                  onComplete();
                  Navigator.of(context).pop();
                },
              ),
            FlatButton(
              child: Text(completeButtonText.i18n),
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
