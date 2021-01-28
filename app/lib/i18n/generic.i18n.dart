import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'I\'m',
        'sv_se': 'Jag',
      } +
      {
        'en_us': 'I\'m',
        'sv_se': 'Jag',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
