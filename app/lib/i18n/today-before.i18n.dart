import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Today & before',
        'sv_se': 'Idag & innan',
      } +
      {
        'en_us': 'I',
        'sv_se': 'jag',
      } +
      {
        'en_us': 'you',
        'sv_se': 'du',
      } +
      {
        'en_us': 'Today %s have taken ',
        'sv_se': 'Idag har %s tagit ',
      } +
      {
        'en_us':
            ' steps so far. On a typical %s, before working from home, %s had normally taken ',
        'sv_se':
            ' steg. På en typisk %s innan började jobba hemifrån hade %s normalt tagit ',
      } +
      {
        'en_us': ' steps at this time of day.',
        'sv_se': ' steg vid den här tiden.',
      } +
      {
        'en_us':
            'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement',
        'sv_se':
            'Se hur min rörelseförändring jämför sig med andra som joobar hemifrån. Testa själv genom att ladda ner appen https://hci-gu.github.io/wfh-movement',
      } +
      {
        'en_us':
            'This is how my movement have changed after working from home.',
        'sv_se':
            'Såhär har min rörelse förändrats sen jag började jobba hemifrån.',
      } +
      {
        'en_us': 'increase',
        'sv_se': 'ökning',
      } +
      {
        'en_us': 'decrease',
        'sv_se': 'minskning',
      } +
      {
        'en_us': 'This is a %s of %s.',
        'sv_se': 'Det är en %s med %s.',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
