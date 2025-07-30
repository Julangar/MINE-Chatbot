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

  /// No description provided for @avatar_form_title.
  ///
  /// In en, this message translates to:
  /// **'Customize your avatar'**
  String get avatar_form_title;

  /// No description provided for @avatar_form_name_label.
  ///
  /// In en, this message translates to:
  /// **'Avatar name'**
  String get avatar_form_name_label;

  /// No description provided for @avatar_form_user_reference_label.
  ///
  /// In en, this message translates to:
  /// **'User name or reference'**
  String get avatar_form_user_reference_label;

  /// No description provided for @avatar_form_relationship_label.
  ///
  /// In en, this message translates to:
  /// **'Relationship or role (e.g. friend, coach)'**
  String get avatar_form_relationship_label;

  /// No description provided for @avatar_form_speaking_style_label.
  ///
  /// In en, this message translates to:
  /// **'Speaking style'**
  String get avatar_form_speaking_style_label;

  /// No description provided for @avatar_form_interests_label.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get avatar_form_interests_label;

  /// No description provided for @avatar_form_common_phrases_label.
  ///
  /// In en, this message translates to:
  /// **'Common phrases'**
  String get avatar_form_common_phrases_label;

  /// No description provided for @avatar_form_traits_label.
  ///
  /// In en, this message translates to:
  /// **'Personality traits'**
  String get avatar_form_traits_label;

  /// No description provided for @avatar_form_extroversion.
  ///
  /// In en, this message translates to:
  /// **'Extroversion'**
  String get avatar_form_extroversion;

  /// No description provided for @avatar_form_agreeableness.
  ///
  /// In en, this message translates to:
  /// **'Agreeableness'**
  String get avatar_form_agreeableness;

  /// No description provided for @avatar_form_conscientiousness.
  ///
  /// In en, this message translates to:
  /// **'Conscientiousness'**
  String get avatar_form_conscientiousness;

  /// No description provided for @avatar_form_add_phrase_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hello!'**
  String get avatar_form_add_phrase_hint;

  /// No description provided for @avatar_form_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get avatar_form_continue_button;

  /// No description provided for @avatar_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Avatar Summary'**
  String get avatar_summary_title;

  /// No description provided for @avatar_summary_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get avatar_summary_user;

  /// No description provided for @avatar_summary_relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get avatar_summary_relationship;

  /// No description provided for @avatar_summary_style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get avatar_summary_style;

  /// No description provided for @avatar_summary_interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get avatar_summary_interests;

  /// No description provided for @avatar_summary_phrases.
  ///
  /// In en, this message translates to:
  /// **'Common phrases'**
  String get avatar_summary_phrases;

  /// No description provided for @avatar_summary_traits.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get avatar_summary_traits;

  /// No description provided for @avatar_summary_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create my avatar'**
  String get avatar_summary_create_button;

  /// No description provided for @avatar_summary_back_button.
  ///
  /// In en, this message translates to:
  /// **'Back to edit personality'**
  String get avatar_summary_back_button;

  /// No description provided for @avatar_summary_extroversion.
  ///
  /// In en, this message translates to:
  /// **'Extroversion'**
  String get avatar_summary_extroversion;

  /// No description provided for @avatar_summary_agreeableness.
  ///
  /// In en, this message translates to:
  /// **'Agreeableness'**
  String get avatar_summary_agreeableness;

  /// No description provided for @avatar_summary_conscientiousness.
  ///
  /// In en, this message translates to:
  /// **'Conscientiousness'**
  String get avatar_summary_conscientiousness;

  /// No description provided for @avatar_loading_generating.
  ///
  /// In en, this message translates to:
  /// **'Generating avatar...'**
  String get avatar_loading_generating;

  /// No description provided for @avatar_error_video.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate the video.'**
  String get avatar_error_video;

  /// No description provided for @avatar_error_timeout.
  ///
  /// In en, this message translates to:
  /// **'The video could not be generated in time.'**
  String get avatar_error_timeout;

  /// No description provided for @avatar_not_available.
  ///
  /// In en, this message translates to:
  /// **'Avatar not available'**
  String get avatar_not_available;

  /// No description provided for @style_casual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get style_casual;

  /// No description provided for @style_formal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get style_formal;

  /// No description provided for @style_tierno.
  ///
  /// In en, this message translates to:
  /// **'Tender'**
  String get style_tierno;

  /// No description provided for @style_divertido.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get style_divertido;

  /// No description provided for @interest_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get interest_music;

  /// No description provided for @interest_tech.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get interest_tech;

  /// No description provided for @interest_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get interest_travel;

  /// No description provided for @interest_books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get interest_books;

  /// No description provided for @interest_nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get interest_nature;

  /// No description provided for @myself_avatar.
  ///
  /// In en, this message translates to:
  /// **'An avatar that represents yourself, with your own interests and style.'**
  String get myself_avatar;

  /// No description provided for @love_avatar.
  ///
  /// In en, this message translates to:
  /// **'An avatar that represents a partner or romantic interest.'**
  String get love_avatar;

  /// No description provided for @friend_avatar.
  ///
  /// In en, this message translates to:
  /// **'An avatar that represents a close friend.'**
  String get friend_avatar;

  /// No description provided for @relative_avatar.
  ///
  /// In en, this message translates to:
  /// **'An avatar that represents a relative, such as a parent or grandparent.'**
  String get relative_avatar;

  /// No description provided for @change_avatar_type.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get change_avatar_type;
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
