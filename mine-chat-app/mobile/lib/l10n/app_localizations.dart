import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('es', '419'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('tl'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MINE Chat'**
  String get appTitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Recreate me, forever'**
  String get slogan;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get enterEmailToReset;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get enterValidEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If this email exists, a password reset link has been sent.'**
  String get resetLinkSent;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get userNotFound;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmail;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @noUserAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'No User Authenticated'**
  String get noUserAuthenticated;

  /// No description provided for @createAvatar.
  ///
  /// In en, this message translates to:
  /// **'Customize your avatar'**
  String get createAvatar;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio:'**
  String get audio;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo:'**
  String get photo;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @record45.
  ///
  /// In en, this message translates to:
  /// **'Record 45s'**
  String get record45;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video:'**
  String get video;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideo;

  /// No description provided for @recordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record a Video'**
  String get recordVideo;

  /// No description provided for @uploadAudio.
  ///
  /// In en, this message translates to:
  /// **'Upload Audio'**
  String get uploadAudio;

  /// No description provided for @agregate.
  ///
  /// In en, this message translates to:
  /// **'Agregate'**
  String get agregate;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @takeYourTime.
  ///
  /// In en, this message translates to:
  /// **'Take your time to create your avatar!'**
  String get takeYourTime;

  /// No description provided for @carefullySelect.
  ///
  /// In en, this message translates to:
  /// **'Carefully select the photo, audio, or video that will represent your avatar. Remember that creating the avatar has a cost and, for security reasons, you will not be able to modify it after it is created. Choose the files that best reflect your tastes and preferences.'**
  String get carefullySelect;

  /// No description provided for @successUpload.
  ///
  /// In en, this message translates to:
  /// **'Success Upload!'**
  String get successUpload;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: '**
  String get errorSaving;

  /// No description provided for @createYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'Create your avatar'**
  String get createYourAvatar;

  /// No description provided for @avatarAlreadyExist.
  ///
  /// In en, this message translates to:
  /// **'You already have an avatar of this type!'**
  String get avatarAlreadyExist;

  /// No description provided for @goToChat.
  ///
  /// In en, this message translates to:
  /// **'Go to chat'**
  String get goToChat;

  /// No description provided for @customizeYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'Customize your avatar to the fullest'**
  String get customizeYourAvatar;

  /// No description provided for @takeAMinuteToAnswer.
  ///
  /// In en, this message translates to:
  /// **'Take a few minutes to answer the form carefully and honestly.'**
  String get takeAMinuteToAnswer;

  /// No description provided for @yourAnswersDefine.
  ///
  /// In en, this message translates to:
  /// **'Your answers will define how your avatar interacts with you. You won\'t be able to modify this information afterwards, so select each option carefully according to your preferences. '**
  String get yourAnswersDefine;

  /// No description provided for @selectAvatarType.
  ///
  /// In en, this message translates to:
  /// **'Select the type of avatar you want to create'**
  String get selectAvatarType;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @chooseAvatarInstruction.
  ///
  /// In en, this message translates to:
  /// **'Choose an image and a voice, or video sample for your avatar.'**
  String get chooseAvatarInstruction;

  /// No description provided for @avatar_name_question.
  ///
  /// In en, this message translates to:
  /// **'Choose a name for your avatar.'**
  String get avatar_name_question;

  /// No description provided for @avatar_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Alex, Sam'**
  String get avatar_name_hint;

  /// No description provided for @relationship_question.
  ///
  /// In en, this message translates to:
  /// **'What relationship will this avatar have with you?'**
  String get relationship_question;

  /// No description provided for @relationship_option_partner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get relationship_option_partner;

  /// No description provided for @relationship_option_spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationship_option_spouse;

  /// No description provided for @relationship_option_boyfriend.
  ///
  /// In en, this message translates to:
  /// **'Boyfriend/Girlfriend'**
  String get relationship_option_boyfriend;

  /// No description provided for @relationship_option_crush.
  ///
  /// In en, this message translates to:
  /// **'Crush'**
  String get relationship_option_crush;

  /// No description provided for @relationship_option_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationship_option_other;

  /// No description provided for @relationship_other_hint.
  ///
  /// In en, this message translates to:
  /// **'Write another relationship'**
  String get relationship_other_hint;

  /// No description provided for @response_style_question.
  ///
  /// In en, this message translates to:
  /// **'How should the avatar respond to you?'**
  String get response_style_question;

  /// No description provided for @response_style_option_friendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get response_style_option_friendly;

  /// No description provided for @response_style_option_supportive.
  ///
  /// In en, this message translates to:
  /// **'Supportive'**
  String get response_style_option_supportive;

  /// No description provided for @response_style_option_motivational.
  ///
  /// In en, this message translates to:
  /// **'Motivational'**
  String get response_style_option_motivational;

  /// No description provided for @response_style_option_serious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get response_style_option_serious;

  /// No description provided for @response_style_option_funny.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get response_style_option_funny;

  /// No description provided for @response_style_option_reflective.
  ///
  /// In en, this message translates to:
  /// **'Reflective'**
  String get response_style_option_reflective;

  /// No description provided for @response_style_option_caring.
  ///
  /// In en, this message translates to:
  /// **'Caring'**
  String get response_style_option_caring;

  /// No description provided for @response_style_option_wise.
  ///
  /// In en, this message translates to:
  /// **'Wise'**
  String get response_style_option_wise;

  /// No description provided for @response_style_option_strict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get response_style_option_strict;

  /// No description provided for @topics_question.
  ///
  /// In en, this message translates to:
  /// **'Select the main topics you want to talk about.'**
  String get topics_question;

  /// No description provided for @topics_option_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get topics_option_daily;

  /// No description provided for @topics_option_feelings.
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get topics_option_feelings;

  /// No description provided for @topics_option_advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get topics_option_advice;

  /// No description provided for @topics_option_plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get topics_option_plans;

  /// No description provided for @topics_option_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get topics_option_music;

  /// No description provided for @topics_option_movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get topics_option_movies;

  /// No description provided for @topics_option_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get topics_option_sports;

  /// No description provided for @topics_option_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get topics_option_travel;

  /// No description provided for @topics_option_technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get topics_option_technology;

  /// No description provided for @topics_option_family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get topics_option_family;

  /// No description provided for @topics_option_stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get topics_option_stories;

  /// No description provided for @topics_option_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get topics_option_support;

  /// No description provided for @topics_option_personal_growth.
  ///
  /// In en, this message translates to:
  /// **'Personal growth'**
  String get topics_option_personal_growth;

  /// No description provided for @topics_option_habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get topics_option_habits;

  /// No description provided for @topics_option_dreams.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get topics_option_dreams;

  /// No description provided for @topics_option_challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get topics_option_challenges;

  /// No description provided for @topics_option_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get topics_option_other;

  /// No description provided for @topics_other_hint.
  ///
  /// In en, this message translates to:
  /// **'Write another topic'**
  String get topics_other_hint;

  /// No description provided for @greeting_question.
  ///
  /// In en, this message translates to:
  /// **'How do you want the avatar to greet you?'**
  String get greeting_question;

  /// No description provided for @greeting_option_hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get greeting_option_hi;

  /// No description provided for @greeting_option_hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greeting_option_hello;

  /// No description provided for @greeting_option_hey.
  ///
  /// In en, this message translates to:
  /// **'Hey'**
  String get greeting_option_hey;

  /// No description provided for @greeting_option_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get greeting_option_other;

  /// No description provided for @greeting_other_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your own greeting'**
  String get greeting_other_hint;

  /// No description provided for @communication_frequency_question.
  ///
  /// In en, this message translates to:
  /// **'How often do you want the avatar to talk to you?'**
  String get communication_frequency_question;

  /// No description provided for @communication_frequency_label.
  ///
  /// In en, this message translates to:
  /// **'Days per week'**
  String get communication_frequency_label;

  /// No description provided for @relationship_family_question.
  ///
  /// In en, this message translates to:
  /// **'What family role will this avatar have?'**
  String get relationship_family_question;

  /// No description provided for @relationship_option_mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relationship_option_mother;

  /// No description provided for @relationship_option_father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relationship_option_father;

  /// No description provided for @relationship_option_grandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relationship_option_grandparent;

  /// No description provided for @relationship_option_sibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationship_option_sibling;

  /// No description provided for @relationship_other_family_hint.
  ///
  /// In en, this message translates to:
  /// **'Write another role'**
  String get relationship_other_family_hint;

  /// No description provided for @successSave.
  ///
  /// In en, this message translates to:
  /// **'Profile Saved Successfully!'**
  String get successSave;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @helpContact.
  ///
  /// In en, this message translates to:
  /// **'Help or Contact Us'**
  String get helpContact;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bg', 'de', 'el', 'en', 'es', 'fr', 'he', 'hi', 'hu', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'tl', 'tr', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es': {
  switch (locale.countryCode) {
    case '419': return AppLocalizationsEs419();
   }
  break;
   }
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bg': return AppLocalizationsBg();
    case 'de': return AppLocalizationsDe();
    case 'el': return AppLocalizationsEl();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'he': return AppLocalizationsHe();
    case 'hi': return AppLocalizationsHi();
    case 'hu': return AppLocalizationsHu();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tl': return AppLocalizationsTl();
    case 'tr': return AppLocalizationsTr();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
