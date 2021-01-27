import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Close',
        'sv_se': 'Stäng',
      };

  String get i18n => localize(this, _t);
}
