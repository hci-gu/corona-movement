import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Country',
        'sv_se': 'Land',
      } +
      {
        'en_us': 'Gender',
        'sv_se': 'Kön',
      } +
      {
        'en_us': 'Age range',
        'sv_se': 'Åldersspann',
      } +
      {
        'en_us': 'Education',
        'sv_se': 'Utbildning',
      } +
      {
        'en_us': 'Occupation',
        'sv_se': 'Sysselsättning',
      } +
      {
        'en_us': 'Group code',
        'sv_se': 'Gruppkod',
      } +
      {
        'en_us': 'Please choose one',
        'sv_se': 'Vänligen välj ett val',
      } +
      {
        'en_us': 'Your occupation (optional)',
        'sv_se': 'Din sysselsättning (valfritt)',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
