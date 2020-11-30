import 'package:flutter/foundation.dart';
import 'package:wfhmovement/models/recoil.dart';

class AppModel extends ValueNotifier {
  String snackMessage;

  AppModel() : super(null);

  setSnackMessage(value) async {
    snackMessage = value;
    notifyListeners();
  }
}

var appModelAtom = Atom('app', AppModel());
