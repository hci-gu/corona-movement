import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Select data source',
        'sv_se': 'Välj datakälla',
      } +
      {
        'en_us':
            'For us to tell you how your moment patterns have changed we need access to your step data.',
        'sv_se':
            'För att vi ska kunna visa hur dina rörelsemönster förändrats behöver vi tillgång till din stegdata.',
      } +
      {
        'en_us': 'Please select where you keep your step data.',
        'sv_se': 'Vänligen välj var du lagrar din stegdata.',
      } +
      {
        'en_us': 'Selecting a data source',
        'sv_se': 'Att välja en datakälla',
      } +
      {
        'en_us':
            'The app will fetch data from a source where you may have step data. Some people with android use google fitness (you might not even know about it). People with iOS devices typically have apple health that automatically record movement data. Some people use Garmin. If you do not have any historical data, you may use the app anyway to compare yourself with others.',
        'sv_se':
            'Appen kommer hämta data från en källa där du kan ha stegdata. Personer med Android använder google fitness, personer med iOS har ofta Apple Health som automatiskt sparar rörelsedata. Om du inte har någon historisk data kan du ändå använda appen för att jämföra dig med andra.',
      } +
      {
        'en_us': "I don't have any steps saved.",
        'sv_se': 'Jag har ingen stegdata sparad.',
      };

  String get i18n => localize(this, _t);
}
