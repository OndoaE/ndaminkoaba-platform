import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NdaMinkoaba'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Learn • Preserve • Transmit'**
  String get appTagline;

  /// No description provided for @poweredByNnanga.
  ///
  /// In en, this message translates to:
  /// **'Powered by Nnanga AI Tutor'**
  String get poweredByNnanga;

  /// No description provided for @commonSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWrong;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get commonContinueWithGoogle;

  /// No description provided for @commonContinueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get commonContinueWithFacebook;

  /// No description provided for @commonOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get commonOrContinueWith;

  /// No description provided for @commonOAuthNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in isn\'t set up yet.'**
  String commonOAuthNotConfigured(String provider);

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectTitle;

  /// No description provided for @languageSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the language you\'d like to use in the app.'**
  String get languageSelectSubtitle;

  /// No description provided for @languageEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishLabel;

  /// No description provided for @languageFrenchLabel.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrenchLabel;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get loginWelcomeTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your African language learning journey.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLabel;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonMessage;

  /// No description provided for @loginButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonLabel;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @registerLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLinkLabel;

  /// No description provided for @loginEmptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get loginEmptyFieldsError;

  /// No description provided for @loginFailedError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailedError;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your African language learning journey.'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @registerButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButtonLabel;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @loginLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLinkLabel;

  /// No description provided for @registerFillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get registerFillAllFieldsError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatchError;

  /// No description provided for @passwordTooWeakError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and include a letter and a number.'**
  String get passwordTooWeakError;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Please log in.'**
  String get registerSuccessMessage;

  /// No description provided for @registerFailedError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerFailedError;

  /// No description provided for @oauthSignInFailedError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get oauthSignInFailedError;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}! 👋'**
  String welcomeGreeting(String name);

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NdaMinkoaba. Your journey to speak, preserve and pass on your language starts now.'**
  String get welcomeMessage;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Our languages, our heritage, our identity'**
  String get welcomeTagline;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @startLearningButton.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearningButton;

  /// No description provided for @welcomeBackMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBackMessage(String name);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get navCourses;

  /// No description provided for @navMyLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get navMyLearning;

  /// No description provided for @navAI.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAI;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your Ewondo learning journey'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get dashboardFallbackName;

  /// No description provided for @statLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get statLessons;

  /// No description provided for @statCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get statCertificates;

  /// No description provided for @statAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get statAvgScore;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to do next'**
  String get quickActionsSubtitle;

  /// No description provided for @actionCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get actionCourses;

  /// No description provided for @actionVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get actionVocabulary;

  /// No description provided for @actionNnanga.
  ///
  /// In en, this message translates to:
  /// **'Nnanga AI'**
  String get actionNnanga;

  /// No description provided for @actionCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get actionCertificates;

  /// No description provided for @actionBible.
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get actionBible;

  /// No description provided for @actionBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get actionBooks;

  /// No description provided for @dailyWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Word'**
  String get dailyWordTitle;

  /// No description provided for @dailyWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn one Ewondo word every day'**
  String get dailyWordSubtitle;

  /// No description provided for @dailyWordMeaning.
  ///
  /// In en, this message translates to:
  /// **'Peace / Calmness'**
  String get dailyWordMeaning;

  /// No description provided for @dailyWordUsageHint.
  ///
  /// In en, this message translates to:
  /// **'Use it today in a simple greeting or conversation.'**
  String get dailyWordUsageHint;

  /// No description provided for @dailyVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Verse'**
  String get dailyVerseTitle;

  /// No description provided for @dailyVerseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A Bible verse in Ewondo, every day'**
  String get dailyVerseSubtitle;

  /// No description provided for @dailyContentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet — check back soon.'**
  String get dailyContentEmpty;

  /// No description provided for @continueLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearningTitle;

  /// No description provided for @resumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeButton;

  /// No description provided for @progressPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String progressPercentLabel(int percent);

  /// No description provided for @myLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'My Learning'**
  String get myLearningTitle;

  /// No description provided for @myLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get myLearningSubtitle;

  /// No description provided for @myLearningEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in progress yet'**
  String get myLearningEmptyTitle;

  /// No description provided for @myLearningEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a course and it will show up here.'**
  String get myLearningEmptyMessage;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @coursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your Ewondo learning path.'**
  String get coursesSubtitle;

  /// No description provided for @searchCoursesHint.
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get searchCoursesHint;

  /// No description provided for @levelAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get levelAllLabel;

  /// No description provided for @availableCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Courses'**
  String get availableCoursesTitle;

  /// No description provided for @availableCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the beginner course'**
  String get availableCoursesSubtitle;

  /// No description provided for @noCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'No courses yet'**
  String get noCoursesTitle;

  /// No description provided for @noCoursesMessage.
  ///
  /// In en, this message translates to:
  /// **'No courses are available at this level yet.'**
  String get noCoursesMessage;

  /// No description provided for @lessonsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonsCountLabel(int count);

  /// No description provided for @levelLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish {level} to unlock this level.'**
  String levelLockedMessage(String level);

  /// No description provided for @lessonLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson to unlock this one.'**
  String get lessonLockedMessage;

  /// No description provided for @courseNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Course not found'**
  String get courseNotFoundTitle;

  /// No description provided for @courseNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This course could not be loaded. Please go back and try again.'**
  String get courseNotFoundMessage;

  /// No description provided for @yourProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgressLabel;

  /// No description provided for @progressCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed ({done}/{total} lessons)'**
  String progressCompletedSummary(int percent, int done, int total);

  /// No description provided for @viewCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get viewCertificateButton;

  /// No description provided for @claimCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'Claim Your Certificate'**
  String get claimCertificateButton;

  /// No description provided for @notEligibleCertificateError.
  ///
  /// In en, this message translates to:
  /// **'Not eligible yet — finish every lesson and pass every quiz first.'**
  String get notEligibleCertificateError;

  /// No description provided for @modulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modulesTitle;

  /// No description provided for @modulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn step by step'**
  String get modulesSubtitle;

  /// No description provided for @lessonNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumberLabel(int number);

  /// No description provided for @lessonNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content available for this lesson yet.'**
  String get lessonNoContent;

  /// No description provided for @illustratedWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrated Words'**
  String get illustratedWordsTitle;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @noSummary.
  ///
  /// In en, this message translates to:
  /// **'No summary available.'**
  String get noSummary;

  /// No description provided for @takeQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuizButton;

  /// No description provided for @nextLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLessonButton;

  /// No description provided for @finishLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Finish Lesson'**
  String get finishLessonButton;

  /// No description provided for @lessonCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson completed'**
  String get lessonCompletedMessage;

  /// No description provided for @lessonNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found'**
  String get lessonNotFoundTitle;

  /// No description provided for @lessonNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This lesson could not be loaded. Please go back and try again.'**
  String get lessonNotFoundMessage;

  /// No description provided for @pleaseAnswerAllError.
  ///
  /// In en, this message translates to:
  /// **'Please answer every question.'**
  String get pleaseAnswerAllError;

  /// No description provided for @quizSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit quiz. Try again.'**
  String get quizSubmitError;

  /// No description provided for @noQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'No quiz yet'**
  String get noQuizTitle;

  /// No description provided for @noQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'No quiz is available for this lesson yet.'**
  String get noQuizMessage;

  /// No description provided for @passMarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Pass mark: {percent}%'**
  String passMarkLabel(int percent);

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionLabel(int number);

  /// No description provided for @submitQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Quiz'**
  String get submitQuizButton;

  /// No description provided for @youPassedTitle.
  ///
  /// In en, this message translates to:
  /// **'You passed!'**
  String get youPassedTitle;

  /// No description provided for @notQuiteThereTitle.
  ///
  /// In en, this message translates to:
  /// **'Not quite there'**
  String get notQuiteThereTitle;

  /// No description provided for @scoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}% (pass mark {passMark}%)'**
  String scoreSummary(int score, int passMark);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @vocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabularyTitle;

  /// No description provided for @vocabularyHeroText.
  ///
  /// In en, this message translates to:
  /// **'Learn one new Ewondo word at a time'**
  String get vocabularyHeroText;

  /// No description provided for @searchWordsHint.
  ///
  /// In en, this message translates to:
  /// **'Search Ewondo words...'**
  String get searchWordsHint;

  /// No description provided for @levelAllShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get levelAllShort;

  /// No description provided for @noWordsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No words found'**
  String get noWordsFoundTitle;

  /// No description provided for @noWordsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or level filter.'**
  String get noWordsFoundMessage;

  /// No description provided for @nnangaTitle.
  ///
  /// In en, this message translates to:
  /// **'Nnanga AI Tutor'**
  String get nnangaTitle;

  /// No description provided for @nnangaGreeting.
  ///
  /// In en, this message translates to:
  /// **'Mbolo! I am **Nnanga**, your Ewondo AI tutor. Ask me about words, grammar, or culture from the NdaMinkoaba lessons.'**
  String get nnangaGreeting;

  /// No description provided for @nnangaErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Nnanga could not answer right now. Please try again.'**
  String get nnangaErrorFallback;

  /// No description provided for @nnangaInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Nnanga anything...'**
  String get nnangaInputHint;

  /// No description provided for @nnangaGroundedBadge.
  ///
  /// In en, this message translates to:
  /// **'From official lessons'**
  String get nnangaGroundedBadge;

  /// No description provided for @nnangaGeneralBadge.
  ///
  /// In en, this message translates to:
  /// **'General knowledge'**
  String get nnangaGeneralBadge;

  /// No description provided for @myCertificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Certificates'**
  String get myCertificatesTitle;

  /// No description provided for @myCertificatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a course and pass its quizzes to earn a certificate.'**
  String get myCertificatesSubtitle;

  /// No description provided for @noCertificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'No certificates yet'**
  String get noCertificatesTitle;

  /// No description provided for @noCertificatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish all lessons and quizzes in a course to earn your first certificate.'**
  String get noCertificatesMessage;

  /// No description provided for @booksTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksTitle;

  /// No description provided for @booksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read Ewondo books as PDF or EPUB, right in the app.'**
  String get booksSubtitle;

  /// No description provided for @noBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get noBooksTitle;

  /// No description provided for @noBooksMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back soon — new books will appear here.'**
  String get noBooksMessage;

  /// No description provided for @bookLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this book. Please try again.'**
  String get bookLoadError;

  /// No description provided for @certificateNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate not found'**
  String get certificateNotFoundTitle;

  /// No description provided for @certificateNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This certificate could not be loaded. Please go back and try again.'**
  String get certificateNotFoundMessage;

  /// No description provided for @certificateOfCompletion.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Completion'**
  String get certificateOfCompletion;

  /// No description provided for @certificateCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificate Code'**
  String get certificateCodeLabel;

  /// No description provided for @issuedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Issued On'**
  String get issuedOnLabel;

  /// No description provided for @generatePdfButton.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdfButton;

  /// No description provided for @viewDownloadPdfButton.
  ///
  /// In en, this message translates to:
  /// **'View / Download PDF'**
  String get viewDownloadPdfButton;

  /// No description provided for @generatePdfError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the PDF. Try again.'**
  String get generatePdfError;

  /// No description provided for @bibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Holy Bible'**
  String get bibleTitle;

  /// No description provided for @bibleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read Scripture in Ewondo, side by side with your language'**
  String get bibleSubtitle;

  /// No description provided for @bibleFourGospelsTitle.
  ///
  /// In en, this message translates to:
  /// **'The Four Gospels'**
  String get bibleFourGospelsTitle;

  /// No description provided for @bibleFourGospelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The life and teachings of Jesus'**
  String get bibleFourGospelsSubtitle;

  /// No description provided for @bibleOtherBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Books'**
  String get bibleOtherBooksTitle;

  /// No description provided for @bibleComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get bibleComingSoonLabel;

  /// No description provided for @bibleChaptersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} chapters'**
  String bibleChaptersCountLabel(int count);

  /// No description provided for @bibleNoContentTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bible content yet'**
  String get bibleNoContentTitle;

  /// No description provided for @bibleNoContentMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back soon — new chapters are being added.'**
  String get bibleNoContentMessage;

  /// No description provided for @bibleSelectChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Chapter'**
  String get bibleSelectChapterTitle;

  /// No description provided for @bibleChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String bibleChapterLabel(int number);

  /// No description provided for @bibleVerseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String bibleVerseCountLabel(int count);

  /// No description provided for @biblePreviousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get biblePreviousChapter;

  /// No description provided for @bibleNextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get bibleNextChapter;

  /// No description provided for @bibleTranslationPending.
  ///
  /// In en, this message translates to:
  /// **'Translation not yet available'**
  String get bibleTranslationPending;

  /// No description provided for @bibleChapterNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter not found'**
  String get bibleChapterNotFoundTitle;

  /// No description provided for @bibleChapterNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This chapter could not be loaded. Please go back and try again.'**
  String get bibleChapterNotFoundMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @statCoursesEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Courses Enrolled'**
  String get statCoursesEnrolled;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password (optional)'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current password'**
  String get newPasswordHint;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedMessage;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get profileUpdateError;

  /// No description provided for @logOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutButton;

  /// No description provided for @switchLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguageTitle;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Language'**
  String get chooseLanguageTitle;

  /// No description provided for @chooseLanguageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which language would you like to learn?'**
  String get chooseLanguageQuestion;

  /// No description provided for @chooseLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'You can switch languages anytime from your profile.'**
  String get chooseLanguageHint;

  /// No description provided for @chooseLanguageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No languages are available yet.'**
  String get chooseLanguageEmptyTitle;

  /// No description provided for @chooseLanguageOnlyCurrentMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re already learning the only language published so far.'**
  String get chooseLanguageOnlyCurrentMessage;

  /// No description provided for @continueLearningWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String continueLearningWelcomeBack(String name);

  /// No description provided for @continueLearningWelcomeBackNoName.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get continueLearningWelcomeBackNoName;

  /// No description provided for @continueLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get continueLearningSubtitle;

  /// No description provided for @continueLearningContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with {language}?'**
  String continueLearningContinueTitle(String language);

  /// No description provided for @continueLearningContinueFallback.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off?'**
  String get continueLearningContinueFallback;

  /// No description provided for @continueLearningContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up your learning journey right where you left off.'**
  String get continueLearningContinueSubtitle;

  /// No description provided for @continueLearningNewLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new language?'**
  String get continueLearningNewLanguageTitle;

  /// No description provided for @continueLearningNewLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore another Cameroonian language from scratch.'**
  String get continueLearningNewLanguageSubtitle;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
