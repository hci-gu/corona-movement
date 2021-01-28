import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Your steps are still processing...\n Pull to refresh.',
        'sv_se':
            'Din stegdata bearbetas fortfarande...\n Dra för att uppdatera.',
      } +
      {
        'en_us':
            'This is the number of steps others have taken each day (on average). Below you can see how working from home has affected how people move throughout the day.',
        'sv_se':
            'Det här är antalet steg andra har tagit varje dag ( i snitt ). Nedan kan du se hur att arbeta hemifrån har påverkat deras rörelse över dagen.',
      } +
      {
        'en_us':
            'This is the number of steps you\'ve taken every day. Below you can pick different views of this data.',
        'sv_se':
            'Det här är antalet steg du har tagit varje dag. Nedan kan du välja olika vyer av den här datan.',
      } +
      {
        'en_us':
            'Since you don’t have any data before working from home, you can\'t compare yourself to others. Below you can see other people’s data.',
        'sv_se':
            'Eftersom du inte har någon data före du började jobba hemifrån kan du inte jämföra dig med andra. Nedan kan du se andras data.',
      } +
      {
        'en_us': 'Add data source',
        'sv_se': 'Lägg till datakälla',
      } +
      {
        'en_us': 'Explore your steps',
        'sv_se': 'Utforska din stegdata',
      } +
      {
        'en_us': 'Before & after',
        'sv_se': 'Före & efter',
      } +
      {
        'en_us': 'You vs others',
        'sv_se': 'Du mot andra',
      } +
      {
        'en_us': 'Today & before',
        'sv_se': 'Idag & tidigare',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
