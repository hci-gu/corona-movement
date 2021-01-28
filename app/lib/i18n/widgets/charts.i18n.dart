import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Started working from home',
        'sv_se': 'Började jobba hemifrån',
      } +
      {
        'en_us': 'May',
        'sv_se': 'Maj',
      } +
      {
        'en_us': 'Oct',
        'sv_se': 'Okt',
      } +
      {
        'en_us': 'steps',
        'sv_se': 'steg',
      } +
      {
        'en_us': 'Change days',
        'sv_se': 'Byt dagar',
      } +
      {
        'en_us': 'People\'s movement hasn\'t changed.',
        'sv_se': 'Människors rörelse har inte förändrats.',
      } +
      {
        'en_us': 'People are moving %s %s.',
        'sv_se': 'Människor rör sig %s %s.',
      } +
      {
        'en_us': 'My movement hasn\'t changed.',
        'sv_se': 'Min rörelse har inte förändrats.',
      } +
      {
        'en_us': 'I\'m moving %s %s.',
        'sv_se': 'Jag rör mig %s %s.',
      } +
      {
        'en_us': 'You\'re moving %s %s.',
        'sv_se': 'Du rör dig %s %s.',
      } +
      {
        'en_us': 'more',
        'sv_se': 'mer',
      } +
      {
        'en_us': 'less',
        'sv_se': 'mindre',
      } +
      {
        'en_us': 'Before',
        'sv_se': 'Före',
      } +
      {
        'en_us': 'After',
        'sv_se': 'Efter',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
