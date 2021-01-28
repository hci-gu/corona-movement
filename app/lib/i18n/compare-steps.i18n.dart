import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'You vs others',
        'sv_se': 'Du mot andra',
      } +
      {
        'en_us':
            'Your\'s and other\'s difference in movement before and after working from home.',
        'sv_se':
            'Din och andras förändring i rörelse före och efter de började jobba hemifrån.',
      } +
      {
        'en_us':
            'My change in movement compared to others before and after working from home.',
        'sv_se':
            'Min förändring i rörelse jämfört med andra efter jag började jobba hemifrån.',
      } +
      {
        'en_us':
            'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement',
        'sv_se':
            'Se hur min rörelse förändrats jämför med andra sedan jag började jobba hemifrån.\nTesta själv genom att ladda ner appen https://hci-gu.github.io/wfh-movement',
      } +
      {
        'en_us': 'This is how my movement has changed after working from home.',
        'sv_se':
            'Det här är hur min rörelse har förändrats sedan jag började jobba hemifrån.',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
