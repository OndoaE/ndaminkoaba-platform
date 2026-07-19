// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NdaMinkoaba';

  @override
  String get appTagline => 'Learn • Preserve • Transmit';

  @override
  String get poweredByNnanga => 'Powered by Nnanga AI Tutor';

  @override
  String get commonSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonContinueWithGoogle => 'Continue with Google';

  @override
  String get commonContinueWithFacebook => 'Continue with Facebook';

  @override
  String get commonOrContinueWith => 'or continue with';

  @override
  String commonOAuthNotConfigured(String provider) {
    return '$provider sign-in isn\'t set up yet.';
  }

  @override
  String get languageSelectTitle => 'Choose your language';

  @override
  String get languageSelectSubtitle =>
      'Select the language you\'d like to use in the app.';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get languageFrenchLabel => 'Français';

  @override
  String get loginWelcomeTitle => 'Welcome Back 👋';

  @override
  String get loginSubtitle =>
      'Continue your African language learning journey.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPasswordLabel => 'Forgot password?';

  @override
  String get comingSoonMessage => 'Coming soon';

  @override
  String get loginButtonLabel => 'Login';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get registerLinkLabel => 'Register';

  @override
  String get loginEmptyFieldsError => 'Please enter your email and password.';

  @override
  String get loginFailedError => 'Login failed. Please check your credentials.';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get registerSubtitle =>
      'Start your African language learning journey.';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get registerButtonLabel => 'Register';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get loginLinkLabel => 'Login';

  @override
  String get registerFillAllFieldsError => 'Please fill in all fields.';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match.';

  @override
  String get passwordTooWeakError =>
      'Password must be at least 8 characters and include a letter and a number.';

  @override
  String get registerSuccessMessage =>
      'Account created successfully. Please log in.';

  @override
  String get registerFailedError => 'Registration failed. Please try again.';

  @override
  String get oauthSignInFailedError => 'Sign-in failed. Please try again.';

  @override
  String welcomeGreeting(String name) {
    return 'Welcome, $name! 👋';
  }

  @override
  String get welcomeMessage =>
      'Welcome to NdaMinkoaba. Your journey to speak, preserve and pass on your language starts now.';

  @override
  String get welcomeTagline => 'Our languages, our heritage, our identity';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get startLearningButton => 'Start Learning';

  @override
  String welcomeBackMessage(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navCourses => 'Courses';

  @override
  String get navMyLearning => 'Learning';

  @override
  String get navAI => 'AI';

  @override
  String get navProfile => 'Profile';

  @override
  String get dashboardSubtitle => 'Continue your Ewondo learning journey';

  @override
  String get dashboardFallbackName => 'Learner';

  @override
  String get statLessons => 'Lessons';

  @override
  String get statCertificates => 'Certificates';

  @override
  String get statAvgScore => 'Avg Score';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get quickActionsSubtitle => 'Choose what you want to do next';

  @override
  String get actionCourses => 'Courses';

  @override
  String get actionVocabulary => 'Vocabulary';

  @override
  String get actionNnanga => 'Nnanga AI';

  @override
  String get actionCertificates => 'Certificates';

  @override
  String get actionBible => 'Bible';

  @override
  String get actionBooks => 'Books';

  @override
  String get dailyWordTitle => 'Daily Word';

  @override
  String get dailyWordSubtitle => 'Learn one Ewondo word every day';

  @override
  String get dailyWordMeaning => 'Peace / Calmness';

  @override
  String get dailyWordUsageHint =>
      'Use it today in a simple greeting or conversation.';

  @override
  String get dailyVerseTitle => 'Daily Verse';

  @override
  String get dailyVerseSubtitle => 'A Bible verse in Ewondo, every day';

  @override
  String get dailyContentEmpty => 'Nothing added yet — check back soon.';

  @override
  String get continueLearningTitle => 'Continue Learning';

  @override
  String get resumeButton => 'Resume';

  @override
  String progressPercentLabel(int percent) {
    return '$percent% complete';
  }

  @override
  String get myLearningTitle => 'My Learning';

  @override
  String get myLearningSubtitle => 'Pick up where you left off';

  @override
  String get myLearningEmptyTitle => 'Nothing in progress yet';

  @override
  String get myLearningEmptyMessage =>
      'Start a course and it will show up here.';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesSubtitle => 'Choose your Ewondo learning path.';

  @override
  String get searchCoursesHint => 'Search courses...';

  @override
  String get levelAllLabel => 'All Levels';

  @override
  String get availableCoursesTitle => 'Available Courses';

  @override
  String get availableCoursesSubtitle => 'Start with the beginner course';

  @override
  String get noCoursesTitle => 'No courses yet';

  @override
  String get noCoursesMessage => 'No courses are available at this level yet.';

  @override
  String lessonsCountLabel(int count) {
    return '$count lessons';
  }

  @override
  String levelLockedMessage(String level) {
    return 'Finish $level to unlock this level.';
  }

  @override
  String get lessonLockedMessage =>
      'Finish the previous lesson to unlock this one.';

  @override
  String get courseNotFoundTitle => 'Course not found';

  @override
  String get courseNotFoundMessage =>
      'This course could not be loaded. Please go back and try again.';

  @override
  String get yourProgressLabel => 'Your Progress';

  @override
  String progressCompletedSummary(int percent, int done, int total) {
    return '$percent% completed ($done/$total lessons)';
  }

  @override
  String get viewCertificateButton => 'View Certificate';

  @override
  String get claimCertificateButton => 'Claim Your Certificate';

  @override
  String get notEligibleCertificateError =>
      'Not eligible yet — finish every lesson and pass every quiz first.';

  @override
  String get modulesTitle => 'Modules';

  @override
  String get modulesSubtitle => 'Learn step by step';

  @override
  String lessonNumberLabel(int number) {
    return 'Lesson $number';
  }

  @override
  String get lessonNoContent => 'No content available for this lesson yet.';

  @override
  String get illustratedWordsTitle => 'Illustrated Words';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get noSummary => 'No summary available.';

  @override
  String get takeQuizButton => 'Take Quiz';

  @override
  String get nextLessonButton => 'Next Lesson';

  @override
  String get finishLessonButton => 'Finish Lesson';

  @override
  String get lessonCompletedMessage => 'Lesson completed';

  @override
  String get lessonNotFoundTitle => 'Lesson not found';

  @override
  String get lessonNotFoundMessage =>
      'This lesson could not be loaded. Please go back and try again.';

  @override
  String get pleaseAnswerAllError => 'Please answer every question.';

  @override
  String get quizSubmitError => 'Could not submit quiz. Try again.';

  @override
  String get noQuizTitle => 'No quiz yet';

  @override
  String get noQuizMessage => 'No quiz is available for this lesson yet.';

  @override
  String passMarkLabel(int percent) {
    return 'Pass mark: $percent%';
  }

  @override
  String questionLabel(int number) {
    return 'Question $number';
  }

  @override
  String get submitQuizButton => 'Submit Quiz';

  @override
  String get youPassedTitle => 'You passed!';

  @override
  String get notQuiteThereTitle => 'Not quite there';

  @override
  String scoreSummary(int score, int passMark) {
    return 'Score: $score% (pass mark $passMark%)';
  }

  @override
  String get reviewTitle => 'Review';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get continueButton => 'Continue';

  @override
  String get vocabularyTitle => 'Vocabulary';

  @override
  String get vocabularyHeroText => 'Learn one new Ewondo word at a time';

  @override
  String get searchWordsHint => 'Search Ewondo words...';

  @override
  String get levelAllShort => 'All';

  @override
  String get noWordsFoundTitle => 'No words found';

  @override
  String get noWordsFoundMessage => 'Try a different search or level filter.';

  @override
  String get nnangaTitle => 'Nnanga AI Tutor';

  @override
  String get nnangaGreeting =>
      'Mbolo! I am **Nnanga**, your Ewondo AI tutor. Ask me about words, grammar, or culture from the NdaMinkoaba lessons.';

  @override
  String get nnangaErrorFallback =>
      'Nnanga could not answer right now. Please try again.';

  @override
  String get nnangaInputHint => 'Ask Nnanga anything...';

  @override
  String get nnangaGroundedBadge => 'From official lessons';

  @override
  String get nnangaGeneralBadge => 'General knowledge';

  @override
  String get myCertificatesTitle => 'My Certificates';

  @override
  String get myCertificatesSubtitle =>
      'Complete a course and pass its quizzes to earn a certificate.';

  @override
  String get noCertificatesTitle => 'No certificates yet';

  @override
  String get noCertificatesMessage =>
      'Finish all lessons and quizzes in a course to earn your first certificate.';

  @override
  String get booksTitle => 'Books';

  @override
  String get booksSubtitle =>
      'Read Ewondo books as PDF or EPUB, right in the app.';

  @override
  String get noBooksTitle => 'No books yet';

  @override
  String get noBooksMessage => 'Check back soon — new books will appear here.';

  @override
  String get bookLoadError => 'Could not load this book. Please try again.';

  @override
  String get certificateNotFoundTitle => 'Certificate not found';

  @override
  String get certificateNotFoundMessage =>
      'This certificate could not be loaded. Please go back and try again.';

  @override
  String get certificateOfCompletion => 'Certificate of Completion';

  @override
  String get certificateCodeLabel => 'Certificate Code';

  @override
  String get issuedOnLabel => 'Issued On';

  @override
  String get generatePdfButton => 'Generate PDF';

  @override
  String get viewDownloadPdfButton => 'View / Download PDF';

  @override
  String get generatePdfError => 'Could not generate the PDF. Try again.';

  @override
  String get bibleTitle => 'Holy Bible';

  @override
  String get bibleSubtitle =>
      'Read Scripture in Ewondo, side by side with your language';

  @override
  String get bibleFourGospelsTitle => 'The Four Gospels';

  @override
  String get bibleFourGospelsSubtitle => 'The life and teachings of Jesus';

  @override
  String get bibleOtherBooksTitle => 'Other Books';

  @override
  String get bibleComingSoonLabel => 'Coming soon';

  @override
  String bibleChaptersCountLabel(int count) {
    return '$count chapters';
  }

  @override
  String get bibleNoContentTitle => 'No Bible content yet';

  @override
  String get bibleNoContentMessage =>
      'Check back soon — new chapters are being added.';

  @override
  String get bibleSelectChapterTitle => 'Select a Chapter';

  @override
  String bibleChapterLabel(int number) {
    return 'Chapter $number';
  }

  @override
  String bibleVerseCountLabel(int count) {
    return '$count verses';
  }

  @override
  String get biblePreviousChapter => 'Previous';

  @override
  String get bibleNextChapter => 'Next';

  @override
  String get bibleTranslationPending => 'Translation not yet available';

  @override
  String get bibleChapterNotFoundTitle => 'Chapter not found';

  @override
  String get bibleChapterNotFoundMessage =>
      'This chapter could not be loaded. Please go back and try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get statCoursesEnrolled => 'Courses Enrolled';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get newPasswordLabel => 'New Password (optional)';

  @override
  String get newPasswordHint => 'Leave blank to keep current password';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get profileUpdatedMessage => 'Profile updated';

  @override
  String get profileUpdateError => 'Could not update profile.';

  @override
  String get logOutButton => 'Log Out';

  @override
  String get switchLanguageTitle => 'Switch Language';

  @override
  String get chooseLanguageTitle => 'Choose a Language';

  @override
  String get chooseLanguageQuestion =>
      'Which language would you like to learn?';

  @override
  String get chooseLanguageHint =>
      'You can switch languages anytime from your profile.';

  @override
  String get chooseLanguageEmptyTitle => 'No languages are available yet.';

  @override
  String get chooseLanguageOnlyCurrentMessage =>
      'You\'re already learning the only language published so far.';

  @override
  String continueLearningWelcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get continueLearningWelcomeBackNoName => 'Welcome back!';

  @override
  String get continueLearningSubtitle => 'What would you like to do today?';

  @override
  String continueLearningContinueTitle(String language) {
    return 'Continue with $language?';
  }

  @override
  String get continueLearningContinueFallback => 'Continue where you left off?';

  @override
  String get continueLearningContinueSubtitle =>
      'Pick up your learning journey right where you left off.';

  @override
  String get continueLearningNewLanguageTitle => 'Start a new language?';

  @override
  String get continueLearningNewLanguageSubtitle =>
      'Explore another Cameroonian language from scratch.';
}
