import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// Brand name shown in the app bar; not translated
  ///
  /// In en, this message translates to:
  /// **'IndicLearn'**
  String get appName;

  /// Window and task-switcher title of the app
  ///
  /// In en, this message translates to:
  /// **'Language Game'**
  String get appTitle;

  /// Shown on the startup screen when account services fail to initialise
  ///
  /// In en, this message translates to:
  /// **'Account services unavailable. Firebase setup or a connection may be required.'**
  String get accountServicesUnavailable;

  /// Button label to retry account service startup
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button label to skip sign-in after startup fails
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get continueWithoutSignIn;

  /// Account action label shown to guests
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @accountUnableToReach.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach your account. Check your connection and try again.'**
  String get accountUnableToReach;

  /// No description provided for @accountEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get accountEmailInvalid;

  /// No description provided for @accountCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get accountCreateTitle;

  /// No description provided for @accountEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// No description provided for @accountPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get accountPhoneLabel;

  /// No description provided for @accountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPasswordLabel;

  /// No description provided for @accountShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accountShowPassword;

  /// No description provided for @accountHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accountHidePassword;

  /// No description provided for @accountPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get accountPasswordRequired;

  /// No description provided for @accountPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get accountPasswordTooShort;

  /// No description provided for @accountPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get accountPhoneNumberLabel;

  /// No description provided for @accountPhoneCountryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Include the country code, for example +91.'**
  String get accountPhoneCountryCodeHint;

  /// No description provided for @accountPhoneExample.
  ///
  /// In en, this message translates to:
  /// **'+919876543210'**
  String get accountPhoneExample;

  /// No description provided for @mascotImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mascot image could not be loaded'**
  String get mascotImageLoadFailed;

  /// No description provided for @accountVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get accountVerificationCodeLabel;

  /// No description provided for @accountVerificationCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get accountVerificationCodeInvalid;

  /// No description provided for @accountChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number or request another code'**
  String get accountChangeNumber;

  /// No description provided for @accountSmsConsent.
  ///
  /// In en, this message translates to:
  /// **'By requesting a code, you agree to receive a verification SMS. Carrier charges may apply.'**
  String get accountSmsConsent;

  /// No description provided for @accountSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get accountSendCode;

  /// No description provided for @accountVerifyAndSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get accountVerifyAndSignIn;

  /// No description provided for @accountCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountCreateAccount;

  /// No description provided for @accountAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get accountAlreadyHaveAccount;

  /// No description provided for @accountCreateEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an email account'**
  String get accountCreateEmailAccount;

  /// No description provided for @accountForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get accountForgotPassword;

  /// No description provided for @accountEmailRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address first.'**
  String get accountEmailRequiredFirst;

  /// No description provided for @accountPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, a password-reset email has been sent.'**
  String get accountPasswordResetSent;

  /// No description provided for @accountContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountContinueGoogle;

  /// No description provided for @accountSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get accountSignInApple;

  /// No description provided for @accountContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get accountContinueGuest;

  /// No description provided for @accountProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get accountProfileTitle;

  /// No description provided for @accountProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile. Check your connection.'**
  String get accountProfileLoadError;

  /// No description provided for @accountDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get accountDisplayNameLabel;

  /// No description provided for @accountNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Use a name between 1 and 80 characters.'**
  String get accountNameLengthError;

  /// No description provided for @accountProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get accountProfileSaved;

  /// No description provided for @accountSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get accountSaveProfile;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountSessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account session unavailable. Restart the app to retry.'**
  String get accountSessionUnavailable;

  /// No description provided for @accountYourAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get accountYourAccountTitle;

  /// No description provided for @accountProfileNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be loaded. Check your connection.'**
  String get accountProfileNotLoaded;

  /// No description provided for @accountSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-out failed. Try again.'**
  String get accountSignOutFailed;

  /// No description provided for @demoSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get demoSpin;

  /// No description provided for @demoJump.
  ///
  /// In en, this message translates to:
  /// **'Jump'**
  String get demoJump;

  /// No description provided for @demoRaiseHands.
  ///
  /// In en, this message translates to:
  /// **'Raise hands'**
  String get demoRaiseHands;

  /// No description provided for @demoBlink.
  ///
  /// In en, this message translates to:
  /// **'Blink'**
  String get demoBlink;

  /// No description provided for @demoRaiseEyebrows.
  ///
  /// In en, this message translates to:
  /// **'Raise eyebrows'**
  String get demoRaiseEyebrows;

  /// No description provided for @mascotCartoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Cartoon Mascot'**
  String get mascotCartoonTitle;

  /// No description provided for @mascotRaiseEyebrows.
  ///
  /// In en, this message translates to:
  /// **'Raise eyebrows'**
  String get mascotRaiseEyebrows;

  /// No description provided for @mascotSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get mascotSpin;

  /// No description provided for @levelLoaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your scenarios'**
  String get levelLoaderTitle;

  /// No description provided for @levelLoaderLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your scenarios could not be loaded.'**
  String get levelLoaderLoadFailed;

  /// No description provided for @levelLoaderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Progress was not saved. Check your connection.'**
  String get levelLoaderSaveFailed;

  /// No description provided for @levelLoaderNoScenarios.
  ///
  /// In en, this message translates to:
  /// **'No scenarios available'**
  String get levelLoaderNoScenarios;

  /// No description provided for @levelLoaderSavingProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving progress…'**
  String get levelLoaderSavingProgress;

  /// No description provided for @levelLoaderShowingCachedProgress.
  ///
  /// In en, this message translates to:
  /// **'Showing locally cached progress'**
  String get levelLoaderShowingCachedProgress;

  /// No description provided for @levelLoaderScenariosUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total} scenarios unlocked'**
  String levelLoaderScenariosUnlocked(int unlocked, int total);

  /// No description provided for @levelLoaderLevelsComplete.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} complete'**
  String levelLoaderLevelsComplete(int completed, int total);

  /// No description provided for @levelLoaderScenarioLocked.
  ///
  /// In en, this message translates to:
  /// **'{title}, locked'**
  String levelLoaderScenarioLocked(String title);

  /// No description provided for @levelLoaderScenarioFinished.
  ///
  /// In en, this message translates to:
  /// **'{title}, complete. Replay final level'**
  String levelLoaderScenarioFinished(String title);

  /// No description provided for @levelLoaderScenarioInProgress.
  ///
  /// In en, this message translates to:
  /// **'{title}, {completed} of {total} complete. Continue level {nextLevel}'**
  String levelLoaderScenarioInProgress(
    String title,
    int completed,
    int total,
    int nextLevel,
  );

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @levelUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Level unavailable'**
  String get levelUnavailableTitle;

  /// No description provided for @levelLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading level'**
  String get levelLoading;

  /// No description provided for @levelStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total}'**
  String levelStepProgress(int current, int total);

  /// No description provided for @levelLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load level: {error}'**
  String levelLoadError(String error);

  /// No description provided for @failTitle.
  ///
  /// In en, this message translates to:
  /// **'Level complete!'**
  String get failTitle;

  /// No description provided for @failOutOfLives.
  ///
  /// In en, this message translates to:
  /// **'Out of lives :('**
  String get failOutOfLives;

  /// No description provided for @failTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get failTryAgain;

  /// No description provided for @winTitle.
  ///
  /// In en, this message translates to:
  /// **'Level complete!'**
  String get winTitle;

  /// No description provided for @winScore.
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String winScore(int score, int total);

  /// No description provided for @winTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get winTryAgain;

  /// No description provided for @winContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue...'**
  String get winContinue;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning progress'**
  String get progressTitle;

  /// No description provided for @progressLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your learning progress could not be loaded. Check your connection and try again.'**
  String get progressLoadFailed;

  /// No description provided for @celebrationTrophy.
  ///
  /// In en, this message translates to:
  /// **'🏆'**
  String get celebrationTrophy;

  /// No description provided for @celebrationWon.
  ///
  /// In en, this message translates to:
  /// **'YOU WON!'**
  String get celebrationWon;

  /// No description provided for @celebrationAmazingJob.
  ///
  /// In en, this message translates to:
  /// **'Amazing job!'**
  String get celebrationAmazingJob;

  /// No description provided for @celebrationCelebrateAgain.
  ///
  /// In en, this message translates to:
  /// **'Celebrate Again!'**
  String get celebrationCelebrateAgain;

  /// No description provided for @ftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the sound'**
  String get ftsTitle;

  /// No description provided for @mtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make the Sentence'**
  String get mtsTitle;

  /// No description provided for @sentenceComplete.
  ///
  /// In en, this message translates to:
  /// **'Sentence complete!'**
  String get sentenceComplete;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @ftsPlaySound.
  ///
  /// In en, this message translates to:
  /// **'Play sound'**
  String get ftsPlaySound;

  /// No description provided for @unableToLoadSentence.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sentence: {error}'**
  String unableToLoadSentence(String error);

  /// No description provided for @pairingTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Words (Score {score})'**
  String pairingTitle(int score);

  /// No description provided for @pairingUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load pairs: {error}'**
  String pairingUnableToLoad(String error);

  /// No description provided for @pairingNoPairs.
  ///
  /// In en, this message translates to:
  /// **'No pairs available'**
  String get pairingNoPairs;

  /// No description provided for @pairingAllMatched.
  ///
  /// In en, this message translates to:
  /// **'All pairs matched!'**
  String get pairingAllMatched;

  /// No description provided for @quizNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available.'**
  String get quizNoQuestions;

  /// No description provided for @quizUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load quiz: {error}'**
  String quizUnableToLoad(String error);

  /// No description provided for @quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete!'**
  String get quizComplete;

  /// No description provided for @quizScoreResult.
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String quizScoreResult(int score, int total);

  /// No description provided for @quizPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get quizPlayAgain;

  /// No description provided for @quizLearnProgress.
  ///
  /// In en, this message translates to:
  /// **'Learn {current}/{total}'**
  String quizLearnProgress(int current, int total);

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String quizQuestionProgress(int current, int total);

  /// No description provided for @quizQuestionListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get quizQuestionListen;

  /// No description provided for @quizQuestionCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizQuestionCorrect;

  /// No description provided for @quizQuestionNotQuite.
  ///
  /// In en, this message translates to:
  /// **'Not quite. The correct answer is highlighted.'**
  String get quizQuestionNotQuite;

  /// No description provided for @quizQuestionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get quizQuestionFinish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
