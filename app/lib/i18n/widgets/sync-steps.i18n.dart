import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us':
            'You have steps up until %s,\n press the button below to sync them.',
        'sv_se':
            'Du har stegdata upp till %s,\n tryck på knappen nedan för att synka.',
      } +
      {
        'en_us': 'Sync steps',
        'sv_se': 'Synka steg',
      } +
      {
        'en_us': 'Login with your Garmin credentials',
        'sv_se': 'Logga in med dina Garmin uppgifter',
      } +
      {
        'en_us': 'Sync Garmin',
        'sv_se': 'Synka Garmin',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
