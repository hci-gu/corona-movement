import 'package:wfhmovement/i18n.dart';

class EnvironmentConfig {
  static const APP_NAME = String.fromEnvironment(
    'WFHMOVEMENT_APP_NAME',
    defaultValue: 'WFH Movement',
  );
  static const APP_SUFFIX = String.fromEnvironment('WFHMOVEMENT_APP_SUFFIX');
}

class AppTexts {
  String appName;
  String introductionQuestion;

  init(String appName) {
    switch (appName) {
      case 'SFH Movement':
        initSFHMovement(appName);
        break;
      case 'WFH Movement':
      default:
        initWFHMovement(appName);
        break;
    }
  }

  initWFHMovement(String name) {
    appName = name;
    introductionQuestion = 'Have you worked from home?'.i18n;
  }

  initSFHMovement(String name) {
    appName = name;
    introductionQuestion = 'Have you studied from home?'.i18n;
  }

  static final AppTexts _appTexts = AppTexts._internal();
  factory AppTexts() {
    return _appTexts;
  }

  AppTexts._internal();
}
