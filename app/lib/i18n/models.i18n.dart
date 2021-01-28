import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Monday',
        'sv_se': 'Måndag',
      } +
      {
        'en_us': 'Tuesday',
        'sv_se': 'Tisdag',
      } +
      {
        'en_us': 'Wednesday',
        'sv_se': 'Onsdag',
      } +
      {
        'en_us': 'Thursday',
        'sv_se': 'Torsdag',
      } +
      {
        'en_us': 'Friday',
        'sv_se': 'Fredag',
      } +
      {
        'en_us': 'Saturday',
        'sv_se': 'Lördag',
      } +
      {
        'en_us': 'Sunday',
        'sv_se': 'Söndag',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
