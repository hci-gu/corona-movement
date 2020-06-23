import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wfhmovement/pages/settings.dart';

class AppColors {
  static Color main = Colors.yellow[700];
  static Color secondary = Colors.blueGrey[600];

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

  static Widget chartDescription(text) {
    return Container(
      padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 5),
      child: Text(
        text,
        style: TextStyle(),
        textAlign: TextAlign.center,
      ),
    );
  }
}
