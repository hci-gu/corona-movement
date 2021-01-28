import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en_us') +
      {
        'en_us':
            'This app is part of an exploratory research project at the University of Gothenburg investigating the impact of the pandemic on our physical movement. For this purpose, we will collect and store the following data:',
        'sv_se':
            'Den här appen är en del av ett forskningsprojekt vid Göteborgs Universitet som undersöker pandemins inverkan på vår fysiska rörelse. För detta ändamål samlar vi in och lagrar följande data:',
      } +
      {
        'en_us': 'Step data',
        'sv_se': 'Stegdata',
      } +
      {
        'en_us': 'Demographic data',
        'sv_se': 'Demografisk data',
      } +
      {
        'en_us': 'App interactions',
        'sv_se': 'Appinteraktioner',
      } +
      {
        'en_us':
            'Any data stored will be removed upon opting out of the study by deleting your account.',
        'sv_se':
            'All lagrad data tas bort om du väljer att gå ur studien genom att radera ditt konto.',
      } +
      {
        'en_us': 'Give access',
        'sv_se': 'Ge åtkomst',
      } +
      {
        'en_us':
            'To proceeed you must grant access for us to retrieve data from %s.',
        'sv_se':
            'För att fortsätta måste du ge oss åtkomst att hämta data från %s.',
      } +
      {
        'en_us':
            'Collected from %s.\n\n- Historical data of number of steps taken with timestamps\n- Date selected for working from home. ( for comparisons before/after )',
        'sv_se':
            'Hämtad från %s. \n\n- Historiska uppgifter om antalet steg som tagits med tidsstämplar\n- Valt datum då du började jobba hemifrån. ( för jämförelser före/efter )',
      } +
      {
        'en_us':
            'The following points are collected by filling out the form in the next step:\n\n- Gender\n- Age range\n- Education\n- Profession',
        'sv_se':
            'Följande punkter samlas in genom att fylla i formuläret i nästa steg:\n\n- Kön\n- Åldersspann\n- Utbildning\n -Yrke',
      } +
      {
        'en_us':
            'Automatically sent via app usage.\n\n- App open/close\n- Navigating through views\n- Sync steps button pressed\n- Change work from home date\n- Day selection in Before & after\n- Using share feature',
        'sv_se':
            'Sänds automatiskt via appanvändning.\n\n- När appen öppnas/stängs\n- Navigering genom vyer\n- Synkning av stegdata\n- Byte att jobba hemifrån-datum\n- Val av dagar i "Före & efter" vyn\n- Användning av delningsfunktionen',
      } +
      {
        'en_us': 'Apple health is not available on an Android device.',
        'sv_se': 'Apple health är inte tillgängligt på en Android-enhet.',
      } +
      {
        'en_us':
            'You will now see a dialog for allowing access to Apple health\n\nTo give us access to your steps make sure check the box for steps before pressing allow.',
        'sv_se':
            'Du kommer nu att se en dialogruta för att tillåta åtkomst till Apple health.\n\nFör att ge oss tillgång till dina steg, se till att kryssa i rutan för steg innan du trycker på tillåt.',
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
