// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get appName => 'IndicLearn';

  @override
  String get appTitle => 'Language Game';

  @override
  String get accountServicesUnavailable =>
      'Account services unavailable. Firebase setup or a connection may be required.';

  @override
  String get retry => 'Retry';

  @override
  String get continueWithoutSignIn => 'Continue without signing in';

  @override
  String get signIn => 'Sign in';

  @override
  String get accountUnableToReach =>
      'Unable to reach your account. Check your connection and try again.';

  @override
  String get accountEmailInvalid => 'Enter a valid email address.';

  @override
  String get accountCreateTitle => 'Create your account';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountPhoneLabel => 'Phone';

  @override
  String get accountPasswordLabel => 'Password';

  @override
  String get accountShowPassword => 'Show password';

  @override
  String get accountHidePassword => 'Hide password';

  @override
  String get accountPasswordRequired => 'Enter your password.';

  @override
  String get accountPasswordTooShort => 'Use at least 8 characters.';

  @override
  String get accountPhoneNumberLabel => 'Phone number';

  @override
  String get accountPhoneCountryCodeHint =>
      'Include the country code, for example +91.';

  @override
  String get accountPhoneExample => '+919876543210';

  @override
  String get mascotImageLoadFailed => 'Mascot image could not be loaded';

  @override
  String get accountVerificationCodeLabel => 'Verification code';

  @override
  String get accountVerificationCodeInvalid => 'Enter the 6-digit code.';

  @override
  String get accountChangeNumber => 'Change number or request another code';

  @override
  String get accountSmsConsent =>
      'By requesting a code, you agree to receive a verification SMS. Carrier charges may apply.';

  @override
  String get accountSendCode => 'Send code';

  @override
  String get accountVerifyAndSignIn => 'Verify and sign in';

  @override
  String get accountCreateAccount => 'Create account';

  @override
  String get accountAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get accountCreateEmailAccount => 'Create an email account';

  @override
  String get accountForgotPassword => 'Forgot password?';

  @override
  String get accountEmailRequiredFirst => 'Enter your email address first.';

  @override
  String get accountPasswordResetSent =>
      'If an account exists, a password-reset email has been sent.';

  @override
  String get accountContinueGoogle => 'Continue with Google';

  @override
  String get accountSignInApple => 'Sign in with Apple';

  @override
  String get accountContinueGuest => 'Continue as guest';

  @override
  String get accountProfileTitle => 'Your profile';

  @override
  String get accountProfileLoadError =>
      'Unable to load your profile. Check your connection.';

  @override
  String get accountDisplayNameLabel => 'Display name';

  @override
  String get accountNameLengthError =>
      'Use a name between 1 and 80 characters.';

  @override
  String get accountProfileSaved => 'Profile saved';

  @override
  String get accountSaveProfile => 'Save profile';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSessionUnavailable =>
      'Account session unavailable. Restart the app to retry.';

  @override
  String get accountYourAccountTitle => 'Your account';

  @override
  String get accountProfileNotLoaded =>
      'Your profile could not be loaded. Check your connection.';

  @override
  String get accountSignOutFailed => 'Sign-out failed. Try again.';

  @override
  String get demoSpin => 'Spin';

  @override
  String get demoJump => 'Jump';

  @override
  String get demoRaiseHands => 'Raise hands';

  @override
  String get demoBlink => 'Blink';

  @override
  String get demoRaiseEyebrows => 'Raise eyebrows';

  @override
  String get mascotCartoonTitle => 'Cartoon Mascot';

  @override
  String get mascotRaiseEyebrows => 'Raise eyebrows';

  @override
  String get mascotSpin => 'Spin';

  @override
  String get levelLoaderTitle => 'Your scenarios';

  @override
  String get levelLoaderLoadFailed => 'Your scenarios could not be loaded.';

  @override
  String get levelLoaderSaveFailed =>
      'Progress was not saved. Check your connection.';

  @override
  String get levelLoaderNoScenarios => 'No scenarios available';

  @override
  String get levelLoaderSavingProgress => 'Saving progress…';

  @override
  String get levelLoaderShowingCachedProgress =>
      'Showing locally cached progress';

  @override
  String levelLoaderScenariosUnlocked(int unlocked, int total) {
    return '$unlocked / $total scenarios unlocked';
  }

  @override
  String levelLoaderLevelsComplete(int completed, int total) {
    return '$completed / $total complete';
  }

  @override
  String levelLoaderScenarioLocked(String title) {
    return '$title, locked';
  }

  @override
  String levelLoaderScenarioFinished(String title) {
    return '$title, complete. Replay final level';
  }

  @override
  String levelLoaderScenarioInProgress(
    String title,
    int completed,
    int total,
    int nextLevel,
  ) {
    return '$title, $completed of $total complete. Continue level $nextLevel';
  }

  @override
  String get yourProfile => 'Your profile';

  @override
  String get levelUnavailableTitle => 'Level unavailable';

  @override
  String get levelLoading => 'Loading level';

  @override
  String levelStepProgress(int current, int total) {
    return 'Step $current/$total';
  }

  @override
  String levelLoadError(String error) {
    return 'Unable to load level: $error';
  }

  @override
  String get failTitle => 'Level complete!';

  @override
  String get failOutOfLives => 'Out of lives :(';

  @override
  String get failTryAgain => 'Try Again';

  @override
  String get winTitle => 'Level complete!';

  @override
  String winScore(int score, int total) {
    return 'You scored $score out of $total';
  }

  @override
  String get winTryAgain => 'Try Again';

  @override
  String get winContinue => 'Continue...';

  @override
  String get progressTitle => 'Learning progress';

  @override
  String get progressLoadFailed =>
      'Your learning progress could not be loaded. Check your connection and try again.';

  @override
  String get celebrationTrophy => '🏆';

  @override
  String get celebrationWon => 'YOU WON!';

  @override
  String get celebrationAmazingJob => 'Amazing job!';

  @override
  String get celebrationCelebrateAgain => 'Celebrate Again!';

  @override
  String get ftsTitle => 'Follow the sound';

  @override
  String get mtsTitle => 'Make the Sentence';

  @override
  String get sentenceComplete => 'Sentence complete!';

  @override
  String get continueLabel => 'Continue';

  @override
  String get ftsPlaySound => 'Play sound';

  @override
  String unableToLoadSentence(String error) {
    return 'Unable to load sentence: $error';
  }

  @override
  String pairingTitle(int score) {
    return 'Match Words (Score $score)';
  }

  @override
  String pairingUnableToLoad(String error) {
    return 'Unable to load pairs: $error';
  }

  @override
  String get pairingNoPairs => 'No pairs available';

  @override
  String get pairingAllMatched => 'All pairs matched!';

  @override
  String get quizNoQuestions => 'No questions available.';

  @override
  String quizUnableToLoad(String error) {
    return 'Unable to load quiz: $error';
  }

  @override
  String get quizComplete => 'Complete!';

  @override
  String quizScoreResult(int score, int total) {
    return 'You scored $score out of $total';
  }

  @override
  String get quizPlayAgain => 'Play Again';

  @override
  String quizLearnProgress(int current, int total) {
    return 'Learn $current/$total';
  }

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizQuestionListen => 'Listen';

  @override
  String get quizQuestionCorrect => 'Correct!';

  @override
  String get quizQuestionNotQuite =>
      'Not quite. The correct answer is highlighted.';

  @override
  String get quizQuestionFinish => 'Finish';
}
