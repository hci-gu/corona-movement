import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us': 'Settings',
        'sv_se': 'Inställningar',
      } +
      {
        'en_us': 'You started working from home on %s.',
        'sv_se': 'Du började jobba hemifrån %s.',
      } +
      {
        'en_us': 'Change date',
        'sv_se': 'Byt datum',
      } +
      {
        'en_us': 'Join group',
        'sv_se': 'Gå med grupp',
      } +
      {
        'en_us': 'Delete data',
        'sv_se': 'Ta bort data',
      } +
      {
        'en_us':
            'By picking a date where you started working from home, you will be able to explore whether your movement patterns have changed since you started working from home. The app visualizes your movement in the form of steps data from your phone, through Apple Health, Google fitness or Garmin.',
        'sv_se':
            'Genom att välja ett datum du började jobba hemifrån kan du utforska om dina rörelsemönster förändrats sedan hemarbete. Appen visualiserar din rörelse i form av stegdata från din telefon, genom Apple Health, Google fitness eller Garmin.',
      } +
      {
        'en_us':
            'The Work From Home app was developed for research purposes by the Division of Human Computer Interaction at the Department of Applied Information Technology, University of Gothenburg, Sweden.',
        'sv_se':
            'Work From Home appen är utvecklad för forskningssyfte av avdelningen för människa-dator interaktion på instutitionen för tillämpad informationsteknologi, Göteborgs Universitet.',
      } +
      {
        'en_us': 'Read more about the project here:',
        'sv_se': 'Läs mer om projektet här:',
      } +
      {
        'en_us': 'Confirm',
        'sv_se': 'Bekräfta',
      } +
      {
        'en_us':
            'Are you sure you want to delete your data?\n\nThis will remove all data from the app, and from our servers. You will no longer praticipate in the research project.\n\nIf you want to use the app again, you are welcome to do so.',
        'sv_se':
            'Är du säker på att du vill ta bort din data?\n\nDet här kommer ta bort all data från appen, och från våra servrar. Du kommer inte längre delta i forskningsprojektet.\n\nOm du vill använda appen igen är du välkommen att göra det.',
      } +
      {
        'en_us': 'Cancel',
        'sv_se': 'Avbryt',
      } +
      {
        'en_us': 'Yes',
        'sv_se': 'Ja',
      } +
      {
        'en_us': 'User id copied to clipboard',
        'sv_se': 'Användarid kopierat till urklipp',
      } +
      {
        'en_us': 'User id: %s',
        'sv_se': 'Användarid: %s',
      } +
      {
        'en_us': '',
        'sv_se': '',
      } +
      {
        'en_us': '',
        'sv_se': '',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
