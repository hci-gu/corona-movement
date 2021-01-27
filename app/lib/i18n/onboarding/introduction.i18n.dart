import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Have your movement patterns changed?',
        'sv_se': 'Har dina rörelsemönster förändrats?',
      } +
      {
        'en_us': 'Begin by picking the day you started working from home.',
        'sv_se': 'Börja med att välja dagen du började jobba hemifrån.',
      } +
      {
        'en_us': 'Select date',
        'sv_se': 'Välj datum',
      };

  String get i18n => localize(this, _t);
}
