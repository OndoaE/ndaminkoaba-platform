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
  String get commonOrContinueWith => 'or continue with';

  @override
  String commonOAuthNotConfigured(String provider) {
    return '$provider sign-in isn\'t set up yet.';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNone => 'None';

  @override
  String get commonUnassigned => 'Unassigned';

  @override
  String get commonOptional => 'optional';

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
  String get rememberMeLabel => 'Remember me';

  @override
  String get comingSoonMessage => 'Coming soon';

  @override
  String get loginButtonLabel => 'Login';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get registerLinkLabel => 'Sign Up';

  @override
  String get loginEmptyFieldsError => 'Please enter your email and password.';

  @override
  String get loginFailedError => 'Login failed. Please check your credentials.';

  @override
  String get createAccountTitle => 'Create an account';

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
  String get registerButtonLabel => 'Sign Up';

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
  String get navLearn => 'Learn';

  @override
  String get navPractice => 'Practice';

  @override
  String get navAI => 'AI Tutor';

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
  String get certificateEarnedTitle => 'Certificate earned!';

  @override
  String get certificateEarnedMessage =>
      'You\'ve completed every lesson and quiz. Well done!';

  @override
  String get certificateEarnedButton => 'View my certificate';

  @override
  String get modulesTitle => 'Modules';

  @override
  String get modulesSubtitle => 'Learn step by step';

  @override
  String get downloadForOfflineButton => 'Download for offline';

  @override
  String downloadingOfflineLabel(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get downloadedOfflineLabel => 'Downloaded for offline';

  @override
  String get removeDownloadButton => 'Remove download';

  @override
  String get removeDownloadConfirmTitle => 'Remove downloaded course?';

  @override
  String get removeDownloadConfirmMessage =>
      'You\'ll need to download it again to use it offline.';

  @override
  String get downloadFailedMessage =>
      'Couldn\'t download the course. Check your connection and try again.';

  @override
  String get downloadCompleteMessage =>
      'Course downloaded — available offline now.';

  @override
  String get quizRequiresConnectivityMessage =>
      'You\'re offline — connect to the internet to take this quiz.';

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
  String get previousLessonButton => 'Previous';

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
  String get uploadPhotoTooltip => 'Upload photo';

  @override
  String get couldNotUploadPhotoError => 'Could not upload photo.';

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
  String get chooseLanguageLoadError =>
      'Couldn\'t load languages. Check your connection to the server and try again.';

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

  @override
  String get adminNeedsWiderScreen =>
      'The admin dashboard needs a wider screen.';

  @override
  String get adminResizeBrowserMessage =>
      'Please resize your browser window or use a desktop device.';

  @override
  String get adminNavOverview => 'Overview';

  @override
  String get adminNavLanguages => 'Languages';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminNavCertificates => 'Certificates';

  @override
  String get adminNavReportsActivity => 'Reports & Activity';

  @override
  String get adminNavDashboard => 'Dashboard';

  @override
  String get adminNavLearners => 'Learners';

  @override
  String get adminNavCourses => 'Courses';

  @override
  String get adminNavLessonsContent => 'Lessons & Content';

  @override
  String get adminNavVocabulary => 'Vocabulary';

  @override
  String get adminNavAssessments => 'Assessments';

  @override
  String get adminNavAiTutor => 'AI Tutor';

  @override
  String get adminNavBible => 'Bible';

  @override
  String get adminNavBooks => 'Books';

  @override
  String get adminNavDaily => 'Phrase & Verse of the Day';

  @override
  String get adminNavReports => 'Reports';

  @override
  String adminLanguageActiveSuffix(String name) {
    return '$name · Active';
  }

  @override
  String get adminBackToAllLanguages => 'Back to All Languages';

  @override
  String get adminRoleFallback => 'Admin';

  @override
  String get adminSuperAdminFallback => 'Super Admin';

  @override
  String get adminLanguageFallback => 'Language';

  @override
  String get adminDashboardOverviewTitle => 'Dashboard Overview';

  @override
  String get adminDashboardOverviewSubtitle =>
      'Here\'s what\'s happening across the platform today.';

  @override
  String get adminStatActiveLanguages => 'Active Languages';

  @override
  String get adminStatTotalLearners => 'Total Learners';

  @override
  String get adminStatPublishedCourses => 'Published Courses';

  @override
  String get adminStatLessonsCompleted => 'Lessons Completed';

  @override
  String get adminLanguageManagementTitle => 'Language Management';

  @override
  String get adminAddLanguageButton => 'Add Language';

  @override
  String get adminViewAllLanguages => 'View All Languages';

  @override
  String get adminColLanguage => 'Language';

  @override
  String get adminColCode => 'Code';

  @override
  String get adminColLearners => 'Learners';

  @override
  String get adminColCourses => 'Courses';

  @override
  String get adminColProgress => 'Progress';

  @override
  String get adminColStatus => 'Status';

  @override
  String get adminColActions => 'Actions';

  @override
  String get adminOpenDashboard => 'Open Dashboard';

  @override
  String get adminStatusActive => 'Active';

  @override
  String get adminStatusDraft => 'Draft';

  @override
  String get adminAddLanguageNameHint => 'Name (e.g. Bassa)';

  @override
  String get adminAddLanguageCodeHint => 'Code (e.g. bas)';

  @override
  String get adminAddLanguageCountryHint => 'Country (optional)';

  @override
  String get adminLanguageAddedMessage =>
      'Language added. It starts inactive — publish it once its content is ready.';

  @override
  String get adminCouldNotAddLanguage => 'Could not add language.';

  @override
  String get adminCourseCompletionTitle => 'Course Completion';

  @override
  String get adminLevelBeginner => 'Beginner';

  @override
  String get adminLevelIntermediate => 'Intermediate';

  @override
  String get adminLevelAdvanced => 'Advanced';

  @override
  String get adminQuickActionsTitle => 'Quick Actions';

  @override
  String get adminQuickActionCreateCourse => 'Create Course';

  @override
  String get adminQuickActionAddUser => 'Add User';

  @override
  String get adminQuickActionUploadContent => 'Upload Content';

  @override
  String get adminRecentActivityTitle => 'Recent Activity';

  @override
  String get adminNoRecentActivity => 'No recent activity.';

  @override
  String get adminViewAllActivity => 'View All Activity';

  @override
  String get adminLearnerActivityTitle => 'Learner Activity';

  @override
  String get adminLegendNewLearners => 'New Learners';

  @override
  String get adminLegendActiveLearners => 'Active Learners';

  @override
  String get adminNoActivityData => 'No activity data yet.';

  @override
  String get adminAiContentReviewTitle => 'AI Content Review';

  @override
  String adminAiReviewCountMessage(int count) {
    return '$count AI-generated lesson drafts are waiting for review';
  }

  @override
  String get adminReviewContentButton => 'Review Content';

  @override
  String get adminSystemNoticeTitle => 'System Notice';

  @override
  String get adminAllSystemsOperational => 'All systems operational';

  @override
  String adminLastUpdatedLabel(String date) {
    return 'Last updated: $date';
  }

  @override
  String get adminAuditVerbCreated => 'created a';

  @override
  String get adminAuditVerbUpdated => 'updated a';

  @override
  String get adminAuditVerbDeleted => 'deleted a';

  @override
  String adminAuditActivityLine(String actor, String verb, String entity) {
    return '$actor $verb $entity';
  }

  @override
  String adminLanguageDashboardTitle(String language) {
    return '$language Dashboard';
  }

  @override
  String adminLanguageDashboardSubtitle(String language) {
    return 'Content and learner activity for $language.';
  }

  @override
  String get adminNewCourseButton => 'New Course';

  @override
  String get adminStatLessons => 'Lessons';

  @override
  String get adminCourseManagementTitle => 'Course Management';

  @override
  String get adminViewAllCourses => 'View All Courses';

  @override
  String get adminColCourseSingle => 'Course';

  @override
  String get adminColLevel => 'Level';

  @override
  String get adminContentWorkflowTitle => 'Content Workflow';

  @override
  String get adminWorkflowDraft => 'Draft';

  @override
  String get adminWorkflowInReview => 'In Review';

  @override
  String get adminWorkflowApproved => 'Approved';

  @override
  String get adminWorkflowPublished => 'Published';

  @override
  String get adminContentQualityTitle => 'Content Quality';

  @override
  String get adminQuickActionNewLesson => 'New Lesson';

  @override
  String get adminQuickActionNewQuiz => 'New Quiz';

  @override
  String get adminQuickActionTrainAi => 'Train the AI';

  @override
  String get adminRecentCertificatesTitle => 'Recent Certificates';

  @override
  String get adminNoCertificatesYet => 'No certificates issued yet.';

  @override
  String adminCertificateCompletedLine(String learner, String course) {
    return '$learner completed $course';
  }

  @override
  String get adminNnangaAiReviewTitle => 'Nnanga AI Review';

  @override
  String adminNnangaReviewCountMessage(int count, String language) {
    return '$count AI-generated $language lesson drafts are waiting for review';
  }

  @override
  String get adminTabAll => 'All';

  @override
  String adminUpdatedCountMessage(int count) {
    return '$count course(s) updated.';
  }

  @override
  String get adminCouldNotUpdateCourses => 'Could not update courses.';

  @override
  String get adminAssignReviewerTitle => 'Assign Reviewer';

  @override
  String adminAssignReviewerPrompt(int count) {
    return 'Assign a reviewer to $count selected course(s).';
  }

  @override
  String get adminNoReviewersAvailable => 'No teachers or admins available.';

  @override
  String get adminReviewerAssignedMessage => 'Reviewer assigned.';

  @override
  String get adminCouldNotAssignReviewer => 'Could not assign reviewer.';

  @override
  String adminCourseManagementSubtitle(String language) {
    return 'Manage every course in $language.';
  }

  @override
  String get adminStatTotalCourses => 'Total Courses';

  @override
  String get adminStatDrafts => 'Drafts';

  @override
  String get adminSearchCoursesHint => 'Search courses...';

  @override
  String get adminAllLevelsLabel => 'All Levels';

  @override
  String get adminBulkPublish => 'Publish';

  @override
  String get adminBulkMoveToDraft => 'Move to Draft';

  @override
  String get adminBulkArchive => 'Archive';

  @override
  String get adminColLessons => 'Lessons';

  @override
  String get adminColReviewer => 'Reviewer';

  @override
  String get adminPublishingPipelineTitle => 'Publishing Pipeline';

  @override
  String get adminContentHealthTitle => 'Content Health';

  @override
  String get adminRecentCourseActivityTitle => 'Recent Course Activity';

  @override
  String get adminWorkflowArchived => 'Archived';

  @override
  String get adminHealthLessonsPublished => 'Lessons published';

  @override
  String get adminHealthLessonsApproved => 'Lessons approved';

  @override
  String get adminHealthLessonsInReview => 'Lessons in review';

  @override
  String get adminHealthLessonsInDraft => 'Lessons in draft';

  @override
  String get adminWizardStepDetails => 'Course Details';

  @override
  String get adminWizardStepCurriculum => 'Curriculum';

  @override
  String get adminWizardStepResources => 'Learning Resources';

  @override
  String get adminWizardStepAssessment => 'Assessment';

  @override
  String get adminWizardStepReview => 'Review & Publish';

  @override
  String get adminTitleMinLengthError => 'Title must be at least 3 characters.';

  @override
  String get adminCourseCreatedMessage =>
      'Course created. Continue building it out below.';

  @override
  String get adminCouldNotSaveCourse => 'Could not save course.';

  @override
  String get adminLearningResourcesSavedMessage => 'Learning resources saved.';

  @override
  String get adminCouldNotSaveGeneric => 'Could not save.';

  @override
  String get adminCoverUpdatedMessage => 'Cover updated.';

  @override
  String get adminCouldNotUploadCover => 'Could not upload cover.';

  @override
  String get adminArchiveCourseTitle => 'Archive Course';

  @override
  String get adminArchiveCourseConfirm =>
      'Archived courses are hidden from learners but not deleted. Continue?';

  @override
  String get adminCourseArchivedMessage => 'Course archived.';

  @override
  String get adminCouldNotArchiveCourse => 'Could not archive course.';

  @override
  String get adminCoursePublishedMessage => 'Course published.';

  @override
  String get adminCouldNotPublishCourse => 'Could not publish course.';

  @override
  String get adminModuleLessonsFirstError =>
      'Delete this module\'s lessons first.';

  @override
  String get adminCouldNotAddModule => 'Could not add module.';

  @override
  String get adminCouldNotUpdateModule => 'Could not update module.';

  @override
  String get adminCouldNotDeleteModule => 'Could not delete module.';

  @override
  String get adminLessonContentMinLengthError =>
      'Lesson content must be at least 10 characters.';

  @override
  String get adminCouldNotAddLesson => 'Could not add lesson.';

  @override
  String get adminCouldNotUpdateLesson => 'Could not update lesson.';

  @override
  String get adminCouldNotDeleteLesson => 'Could not delete lesson.';

  @override
  String get adminCouldNotMoveLesson => 'Could not move lesson.';

  @override
  String get adminCouldNotReorderLesson => 'Could not reorder lesson.';

  @override
  String get adminAddModuleTitle => 'Add Module';

  @override
  String get adminRenameModuleTitle => 'Rename Module';

  @override
  String adminAddLessonToTitle(String module) {
    return 'Add Lesson to \"$module\"';
  }

  @override
  String adminEditLessonTitle(String lesson) {
    return 'Edit \"$lesson\"';
  }

  @override
  String get adminFieldTitle => 'Title';

  @override
  String get adminFieldDescription => 'Description';

  @override
  String get adminFieldFrenchTitle => 'French Title';

  @override
  String get adminFieldFrenchDescription => 'French Description';

  @override
  String get adminFieldSummary => 'Summary';

  @override
  String get adminFieldContent => 'Content';

  @override
  String get adminFieldFrenchSummary => 'French Summary';

  @override
  String get adminFieldFrenchContent => 'French Content';

  @override
  String get adminCreateCourseTitle => 'Create Course';

  @override
  String get adminEditCourseTitle => 'Edit Course';

  @override
  String adminBuildNewCourseSubtitle(String language) {
    return 'Build a new course for $language.';
  }

  @override
  String get adminThisLanguageFallback => 'This language';

  @override
  String get adminBackButton => 'Back';

  @override
  String get adminSavingLabel => 'Saving...';

  @override
  String get adminCreateAndContinueButton => 'Create & Continue';

  @override
  String get adminNextButton => 'Next';

  @override
  String get adminCourseCoverTitle => 'Course Cover';

  @override
  String get adminUploadCoverButton => 'Upload Cover';

  @override
  String get adminUploadingLabel => 'Uploading...';

  @override
  String get adminGenerateWithAiTooltip =>
      'AI cover generation is not available yet.';

  @override
  String get adminGenerateWithAiButton => 'Generate with AI';

  @override
  String get adminPublishingSettingsTitle => 'Publishing Settings';

  @override
  String get adminVisibilityLabel => 'Visibility';

  @override
  String get adminVisibilityPublic => 'Public';

  @override
  String get adminVisibilityPrivate => 'Private';

  @override
  String get adminEnrollmentLabel => 'Enrollment';

  @override
  String get adminEnrollmentOpen => 'Open';

  @override
  String get adminEnrollmentInviteOnly => 'Invite Only';

  @override
  String get adminIssueCertificateLabel => 'Issue Certificate';

  @override
  String get adminCourseTeamTitle => 'Course Team';

  @override
  String get adminInstructorLabel => 'Instructor';

  @override
  String get adminContentReadinessTitle => 'Content Readiness';

  @override
  String get adminReadyLabel => 'Ready';

  @override
  String get adminDangerZoneTitle => 'Danger Zone';

  @override
  String get adminArchiveCourseButton => 'Archive Course';

  @override
  String get adminSubtitleOptionalLabel => 'Subtitle (optional)';

  @override
  String get adminFrenchTitleOptionalLabel => 'French Title (optional)';

  @override
  String get adminCategoryOptionalLabel => 'Category (optional)';

  @override
  String get adminFrenchDescriptionOptionalLabel =>
      'French Description (optional)';

  @override
  String get adminEstimatedHoursLabel => 'Estimated Hours';

  @override
  String get adminTagsLabel => 'Tags';

  @override
  String get adminAddTagHint => 'Add a tag and press enter';

  @override
  String get adminLearningObjectivesLabel => 'Learning Objectives';

  @override
  String get adminAddObjectiveHint => 'Add an objective and press enter';

  @override
  String get adminModulesLessonsTitle => 'Modules & Lessons';

  @override
  String get adminNoModulesYetMessage =>
      'No modules yet. Add one to start adding lessons.';

  @override
  String adminLessonsCountLabel(int count) {
    return '$count lessons';
  }

  @override
  String get adminRenameModuleTooltip => 'Rename module';

  @override
  String get adminDeleteModuleTooltip => 'Delete module';

  @override
  String get adminMenuBlockEditor => 'Block Editor';

  @override
  String get adminMenuMoveToAnotherModule => 'Move to another module';

  @override
  String get adminMenuChangePosition => 'Change position';

  @override
  String get adminMenuManageImages => 'Manage images';

  @override
  String get adminMenuManageQuiz => 'Manage quiz';

  @override
  String get adminAddLessonButton => 'Add Lesson';

  @override
  String get adminSupportLanguageCodesLabel => 'Support Language Codes';

  @override
  String get adminSupportLanguageHint => 'e.g. fr, en — press enter';

  @override
  String get adminPrerequisiteCourseLabel => 'Prerequisite Course';

  @override
  String get adminManageQuizFromBuilderMessage =>
      'Manage each lesson\'s quiz from the existing Quiz Builder.';

  @override
  String get adminAddLessonsFirstMessage =>
      'Add lessons in the Curriculum step first.';

  @override
  String get adminManageQuizButton => 'Manage Quiz';

  @override
  String adminModulesCountLabel(int count) {
    return '$count modules';
  }

  @override
  String adminHoursSuffixLabel(int hours) {
    return '${hours}h';
  }

  @override
  String get adminReadinessChecklistTitle => 'Readiness Checklist';

  @override
  String get adminChecklistCourseDetailsComplete => 'Course details complete';

  @override
  String adminChecklistLessonsReady(int ready, int total) {
    return 'Lessons ready ($ready/$total)';
  }

  @override
  String get adminChecklistAssessmentPresent => 'Assessment present';

  @override
  String adminChecklistAudioMissing(int count) {
    return 'Audio missing on $count lesson(s)';
  }

  @override
  String get adminSetPublicationDateButton => 'Set publication date';

  @override
  String get adminPublishCourseButton => 'Publish Course';

  @override
  String get adminBlockTypeText => 'Text';

  @override
  String get adminBlockTypeDialogue => 'Dialogue';

  @override
  String get adminBlockTypeAudio => 'Audio';

  @override
  String get adminBlockTypeImage => 'Image';

  @override
  String get adminBlockTypeVocabulary => 'Vocabulary';

  @override
  String get adminBlockTypeQuiz => 'Quiz';

  @override
  String get adminBlockTypePronunciation => 'Pronunciation';

  @override
  String get adminBlockTypeExercise => 'Exercise';

  @override
  String get adminBlockTypeVideo => 'Video';

  @override
  String get adminAiActionGenerateExamples => 'Generate Examples';

  @override
  String get adminAiActionCreateQuiz => 'Create Quiz';

  @override
  String get adminAiActionSimplifyContent => 'Simplify Content';

  @override
  String get adminAiActionCheckTranslations => 'Check Translations';

  @override
  String get adminCouldNotAddBlock => 'Could not add block.';

  @override
  String get adminRemoveBlockTitle => 'Remove Block';

  @override
  String get adminRemoveBlockConfirm => 'Remove this block from the lesson?';

  @override
  String get adminRemoveButton => 'Remove';

  @override
  String get adminCouldNotRemoveBlock => 'Could not remove block.';

  @override
  String get adminCouldNotReorderBlocks => 'Could not reorder blocks.';

  @override
  String get adminSubmittedForReviewMessage => 'Submitted for review.';

  @override
  String get adminCouldNotSubmitForReview => 'Could not submit for review.';

  @override
  String get adminCouldNotPostComment => 'Could not post comment.';

  @override
  String get adminNnangaNoRespondError => 'Nnanga could not respond.';

  @override
  String get adminNnangaSuggestionLabel => 'Nnanga suggestion';

  @override
  String get adminAddedAsTextBlockMessage => 'Added as a new Text block.';

  @override
  String get adminCouldNotApplySuggestion => 'Could not apply suggestion.';

  @override
  String get adminDraftQuestionsAddedMessage =>
      'Draft questions added to the quiz.';

  @override
  String get adminCouldNotApplyQuizDraft => 'Could not apply quiz draft.';

  @override
  String get adminLessonEditorTitle => 'Lesson Editor';

  @override
  String get adminSubmitForReviewButton => 'Submit for Review';

  @override
  String get adminAddBlockTitle => 'Add Block';

  @override
  String get adminNoBlocksYetMessage =>
      'No blocks yet. Add one from the palette on the left to start authoring this lesson.';

  @override
  String get adminMoveUpTooltip => 'Move up';

  @override
  String get adminMoveDownTooltip => 'Move down';

  @override
  String get adminRemoveBlockTooltip => 'Remove block';

  @override
  String get adminSaveBlockButton => 'Save Block';

  @override
  String get adminEyebrowLabelOptional => 'Eyebrow label (optional)';

  @override
  String get adminFrenchContentOptionalLabel => 'French content (optional)';

  @override
  String get adminSpeakerLabel => 'Speaker';

  @override
  String get adminLineLabel => 'Line';

  @override
  String get adminFrenchLineOptionalLabel => 'French line (optional)';

  @override
  String get adminAddTurnButton => 'Add Turn';

  @override
  String get adminAudioUrlLabel => 'Audio URL';

  @override
  String get adminUploadButton => 'Upload';

  @override
  String get adminVideoUrlLabel => 'Video URL';

  @override
  String get adminVideoNotVisibleNotice =>
      'Video is saved but not yet shown to learners — no player exists on the lesson screen yet.';

  @override
  String get adminWordLabelField => 'Word / label';

  @override
  String get adminImageUrlLabel => 'Image URL';

  @override
  String get adminCaptionOptionalLabel => 'Caption (optional)';

  @override
  String get adminSelectWordHint => 'Select a word';

  @override
  String get adminInstructionsOptionalLabel => 'Instructions (optional)';

  @override
  String get adminNoQuizYetNotice =>
      'No quiz exists for this lesson yet. Create one from the Assessment step, then save this block again.';

  @override
  String get adminLinkedToQuizMessage => 'Linked to this lesson\'s quiz.';

  @override
  String get adminExerciseNotVisibleNotice =>
      'Exercise blocks are saved but not yet rendered to learners — no interactive-exercise widget exists yet.';

  @override
  String get adminExerciseDataJsonLabel => 'Exercise data (JSON)';

  @override
  String get adminExerciseInvalidJsonError =>
      'Exercise content must be valid JSON.';

  @override
  String get adminCouldNotSaveBlock => 'Could not save block.';

  @override
  String get adminCouldNotUploadImage => 'Could not upload image.';

  @override
  String get adminCouldNotUploadAudio => 'Could not upload audio.';

  @override
  String get adminNnangaAssistantTitle => 'Nnanga AI Assistant';

  @override
  String get adminNnangaInstructionHint => 'Optional instruction for Nnanga...';

  @override
  String get adminThinkingLabel => 'Thinking...';

  @override
  String get adminAskNnangaButton => 'Ask Nnanga';

  @override
  String get adminAddDraftQuestionsButton => 'Add Draft Questions to Quiz';

  @override
  String get adminApplyAsTextBlockButton => 'Apply as New Text Block';

  @override
  String get adminContentChecklistTitle => 'Content Checklist';

  @override
  String get adminChecklistTextContent => 'Text content';

  @override
  String get adminChecklistFrenchTranslation => 'French translation';

  @override
  String get adminChecklistQuizLinked => 'Quiz linked';

  @override
  String get adminReviewCollaborationTitle => 'Review & Collaboration';

  @override
  String get adminCommentsLabel => 'Comments';

  @override
  String get adminNoCommentsYetMessage => 'No comments yet.';

  @override
  String get adminAddCommentHint => 'Add a comment...';

  @override
  String get commonNoResults => 'No results.';

  @override
  String get adminOverallLabel => 'Overall';

  @override
  String get adminNavNotifications => 'Notifications';

  @override
  String get adminNotificationsTitle => 'Notifications';

  @override
  String get adminNotificationsSubtitle =>
      'Send a broadcast to every learner or notify one person directly.';

  @override
  String get adminBroadcastCardTitle => 'Broadcast to All Learners';

  @override
  String get adminBroadcastCardDescription =>
      'This message is sent immediately to every active learner account.';

  @override
  String get adminNotifyUserCardTitle => 'Notify a Specific User';

  @override
  String get adminNotifyUserCardDescription =>
      'Search for a user below, then send them a direct notification.';

  @override
  String get adminSearchUserHint => 'Search by name or email...';

  @override
  String get adminNoUserSelectedHint => 'No user selected yet.';

  @override
  String adminNotifyRecipientLine(String name, String email) {
    return 'To: $name ($email)';
  }

  @override
  String get adminNotificationTitleHint => 'Title';

  @override
  String get adminNotificationMessageHint => 'Message';

  @override
  String get adminSendBroadcastButton => 'Send Broadcast';

  @override
  String get adminSendNotificationButton => 'Send Notification';

  @override
  String get adminBroadcastSentMessage => 'Broadcast sent to all learners.';

  @override
  String get adminCouldNotSendBroadcast => 'Could not send broadcast.';

  @override
  String get adminNotificationSentMessage => 'Notification sent.';

  @override
  String get adminCouldNotSendNotification => 'Could not send notification.';

  @override
  String get dashboardProgressTitle => 'Your Learning Progress';

  @override
  String lessonsCompletedCount(int count) {
    return '$count lessons completed';
  }

  @override
  String get exploreSectionTitle => 'Explore';

  @override
  String get nnangaPromoSubtitle =>
      'Practice Ewondo with your personal AI tutor';

  @override
  String get startPracticeButton => 'START PRACTICE';

  @override
  String get phraseOfDayTitle => 'Phrase of the Day';

  @override
  String get learnHubTitle => 'Learn Ewondo';

  @override
  String get learnHubSubtitle => 'Choose a level and continue your journey.';

  @override
  String get dailyGoalTitle => 'Daily Goal';

  @override
  String get dailyGoalSubtitle => 'Complete 1 lesson today';

  @override
  String get todaysLessonLabel => 'TODAY\'S LESSON';

  @override
  String get listenAndRepeatTitle => 'Listen and Repeat';

  @override
  String get tapSpeakerRepeatCaption =>
      'Tap the speaker, then repeat the phrase.';

  @override
  String get inConversationTitle => 'In Conversation';

  @override
  String get quickCheckTitle => 'Quick Check';

  @override
  String get voiceMessageSendError =>
      'Couldn\'t send that voice message — please try again.';

  @override
  String get practiceModeLabel => 'Practice Mode';

  @override
  String get freeConversationLabel => 'Free Conversation';

  @override
  String explainPromptPrefix(String text) {
    return 'Explain: $text';
  }

  @override
  String translatePromptPrefix(String text) {
    return 'Translate: $text';
  }

  @override
  String get explainActionLabel => 'Explain';

  @override
  String get translateActionLabel => 'Translate';

  @override
  String get correctionLabel => 'Correction';

  @override
  String get translationLabel => 'Translation';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practiceSubtitle => 'Strengthen your Ewondo skills';

  @override
  String get practiceLoadError => 'Something went wrong loading Practice.';

  @override
  String get dailyPracticeTitle => 'Daily Practice';

  @override
  String get dailyGoalReachedMessage => 'Today\'s goal reached!';

  @override
  String minutesToGoalMessage(int minutes) {
    return '$minutes minutes to reach today\'s goal';
  }

  @override
  String get minutesUnitLabel => 'min';

  @override
  String get continuePracticeButton => 'CONTINUE PRACTICE';

  @override
  String get smartReviewTitle => 'Smart Review';

  @override
  String wordsReadyForReview(int count) {
    return '$count words are ready for review';
  }

  @override
  String get noWordsDueMessage => 'No words due for review right now';

  @override
  String get reviewNowButton => 'REVIEW NOW';

  @override
  String get thisWeekTitle => 'This Week';

  @override
  String practiceDaysCount(int count) {
    return '$count practice days';
  }

  @override
  String get almostThereTitle => 'Almost there!';

  @override
  String completeSessionsForBadge(int count, String badgeName) {
    return 'Complete $count more sessions to earn the $badgeName badge.';
  }

  @override
  String get badgesTitle => 'Badges';

  @override
  String get noBadgesYetMessage => 'No badges yet.';

  @override
  String completeMoreForBadge(int remaining) {
    return 'Complete $remaining more to earn this badge';
  }

  @override
  String get tapToRevealHint => 'Tap to reveal';

  @override
  String get gradeAgainLabel => 'Again';

  @override
  String get gradeHardLabel => 'Hard';

  @override
  String get gradeGoodLabel => 'Good';

  @override
  String get gradeEasyLabel => 'Easy';

  @override
  String get bestStreakLabel => 'Best Streak';

  @override
  String get yourPronunciationTitle => 'Your Pronunciation';

  @override
  String get micPermissionRequiredError =>
      'Microphone permission is required to practice pronunciation.';

  @override
  String get recordingSubmitError =>
      'Couldn\'t submit your recording — please try again.';

  @override
  String get recordingStatusLabel => 'Recording…';

  @override
  String get scoringStatusLabel => 'Scoring…';

  @override
  String get scoredStatusLabel => 'Scored';

  @override
  String get notScoredStatusLabel => 'Not scored';

  @override
  String get readyToRecordStatusLabel => 'Ready to record';

  @override
  String get stopRecordingButton => 'STOP RECORDING';

  @override
  String get startRecordingButton => 'START RECORDING';

  @override
  String get scoringFailedFallback => 'Couldn\'t score that attempt.';
}
