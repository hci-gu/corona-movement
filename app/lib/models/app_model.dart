import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api/api.dart' as api;

class AppModel extends ValueNotifier {
  String snackMessage;
  List<DateEvent> events = [];
  Locale locale;

  AppModel() : super(null);

  setSnackMessage(value) async {
    snackMessage = value;
    notifyListeners();
  }

  setEvents(List<DateEvent> newEvents) {
    events = newEvents;
    notifyListeners();
  }

  setlocale(Locale currentLocale) {
    locale = currentLocale;
    notifyListeners();
  }
}

var appModelAtom = Atom('app', AppModel());

Action getEventsAction = (get) async {
  AppModel appModel = get(appModelAtom);

  List<DateEvent> events = await api.getEvents(appModel.locale.languageCode);

  appModel.setEvents(events);
};
