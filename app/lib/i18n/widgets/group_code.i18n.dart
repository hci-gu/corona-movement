import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Group code',
        'sv_se': 'Gruppkod',
      } +
      {
        'en_us': 'Join',
        'sv_se': 'Gå med',
      } +
      {
        'en_us': 'Joining a group',
        'sv_se': 'Att gå med i en grupp',
      } +
      {
        'en_us':
            'If you have a code you can enter it here to join a group. This allows you to compare with others in the same group.\n\nIf you are interested in trying out this feature with your group, company or organization, feel free to contact us at sebastian.andreasson@ait.gu.se',
        'sv_se':
            'Om du har en gruppkod kan du skriva in den här för att gå med i en grupp. Det låter dig jämföra dig med andra i samma grupp.\n\nOm du är intresserad av att testa den här funktionaliteten med din grupp, bolag eller organisation kan du kontakta oss genom sebastian.andreasson@ait.gu.se',
      } +
      {
        'en_us': 'Code to join a group (optional)',
        'sv_se': 'Kod för att gå med i grupp (valfritt)',
      };

  String get i18n => localize(this, _t);
}
