import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': "No steps",
        'sv_se': 'Ingen stegdata',
      } +
      {
        'en_us':
            "If you don\'t have any steps saved you can still proceed without uploading to just explore others results.",
        'sv_se':
            'Om du inte har några steg sparade kan du fortfarande fortsätta utan att ladda upp för att bara utforska andras resultat.',
      } +
      {
        'en_us': "Proceed",
        'sv_se': 'Fortsätt',
      };

  String get i18n => localize(this, _t);
}
