import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:wfhmovement/i18n.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'api/utils.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyI18n.loadTranslations();
  tz.initializeTimeZones();
  try {
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    globalApiHandler.init(timezone);
  } catch (e) {}

  runApp(App());
}
