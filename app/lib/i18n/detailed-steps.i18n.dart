import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Before & after',
        'sv_se': 'Före & efter',
      } +
      {
        'en_us':
            'Above you can see how working from home has affected how people move throughout the day.',
        'sv_se':
            'Ovan kan du se hur hemarbete har påverkar hur människor rör sig över dagen.',
      } +
      {
        'en_us':
            'Above you can see how your activity has changed over a typical day before and after working from home.',
        'sv_se':
            'Ovan kan du se hur din rörelse har förändrats över en typisk dag före och efter du började jobba hemifrån.',
      } +
      {
        'en_us': 'This is how %s movement has changed after working from home.',
        'sv_se': 'Det här är hur %s rörelse har förändrats efter hemarbete.',
      } +
      {
        'en_us':
            '\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement',
        'sv_se':
            '\nTesta själv genom att ladda ner appen https://hci-gu.github.io/wfh-movement',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
