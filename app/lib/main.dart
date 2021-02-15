import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:wfhmovement/app-init.dart';
import 'package:wfhmovement/i18n.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'api/utils.dart';
import 'models/recoil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyI18n.loadTranslations();
  tz.initializeTimeZones();
  try {
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    globalApiHandler.init(timezone);
  } catch (e) {}

  runApp(I18n(
    child: Provider(
      create: (context) => StateStore(),
      child: AppInit(),
    ),
  ));
}
