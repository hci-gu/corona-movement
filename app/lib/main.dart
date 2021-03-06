import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:wfhmovement/app-init.dart';
import 'package:wfhmovement/config.dart';
import 'package:wfhmovement/i18n.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'api/utils.dart';
import 'models/recoil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyI18n.loadTranslations();
  tz.initializeTimeZones();
  AppTexts().init(EnvironmentConfig.APP_NAME);
  try {
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    globalApiHandler.init(timezone);
  } catch (e) {}

  runApp(I18n(
    child: Provider(
      create: (context) => StateStore(),
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('sv'),
        ],
        title: 'Work from home movement',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.amber,
        ),
        debugShowCheckedModeBanner: false,
        home: AppInit(),
      ),
    ),
  ));
}
