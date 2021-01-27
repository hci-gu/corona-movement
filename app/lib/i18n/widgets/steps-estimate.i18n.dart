import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'How much do you think your movement have changed?',
        'sv_se': 'Hur mycket tror du att din rörelse har förändrats?',
      } +
      {
        'en_us':
            'Use the slider below to give an estimate of how much you think your average daily steps have changed.',
        'sv_se':
            'Använd skjutreglaget nedan för att ge ett estimat på hur du tror att dina dagligla steg har förändrat.',
      } +
      {
        'en_us': 'Set estimate',
        'sv_se': 'Sätt estimat',
      } +
      {
        'en_us': 'Redo estimate',
        'sv_se': 'Gör om estimat',
      } +
      {
        'en_us': 'No change',
        'sv_se': 'Ingen förändring',
      } +
      {
        'en_us': 'I\'m moving %s more.',
        'sv_se': 'Jag rör mig %s mer.',
      } +
      {
        'en_us': 'I\'m moving %s less.',
        'sv_se': 'Jag rör mig %s mindre.',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
