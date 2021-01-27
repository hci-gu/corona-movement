import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Upload done.',
        'sv_se': 'Uppladdning klar.',
      } +
      {
        'en_us': 'Uploading your steps: %d uploads left.'
            .one('Uploading your steps: %d upload left.'),
        'sv_se': 'Laddar upp dina steg: %d uppladdningar kvar.'
            .one('Laddar upp dina steg: %d uppladdning kvar.'),
      } +
      {
        'en_us': 'Next',
        'sv_se': 'Fortsätt',
      } +
      {
        'en_us': 'Done',
        'sv_se': 'Färdig',
      } +
      {
        'en_us': 'Upload not finished',
        'sv_se': 'Uppladdningen är inte färdig',
      } +
      {
        'en_us': 'Please wait until the upload has finished to proceed.',
        'sv_se':
            'Vänligen vänta tills uppladdningen är färdig för att fortsätta.',
      } +
      {
        'en_us': 'Form not completed',
        'sv_se': 'Formuläret har inte fyllts i',
      } +
      {
        'en_us': 'Please fill out the fields above to proceed.',
        'sv_se': 'Vänligen fyll i fälten ovan för att fortsätta.',
      } +
      {
        'en_us': 'Back',
        'sv_se': 'Tillbaka',
      } +
      {
        'en_us': '',
        'sv_se': '',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);
}
