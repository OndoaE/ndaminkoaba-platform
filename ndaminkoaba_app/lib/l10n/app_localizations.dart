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

  /// No description provided for @adminQuizBuilderDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Quiz'**
  String get adminQuizBuilderDefaultTitle;

  /// No description provided for @adminQuizBuilderCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create quiz.'**
  String get adminQuizBuilderCreateError;

  /// No description provided for @adminQuizBuilderEditQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Quiz'**
  String get adminQuizBuilderEditQuizTitle;

  /// No description provided for @adminQuizBuilderTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminQuizBuilderTitleLabel;

  /// No description provided for @adminQuizBuilderDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminQuizBuilderDescriptionLabel;

  /// No description provided for @adminQuizBuilderFrenchTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'French Title (optional)'**
  String get adminQuizBuilderFrenchTitleLabel;

  /// No description provided for @adminQuizBuilderFrenchDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'French Description (optional)'**
  String get adminQuizBuilderFrenchDescriptionLabel;

  /// No description provided for @adminQuizBuilderPassingScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Passing Score (%)'**
  String get adminQuizBuilderPassingScoreLabel;

  /// No description provided for @adminQuizBuilderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminQuizBuilderCancel;

  /// No description provided for @adminQuizBuilderSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminQuizBuilderSave;

  /// No description provided for @adminQuizBuilderQuizUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quiz updated.'**
  String get adminQuizBuilderQuizUpdated;

  /// No description provided for @adminQuizBuilderUpdateQuizError.
  ///
  /// In en, this message translates to:
  /// **'Could not update quiz.'**
  String get adminQuizBuilderUpdateQuizError;

  /// No description provided for @adminQuizBuilderDeleteQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Quiz'**
  String get adminQuizBuilderDeleteQuizTitle;

  /// No description provided for @adminQuizBuilderDeleteQuizConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" and all {count} question(s)? Learners will no longer be able to complete this lesson via quiz.'**
  String adminQuizBuilderDeleteQuizConfirm(String title, int count);

  /// No description provided for @adminQuizBuilderDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminQuizBuilderDelete;

  /// No description provided for @adminQuizBuilderDeleteQuizError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete quiz.'**
  String get adminQuizBuilderDeleteQuizError;

  /// No description provided for @adminQuizBuilderQuestionAdded.
  ///
  /// In en, this message translates to:
  /// **'Question added.'**
  String get adminQuizBuilderQuestionAdded;

  /// No description provided for @adminQuizBuilderAddQuestionError.
  ///
  /// In en, this message translates to:
  /// **'Could not add question.'**
  String get adminQuizBuilderAddQuestionError;

  /// No description provided for @adminQuizBuilderUnknownServerError.
  ///
  /// In en, this message translates to:
  /// **'Unknown server error.'**
  String get adminQuizBuilderUnknownServerError;

  /// No description provided for @adminQuizBuilderImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} question(s).'**
  String adminQuizBuilderImportSuccess(int count);

  /// No description provided for @adminQuizBuilderImportPartial.
  ///
  /// In en, this message translates to:
  /// **'Imported {succeeded} question(s), {failed} failed{errorSuffix}.'**
  String adminQuizBuilderImportPartial(
    int succeeded,
    int failed,
    String errorSuffix,
  );

  /// No description provided for @adminQuizBuilderQuestionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Question updated.'**
  String get adminQuizBuilderQuestionUpdated;

  /// No description provided for @adminQuizBuilderUpdateQuestionError.
  ///
  /// In en, this message translates to:
  /// **'Could not update question.'**
  String get adminQuizBuilderUpdateQuestionError;

  /// No description provided for @adminQuizBuilderDeleteQuestionError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete question.'**
  String get adminQuizBuilderDeleteQuestionError;

  /// No description provided for @adminQuizBuilderUpdateAnswerKeyError.
  ///
  /// In en, this message translates to:
  /// **'Could not update answer key.'**
  String get adminQuizBuilderUpdateAnswerKeyError;

  /// No description provided for @adminQuizBuilderAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz — {lessonTitle}'**
  String adminQuizBuilderAppBarTitle(String lessonTitle);

  /// No description provided for @adminQuizBuilderDefaultLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get adminQuizBuilderDefaultLessonTitle;

  /// No description provided for @adminQuizBuilderNoQuizYetTitle.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no quiz yet'**
  String get adminQuizBuilderNoQuizYetTitle;

  /// No description provided for @adminQuizBuilderNoQuizYetDescription.
  ///
  /// In en, this message translates to:
  /// **'Create one so learners can complete this lesson by passing it.'**
  String get adminQuizBuilderNoQuizYetDescription;

  /// No description provided for @adminQuizBuilderQuizTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiz Title'**
  String get adminQuizBuilderQuizTitleLabel;

  /// No description provided for @adminQuizBuilderCreateQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get adminQuizBuilderCreateQuizButton;

  /// No description provided for @adminQuizBuilderPassMarkSummary.
  ///
  /// In en, this message translates to:
  /// **'Pass mark: {score}% • {count} questions'**
  String adminQuizBuilderPassMarkSummary(int score, int count);

  /// No description provided for @adminQuizBuilderEditQuizInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit quiz info'**
  String get adminQuizBuilderEditQuizInfoTooltip;

  /// No description provided for @adminQuizBuilderDeleteQuizTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete quiz'**
  String get adminQuizBuilderDeleteQuizTooltip;

  /// No description provided for @adminQuizBuilderQuestionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get adminQuizBuilderQuestionsHeading;

  /// No description provided for @adminQuizBuilderPasteQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Paste Quiz'**
  String get adminQuizBuilderPasteQuizButton;

  /// No description provided for @adminQuizBuilderAddQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get adminQuizBuilderAddQuestionButton;

  /// No description provided for @adminQuizBuilderNoQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions yet. A quiz needs at least one question before a learner can take it.'**
  String get adminQuizBuilderNoQuestionsYet;

  /// No description provided for @adminQuizBuilderPasteQuizHint.
  ///
  /// In en, this message translates to:
  /// **'Already have a quiz written elsewhere? Use \"Paste Quiz\" above to copy and paste it in and have the questions and choices created for you.'**
  String get adminQuizBuilderPasteQuizHint;

  /// No description provided for @adminQuizBuilderEditQuestionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit question'**
  String get adminQuizBuilderEditQuestionTooltip;

  /// No description provided for @adminQuizBuilderDeleteQuestionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete question'**
  String get adminQuizBuilderDeleteQuestionTooltip;

  /// No description provided for @adminQuizBuilderNoCorrectAnswerSet.
  ///
  /// In en, this message translates to:
  /// **'No correct answer set — tap a choice above to mark it.'**
  String get adminQuizBuilderNoCorrectAnswerSet;

  /// No description provided for @adminQuizBuilderQuestionTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Question text must be at least 5 characters.'**
  String get adminQuizBuilderQuestionTooShortError;

  /// No description provided for @adminQuizBuilderTooFewChoicesError.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 answer choices.'**
  String get adminQuizBuilderTooFewChoicesError;

  /// No description provided for @adminQuizBuilderEditQuestionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get adminQuizBuilderEditQuestionDialogTitle;

  /// No description provided for @adminQuizBuilderQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get adminQuizBuilderQuestionLabel;

  /// No description provided for @adminQuizBuilderExplanationLabel.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get adminQuizBuilderExplanationLabel;

  /// No description provided for @adminQuizBuilderFrenchQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'French Question (optional)'**
  String get adminQuizBuilderFrenchQuestionLabel;

  /// No description provided for @adminQuizBuilderFrenchExplanationLabel.
  ///
  /// In en, this message translates to:
  /// **'French Explanation (optional)'**
  String get adminQuizBuilderFrenchExplanationLabel;

  /// No description provided for @adminQuizBuilderChoicesHelper.
  ///
  /// In en, this message translates to:
  /// **'Choices — select the correct one'**
  String get adminQuizBuilderChoicesHelper;

  /// No description provided for @adminQuizBuilderChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Choice {number}'**
  String adminQuizBuilderChoiceHint(int number);

  /// No description provided for @adminQuizBuilderFrenchOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'French (optional)'**
  String get adminQuizBuilderFrenchOptionalHint;

  /// No description provided for @adminQuizBuilderAddAnotherChoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Add another choice'**
  String get adminQuizBuilderAddAnotherChoiceButton;

  /// No description provided for @adminQuizBuilderPreviewImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview Import'**
  String get adminQuizBuilderPreviewImportTitle;

  /// No description provided for @adminQuizBuilderParseButton.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get adminQuizBuilderParseButton;

  /// No description provided for @adminQuizBuilderBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get adminQuizBuilderBackButton;

  /// No description provided for @adminQuizBuilderImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import {count} Question(s)'**
  String adminQuizBuilderImportButton(int count);

  /// No description provided for @adminQuizBuilderPasteInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste one or more questions, with a blank line between each question.'**
  String get adminQuizBuilderPasteInstructions;

  /// No description provided for @adminQuizBuilderPasteExample.
  ///
  /// In en, this message translates to:
  /// **'1. What is the Ewondo word for \"water\"?\nA) Mendim *\nB) Ayong\nC) Nti\nExplanation: Mendim means water.\n\n2. Next question...\nA) Choice one\nB) Choice two\nAnswer: B'**
  String get adminQuizBuilderPasteExample;

  /// No description provided for @adminQuizBuilderPasteFormatHelp.
  ///
  /// In en, this message translates to:
  /// **'Mark the correct choice with a trailing * or add an \"Answer: B\" / \"Réponse : B\" line. Add \"FR: ...\" on its own line right after a question or choice for the French translation. Numbered questions with all the answers listed separately at the bottom under a heading \"Answer Key\" (e.g. \"7. B) Parents\") also work.'**
  String get adminQuizBuilderPasteFormatHelp;

  /// No description provided for @adminQuizBuilderPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your quiz text here…'**
  String get adminQuizBuilderPasteHint;

  /// No description provided for @adminQuizBuilderDetectedCount.
  ///
  /// In en, this message translates to:
  /// **'{total} question(s) detected — {valid} ready to import.'**
  String adminQuizBuilderDetectedCount(int total, int valid);

  /// No description provided for @adminQuizBuilderNothingToPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview — go back and adjust the pasted text.'**
  String get adminQuizBuilderNothingToPreview;

  /// No description provided for @adminQuizMgmtEditQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Quiz'**
  String get adminQuizMgmtEditQuizTitle;

  /// No description provided for @adminQuizMgmtTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminQuizMgmtTitleLabel;

  /// No description provided for @adminQuizMgmtDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminQuizMgmtDescriptionLabel;

  /// No description provided for @adminQuizMgmtFrenchTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'French Title (optional)'**
  String get adminQuizMgmtFrenchTitleLabel;

  /// No description provided for @adminQuizMgmtFrenchDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'French Description (optional)'**
  String get adminQuizMgmtFrenchDescriptionLabel;

  /// No description provided for @adminQuizMgmtPassingScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Passing Score (%)'**
  String get adminQuizMgmtPassingScoreLabel;

  /// No description provided for @adminQuizMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminQuizMgmtCancel;

  /// No description provided for @adminQuizMgmtSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminQuizMgmtSave;

  /// No description provided for @adminQuizMgmtQuizUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quiz updated.'**
  String get adminQuizMgmtQuizUpdated;

  /// No description provided for @adminQuizMgmtUpdateQuizError.
  ///
  /// In en, this message translates to:
  /// **'Could not update quiz.'**
  String get adminQuizMgmtUpdateQuizError;

  /// No description provided for @adminQuizMgmtDeleteQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Quiz'**
  String get adminQuizMgmtDeleteQuizTitle;

  /// No description provided for @adminQuizMgmtDeleteQuizConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" and all {count} question(s)? This cannot be undone.'**
  String adminQuizMgmtDeleteQuizConfirm(String title, int count);

  /// No description provided for @adminQuizMgmtDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminQuizMgmtDelete;

  /// No description provided for @adminQuizMgmtQuizDeleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz deleted.'**
  String get adminQuizMgmtQuizDeleted;

  /// No description provided for @adminQuizMgmtDeleteQuizError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete quiz.'**
  String get adminQuizMgmtDeleteQuizError;

  /// No description provided for @adminQuizMgmtAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Management'**
  String get adminQuizMgmtAppBarTitle;

  /// No description provided for @adminQuizMgmtNewQuizButton.
  ///
  /// In en, this message translates to:
  /// **'New Quiz'**
  String get adminQuizMgmtNewQuizButton;

  /// No description provided for @adminQuizMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search quizzes...'**
  String get adminQuizMgmtSearchHint;

  /// No description provided for @adminQuizMgmtAllCoursesFilter.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get adminQuizMgmtAllCoursesFilter;

  /// No description provided for @adminQuizMgmtNoQuizzesFound.
  ///
  /// In en, this message translates to:
  /// **'No quizzes found.'**
  String get adminQuizMgmtNoQuizzesFound;

  /// No description provided for @adminQuizMgmtQuestionsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} questions • pass {passingScore}%'**
  String adminQuizMgmtQuestionsSummary(int count, int passingScore);

  /// No description provided for @adminBibleChapterDefaultVersion.
  ///
  /// In en, this message translates to:
  /// **'ESV'**
  String get adminBibleChapterDefaultVersion;

  /// No description provided for @adminBibleChapterFileReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get adminBibleChapterFileReadError;

  /// No description provided for @adminBibleChapterFileLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded {fileName}.'**
  String adminBibleChapterFileLoaded(String fileName);

  /// No description provided for @adminBibleChapterInvalidChapterError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid chapter number.'**
  String get adminBibleChapterInvalidChapterError;

  /// No description provided for @adminBibleChapterNoVersesFoundError.
  ///
  /// In en, this message translates to:
  /// **'No numbered verses found. Paste one verse per line, each starting with its verse number.'**
  String get adminBibleChapterNoVersesFoundError;

  /// No description provided for @adminBibleChapterNoUsfmMarkersError.
  ///
  /// In en, this message translates to:
  /// **'Could not find any \\v verse markers. Make sure you pasted valid USFM text (e.g. \"\\c 1 \\v 1 In the beginning...\").'**
  String get adminBibleChapterNoUsfmMarkersError;

  /// No description provided for @adminBibleChapterEnterBookNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter a book name.'**
  String get adminBibleChapterEnterBookNameError;

  /// No description provided for @adminBibleChapterNoEwondoVersesError.
  ///
  /// In en, this message translates to:
  /// **'No verses with Ewondo text to save — preview the comparison first.'**
  String get adminBibleChapterNoEwondoVersesError;

  /// No description provided for @adminBibleChapterSavedMultiChapters.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} verse(s) across {chapterCount} chapters of {book}.'**
  String adminBibleChapterSavedMultiChapters(
    int count,
    int chapterCount,
    String book,
  );

  /// No description provided for @adminBibleChapterSavedSingleChapter.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} verse(s) for {book}.'**
  String adminBibleChapterSavedSingleChapter(int count, String book);

  /// No description provided for @adminBibleChapterSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save chapter.'**
  String get adminBibleChapterSaveError;

  /// No description provided for @adminBibleChapterDeleteChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Chapter'**
  String get adminBibleChapterDeleteChapterTitle;

  /// No description provided for @adminBibleChapterDeleteChapterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all {count} verse(s) of {book} {chapter} ({version})?'**
  String adminBibleChapterDeleteChapterConfirm(
    int count,
    String book,
    int chapter,
    String version,
  );

  /// No description provided for @adminBibleChapterCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminBibleChapterCancel;

  /// No description provided for @adminBibleChapterDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminBibleChapterDelete;

  /// No description provided for @adminBibleChapterDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete chapter.'**
  String get adminBibleChapterDeleteError;

  /// No description provided for @adminBibleChapterUploadFileButton.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get adminBibleChapterUploadFileButton;

  /// No description provided for @adminBibleChapterChapterHeading.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter}'**
  String adminBibleChapterChapterHeading(int chapter);

  /// No description provided for @adminBibleChapterVerseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String adminBibleChapterVerseCount(int count);

  /// No description provided for @adminBibleChapterMissingEwondoText.
  ///
  /// In en, this message translates to:
  /// **'Missing Ewondo text'**
  String get adminBibleChapterMissingEwondoText;

  /// No description provided for @adminBibleChapterMissingEnglishText.
  ///
  /// In en, this message translates to:
  /// **'Missing English text'**
  String get adminBibleChapterMissingEnglishText;

  /// No description provided for @adminBibleChapterMissingFrenchText.
  ///
  /// In en, this message translates to:
  /// **'Missing French text'**
  String get adminBibleChapterMissingFrenchText;

  /// No description provided for @adminBibleChapterDefaultLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get adminBibleChapterDefaultLanguageName;

  /// No description provided for @adminBibleChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Management'**
  String get adminBibleChapterTitle;

  /// No description provided for @adminBibleChapterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bible chapters and verses for {title}'**
  String adminBibleChapterSubtitle(String title);

  /// No description provided for @adminBibleChapterUsfmModeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Upload (or paste) an entire book\'s USFM in Ewondo alongside its English (ESV) USFM. Chapters and verses are detected automatically from the \\c and \\v markers and matched verse by verse.'**
  String get adminBibleChapterUsfmModeInstructions;

  /// No description provided for @adminBibleChapterManualModeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste a full chapter in Ewondo (New Testament) alongside its English (ESV) translation. Each is matched verse by verse so Nnanga learns accurate, side-by-side translations.'**
  String get adminBibleChapterManualModeInstructions;

  /// No description provided for @adminBibleChapterSingleChapterOption.
  ///
  /// In en, this message translates to:
  /// **'Single Chapter'**
  String get adminBibleChapterSingleChapterOption;

  /// No description provided for @adminBibleChapterUsfmWholeBookOption.
  ///
  /// In en, this message translates to:
  /// **'USFM (Whole Book)'**
  String get adminBibleChapterUsfmWholeBookOption;

  /// No description provided for @adminBibleChapterBookDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Details'**
  String get adminBibleChapterBookDetailsTitle;

  /// No description provided for @adminBibleChapterChapterDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter Details'**
  String get adminBibleChapterChapterDetailsTitle;

  /// No description provided for @adminBibleChapterAutoFilledHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled from the USFM \\h/\\mt1 title once previewed — edit if needed.'**
  String get adminBibleChapterAutoFilledHint;

  /// No description provided for @adminBibleChapterBookLabel.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get adminBibleChapterBookLabel;

  /// No description provided for @adminBibleChapterChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get adminBibleChapterChapterLabel;

  /// No description provided for @adminBibleChapterVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get adminBibleChapterVersionLabel;

  /// No description provided for @adminBibleChapterEwondoUsfmLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo USFM (entire book)'**
  String get adminBibleChapterEwondoUsfmLabel;

  /// No description provided for @adminBibleChapterEwondoChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo Chapter Text'**
  String get adminBibleChapterEwondoChapterLabel;

  /// No description provided for @adminBibleChapterUploadOrPasteHelper.
  ///
  /// In en, this message translates to:
  /// **'Upload a .usfm/.sfm/.txt file, or paste the text directly.'**
  String get adminBibleChapterUploadOrPasteHelper;

  /// No description provided for @adminBibleChapterOneVersePerLineHelper.
  ///
  /// In en, this message translates to:
  /// **'One verse per line, each starting with its verse number.'**
  String get adminBibleChapterOneVersePerLineHelper;

  /// No description provided for @adminBibleChapterEwondoUsfmHintExample.
  ///
  /// In en, this message translates to:
  /// **'\\id JHN\n\\h John\n\\c 1\n\\v 1 Kiki avele, Nkobo a nga bo...\n\\v 2 ...'**
  String get adminBibleChapterEwondoUsfmHintExample;

  /// No description provided for @adminBibleChapterManualHintExample.
  ///
  /// In en, this message translates to:
  /// **'1 In the beginning was the Word...\n2 He was in the beginning with God...'**
  String get adminBibleChapterManualHintExample;

  /// No description provided for @adminBibleChapterEnglishUsfmLabel.
  ///
  /// In en, this message translates to:
  /// **'English USFM (entire book, ESV)'**
  String get adminBibleChapterEnglishUsfmLabel;

  /// No description provided for @adminBibleChapterEnglishChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'English Chapter Text (ESV)'**
  String get adminBibleChapterEnglishChapterLabel;

  /// No description provided for @adminBibleChapterEnglishUsfmHintExample.
  ///
  /// In en, this message translates to:
  /// **'\\id JHN\n\\h John\n\\c 1\n\\v 1 In the beginning was the Word...\n\\v 2 ...'**
  String get adminBibleChapterEnglishUsfmHintExample;

  /// No description provided for @adminBibleChapterFrenchUsfmLabel.
  ///
  /// In en, this message translates to:
  /// **'French USFM (entire book, optional)'**
  String get adminBibleChapterFrenchUsfmLabel;

  /// No description provided for @adminBibleChapterFrenchChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'French Chapter Text (optional)'**
  String get adminBibleChapterFrenchChapterLabel;

  /// No description provided for @adminBibleChapterFrenchUsfmHintExample.
  ///
  /// In en, this message translates to:
  /// **'\\id JHN\n\\h Jean\n\\c 1\n\\v 1 Au commencement était la Parole...\n\\v 2 ...'**
  String get adminBibleChapterFrenchUsfmHintExample;

  /// No description provided for @adminBibleChapterFrenchManualHintExample.
  ///
  /// In en, this message translates to:
  /// **'1 Au commencement était la Parole...\n2 Elle était au commencement avec Dieu...'**
  String get adminBibleChapterFrenchManualHintExample;

  /// No description provided for @adminBibleChapterPreviewButton.
  ///
  /// In en, this message translates to:
  /// **'Preview Verse-by-Verse Comparison'**
  String get adminBibleChapterPreviewButton;

  /// No description provided for @adminBibleChapterComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Verse-by-Verse Comparison'**
  String get adminBibleChapterComparisonTitle;

  /// No description provided for @adminBibleChapterVersesAcrossChapters.
  ///
  /// In en, this message translates to:
  /// **'{verseCount} verses across {chapterCount} chapter(s)'**
  String adminBibleChapterVersesAcrossChapters(
    int verseCount,
    int chapterCount,
  );

  /// No description provided for @adminBibleChapterSaveBookButton.
  ///
  /// In en, this message translates to:
  /// **'Save Book'**
  String get adminBibleChapterSaveBookButton;

  /// No description provided for @adminBibleChapterSaveChapterButton.
  ///
  /// In en, this message translates to:
  /// **'Save Chapter'**
  String get adminBibleChapterSaveChapterButton;

  /// No description provided for @adminBibleChapterSavedChaptersHeading.
  ///
  /// In en, this message translates to:
  /// **'Saved Chapters'**
  String get adminBibleChapterSavedChaptersHeading;

  /// No description provided for @adminBibleChapterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No chapters yet'**
  String get adminBibleChapterEmptyTitle;

  /// No description provided for @adminBibleChapterEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Paste and save a chapter above to see it here.'**
  String get adminBibleChapterEmptyMessage;

  /// No description provided for @adminBibleChapterDeleteChapterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete chapter'**
  String get adminBibleChapterDeleteChapterTooltip;

  /// No description provided for @adminBibleChapterOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing chapters?'**
  String get adminBibleChapterOverwriteTitle;

  /// No description provided for @adminBibleChapterOverwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count} of these chapters are already saved for \"{book}\". Saving now will replace their existing verses with the ones you\'re uploading.'**
  String adminBibleChapterOverwriteConfirm(int count, String book);

  /// No description provided for @adminBibleChapterOverwriteButton.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get adminBibleChapterOverwriteButton;

  /// No description provided for @adminBibleChapterFilesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) loaded.'**
  String adminBibleChapterFilesLoaded(int count);

  /// No description provided for @adminBibleChapterFilesLoadedWithErrors.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) loaded, {unreadable} couldn\'t be read.'**
  String adminBibleChapterFilesLoadedWithErrors(int count, int unreadable);

  /// No description provided for @adminBibleChapterPastedTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Pasted text'**
  String get adminBibleChapterPastedTextLabel;

  /// No description provided for @adminBibleChapterOverwriteConfirmMulti.
  ///
  /// In en, this message translates to:
  /// **'{count} of these {total} book(s) have chapters that already exist. Saving now will replace their existing verses with the ones you\'re uploading.'**
  String adminBibleChapterOverwriteConfirmMulti(int count, int total);

  /// No description provided for @adminBibleChapterSavedBooks.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} book(s).'**
  String adminBibleChapterSavedBooks(int count);

  /// No description provided for @adminBibleChapterSavedBooksWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Saved {succeeded} book(s), {failed} failed{errorSuffix}.'**
  String adminBibleChapterSavedBooksWithFailures(
    int succeeded,
    int failed,
    String errorSuffix,
  );

  /// No description provided for @adminBibleChapterBooksDetectedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} book(s) detected — review each below, then save.'**
  String adminBibleChapterBooksDetectedSummary(int count);

  /// No description provided for @adminBibleChapterSaveAllBooksButton.
  ///
  /// In en, this message translates to:
  /// **'Save All Books ({count})'**
  String adminBibleChapterSaveAllBooksButton(int count);

  /// No description provided for @adminLessonEditorTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Lesson Info'**
  String get adminLessonEditorTabInfo;

  /// No description provided for @adminLessonEditorTabContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminLessonEditorTabContent;

  /// No description provided for @adminLessonEditorTabActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get adminLessonEditorTabActivities;

  /// No description provided for @adminLessonEditorTabQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get adminLessonEditorTabQuiz;

  /// No description provided for @adminLessonEditorTabResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get adminLessonEditorTabResources;

  /// No description provided for @adminLessonEditorTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminLessonEditorTabSettings;

  /// No description provided for @adminLessonEditorSavedInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson info saved.'**
  String get adminLessonEditorSavedInfoMessage;

  /// No description provided for @adminLessonEditorCouldNotSaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Could not save lesson info.'**
  String get adminLessonEditorCouldNotSaveInfo;

  /// No description provided for @adminLessonEditorDraftSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get adminLessonEditorDraftSavedMessage;

  /// No description provided for @adminLessonEditorCouldNotSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Could not save draft.'**
  String get adminLessonEditorCouldNotSaveDraft;

  /// No description provided for @adminLessonEditorPublishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson published.'**
  String get adminLessonEditorPublishedMessage;

  /// No description provided for @adminLessonEditorCouldNotPublish.
  ///
  /// In en, this message translates to:
  /// **'Could not publish lesson.'**
  String get adminLessonEditorCouldNotPublish;

  /// No description provided for @adminLessonEditorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Lesson'**
  String get adminLessonEditorAppBarTitle;

  /// No description provided for @adminLessonEditorPreviewLearnerViewButton.
  ///
  /// In en, this message translates to:
  /// **'Preview (Learner View)'**
  String get adminLessonEditorPreviewLearnerViewButton;

  /// No description provided for @adminLessonEditorSaveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get adminLessonEditorSaveDraftButton;

  /// No description provided for @adminLessonEditorPublishingLabel.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get adminLessonEditorPublishingLabel;

  /// No description provided for @adminLessonEditorPublishLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Publish Lesson'**
  String get adminLessonEditorPublishLessonButton;

  /// No description provided for @adminLessonEditorLessonInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Information'**
  String get adminLessonEditorLessonInfoSectionTitle;

  /// No description provided for @adminLessonEditorLessonTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson Title'**
  String get adminLessonEditorLessonTitleLabel;

  /// No description provided for @adminLessonEditorShortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get adminLessonEditorShortDescriptionLabel;

  /// No description provided for @adminLessonEditorLessonCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson Category'**
  String get adminLessonEditorLessonCategoryLabel;

  /// No description provided for @adminLessonEditorLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get adminLessonEditorLevelLabel;

  /// No description provided for @adminLessonEditorEstimatedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time (min)'**
  String get adminLessonEditorEstimatedTimeLabel;

  /// No description provided for @adminLessonEditorOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get adminLessonEditorOrderLabel;

  /// No description provided for @adminLessonEditorCoverImageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Cover / Image'**
  String get adminLessonEditorCoverImageSectionTitle;

  /// No description provided for @adminLessonEditorCoverImageHint.
  ///
  /// In en, this message translates to:
  /// **'This image will appear on the learner view.'**
  String get adminLessonEditorCoverImageHint;

  /// No description provided for @adminLessonEditorChangeImageButton.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get adminLessonEditorChangeImageButton;

  /// No description provided for @adminLessonEditorRemoveImageButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get adminLessonEditorRemoveImageButton;

  /// No description provided for @adminLessonEditorLearningObjectivesLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning Objectives (one per line)'**
  String get adminLessonEditorLearningObjectivesLabel;

  /// No description provided for @adminLessonEditorOutcomesLabel.
  ///
  /// In en, this message translates to:
  /// **'What Learners Will Learn (one per line)'**
  String get adminLessonEditorOutcomesLabel;

  /// No description provided for @adminLessonEditorNoActivitiesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No activities yet.'**
  String get adminLessonEditorNoActivitiesYetMessage;

  /// No description provided for @adminLessonEditorNoQuizYetMessage.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no quiz yet.'**
  String get adminLessonEditorNoQuizYetMessage;

  /// No description provided for @adminLessonEditorHasQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'This lesson has a quiz linked to it.'**
  String get adminLessonEditorHasQuizMessage;

  /// No description provided for @adminLessonEditorResourcesDescription.
  ///
  /// In en, this message translates to:
  /// **'Illustrated word images attached to this lesson. Add or remove per-word images from the dedicated Images screen.'**
  String get adminLessonEditorResourcesDescription;

  /// No description provided for @adminLessonEditorManageLessonImagesButton.
  ///
  /// In en, this message translates to:
  /// **'Manage Lesson Images'**
  String get adminLessonEditorManageLessonImagesButton;

  /// No description provided for @adminLessonEditorSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reviewer assignment and comments are in the panel on the right.'**
  String get adminLessonEditorSettingsDescription;

  /// No description provided for @adminLessonEditorLessonSummaryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Summary'**
  String get adminLessonEditorLessonSummaryCardTitle;

  /// No description provided for @adminLessonEditorLessonIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson ID'**
  String get adminLessonEditorLessonIdLabel;

  /// No description provided for @adminLessonEditorCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get adminLessonEditorCreatedLabel;

  /// No description provided for @adminLessonEditorLastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get adminLessonEditorLastUpdatedLabel;

  /// No description provided for @adminLessonEditorImagePreviewCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Image Preview (Learner View)'**
  String get adminLessonEditorImagePreviewCardTitle;

  /// No description provided for @adminLessonEditorTipsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get adminLessonEditorTipsCardTitle;

  /// No description provided for @adminLessonEditorTip1.
  ///
  /// In en, this message translates to:
  /// **'Use high quality images (1280x720 recommended)'**
  String get adminLessonEditorTip1;

  /// No description provided for @adminLessonEditorTip2.
  ///
  /// In en, this message translates to:
  /// **'Images make lessons more engaging'**
  String get adminLessonEditorTip2;

  /// No description provided for @adminLessonEditorTip3.
  ///
  /// In en, this message translates to:
  /// **'You can add multiple images in the content'**
  String get adminLessonEditorTip3;

  /// No description provided for @adminLessonEditorTip4.
  ///
  /// In en, this message translates to:
  /// **'Keep lessons focused and interactive'**
  String get adminLessonEditorTip4;

  /// No description provided for @adminLessonEditorUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get adminLessonEditorUrlHint;

  /// No description provided for @adminLessonEditorInsertButton.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get adminLessonEditorInsertButton;

  /// No description provided for @adminLessonEditorEmbedUrlDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Embed URL'**
  String get adminLessonEditorEmbedUrlDialogTitle;

  /// No description provided for @adminLessonMgmtFrenchSummaryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French Summary (optional)'**
  String get adminLessonMgmtFrenchSummaryOptionalLabel;

  /// No description provided for @adminLessonMgmtFrenchContentOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French Content (optional)'**
  String get adminLessonMgmtFrenchContentOptionalLabel;

  /// No description provided for @adminLessonMgmtConversationHelpText.
  ///
  /// In en, this message translates to:
  /// **'In Conversation (optional) — one line per turn: \"Speaker: Text || French text\"'**
  String get adminLessonMgmtConversationHelpText;

  /// No description provided for @adminLessonMgmtConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get adminLessonMgmtConversationLabel;

  /// No description provided for @adminLessonMgmtConversationHint.
  ///
  /// In en, this message translates to:
  /// **'Amina: Mbolo, wa nga zu na? || Bonjour, comment vas-tu ?'**
  String get adminLessonMgmtConversationHint;

  /// No description provided for @adminLessonMgmtDeleteLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Lesson'**
  String get adminLessonMgmtDeleteLessonTitle;

  /// No description provided for @adminLessonMgmtDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String adminLessonMgmtDeleteConfirm(String title);

  /// No description provided for @adminLessonMgmtDeleteConfirmWithQuiz.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? Its quiz must be deleted first (from Quiz Management).'**
  String adminLessonMgmtDeleteConfirmWithQuiz(String title);

  /// No description provided for @adminLessonMgmtUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson updated.'**
  String get adminLessonMgmtUpdatedMessage;

  /// No description provided for @adminLessonMgmtMovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson moved.'**
  String get adminLessonMgmtMovedMessage;

  /// No description provided for @adminLessonMgmtReorderedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson reordered.'**
  String get adminLessonMgmtReorderedMessage;

  /// No description provided for @adminLessonMgmtDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lesson deleted.'**
  String get adminLessonMgmtDeletedMessage;

  /// No description provided for @adminLessonMgmtAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Management'**
  String get adminLessonMgmtAppBarTitle;

  /// No description provided for @adminLessonMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lessons...'**
  String get adminLessonMgmtSearchHint;

  /// No description provided for @adminLessonMgmtAllCoursesFilter.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get adminLessonMgmtAllCoursesFilter;

  /// No description provided for @adminLessonMgmtNoLessonsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No lessons found.'**
  String get adminLessonMgmtNoLessonsFoundMessage;

  /// No description provided for @adminLessonMgmtLessonRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}: {title}'**
  String adminLessonMgmtLessonRowTitle(int number, String title);

  /// No description provided for @moveLessonDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Move Lesson'**
  String get moveLessonDialogTitle;

  /// No description provided for @moveLessonDialogDestinationCourseLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination course'**
  String get moveLessonDialogDestinationCourseLabel;

  /// No description provided for @moveLessonDialogDestinationModuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination module'**
  String get moveLessonDialogDestinationModuleLabel;

  /// No description provided for @moveLessonDialogAlreadyInModuleMessage.
  ///
  /// In en, this message translates to:
  /// **'This lesson is already in that module.'**
  String get moveLessonDialogAlreadyInModuleMessage;

  /// No description provided for @moveLessonDialogMoveButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveLessonDialogMoveButton;

  /// No description provided for @reorderLessonDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Lesson Position'**
  String get reorderLessonDialogTitle;

  /// No description provided for @reorderLessonDialogNewPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'New position (currently Lesson {currentPosition})'**
  String reorderLessonDialogNewPositionLabel(int currentPosition);

  /// No description provided for @reorderLessonDialogMoveButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get reorderLessonDialogMoveButton;

  /// No description provided for @adminUsersCouldNotUpdateUser.
  ///
  /// In en, this message translates to:
  /// **'Could not update user.'**
  String get adminUsersCouldNotUpdateUser;

  /// No description provided for @adminUsersCouldNotUpdateRole.
  ///
  /// In en, this message translates to:
  /// **'Could not update role.'**
  String get adminUsersCouldNotUpdateRole;

  /// No description provided for @adminUsersDeleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminUsersDeleteUserTitle;

  /// No description provided for @adminUsersDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete {name}? This cannot be undone. Users with existing courses, progress, or other linked records cannot be deleted — deactivate them instead.'**
  String adminUsersDeleteConfirm(String name);

  /// No description provided for @adminUsersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminUsersCancel;

  /// No description provided for @adminUsersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminUsersDelete;

  /// No description provided for @adminUsersCouldNotDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Could not delete user.'**
  String get adminUsersCouldNotDeleteUser;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String adminUsersSubtitle(int count);

  /// No description provided for @adminUsersNewUser.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get adminUsersNewUser;

  /// No description provided for @adminUsersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get adminUsersSearchHint;

  /// No description provided for @adminUsersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminUsersActive;

  /// No description provided for @adminUsersDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get adminUsersDeactivated;

  /// No description provided for @adminUsersDeactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminUsersDeactivateAction;

  /// No description provided for @adminUsersActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminUsersActivateAction;

  /// No description provided for @adminUsersMakeAdminAction.
  ///
  /// In en, this message translates to:
  /// **'Make Administrator'**
  String get adminUsersMakeAdminAction;

  /// No description provided for @adminUsersMakeTeacherAction.
  ///
  /// In en, this message translates to:
  /// **'Make Teacher'**
  String get adminUsersMakeTeacherAction;

  /// No description provided for @adminUsersMakeLearnerAction.
  ///
  /// In en, this message translates to:
  /// **'Make Learner'**
  String get adminUsersMakeLearnerAction;

  /// No description provided for @adminUsersThisIsYourAccount.
  ///
  /// In en, this message translates to:
  /// **'This is your account'**
  String get adminUsersThisIsYourAccount;

  /// No description provided for @adminVocabMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Management'**
  String get adminVocabMgmtTitle;

  /// No description provided for @adminVocabMgmtCouldNotDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Could not delete word.'**
  String get adminVocabMgmtCouldNotDeleteWord;

  /// No description provided for @adminVocabMgmtWordAdded.
  ///
  /// In en, this message translates to:
  /// **'Knowledge entry added.'**
  String get adminVocabMgmtWordAdded;

  /// No description provided for @adminVocabMgmtCouldNotAddWord.
  ///
  /// In en, this message translates to:
  /// **'Could not add word.'**
  String get adminVocabMgmtCouldNotAddWord;

  /// No description provided for @adminVocabMgmtUnknownServerError.
  ///
  /// In en, this message translates to:
  /// **'Unknown server error.'**
  String get adminVocabMgmtUnknownServerError;

  /// No description provided for @adminVocabMgmtImportedWords.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} word(s).'**
  String adminVocabMgmtImportedWords(int count);

  /// No description provided for @adminVocabMgmtImportedWordsWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Imported {succeeded} word(s), {failed} failed'**
  String adminVocabMgmtImportedWordsWithFailures(int succeeded, int failed);

  /// No description provided for @adminVocabMgmtWordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Knowledge entry updated.'**
  String get adminVocabMgmtWordUpdated;

  /// No description provided for @adminVocabMgmtCouldNotUpdateWord.
  ///
  /// In en, this message translates to:
  /// **'Could not update word.'**
  String get adminVocabMgmtCouldNotUpdateWord;

  /// No description provided for @adminVocabMgmtCouldNotDeleteText.
  ///
  /// In en, this message translates to:
  /// **'Could not delete text.'**
  String get adminVocabMgmtCouldNotDeleteText;

  /// No description provided for @adminVocabMgmtTextAdded.
  ///
  /// In en, this message translates to:
  /// **'Text & translation added.'**
  String get adminVocabMgmtTextAdded;

  /// No description provided for @adminVocabMgmtCouldNotAddText.
  ///
  /// In en, this message translates to:
  /// **'Could not add text.'**
  String get adminVocabMgmtCouldNotAddText;

  /// No description provided for @adminVocabMgmtTextUpdated.
  ///
  /// In en, this message translates to:
  /// **'Text & translation updated.'**
  String get adminVocabMgmtTextUpdated;

  /// No description provided for @adminVocabMgmtCouldNotUpdateText.
  ///
  /// In en, this message translates to:
  /// **'Could not update text.'**
  String get adminVocabMgmtCouldNotUpdateText;

  /// No description provided for @adminVocabMgmtAddTextAction.
  ///
  /// In en, this message translates to:
  /// **'Add Text & Translation'**
  String get adminVocabMgmtAddTextAction;

  /// No description provided for @adminVocabMgmtPasteVocabularyAction.
  ///
  /// In en, this message translates to:
  /// **'Paste Vocabulary'**
  String get adminVocabMgmtPasteVocabularyAction;

  /// No description provided for @adminVocabMgmtAddKnowledgeAction.
  ///
  /// In en, this message translates to:
  /// **'Add Knowledge'**
  String get adminVocabMgmtAddKnowledgeAction;

  /// No description provided for @adminVocabMgmtKnowledgeBaseDescription.
  ///
  /// In en, this message translates to:
  /// **'This is Nnanga\'s knowledge base. It searches these words and their lessons to answer learners — the more you add, the better it answers.'**
  String get adminVocabMgmtKnowledgeBaseDescription;

  /// No description provided for @adminVocabMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search knowledge...'**
  String get adminVocabMgmtSearchHint;

  /// No description provided for @adminVocabMgmtAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get adminVocabMgmtAllLevels;

  /// No description provided for @adminVocabMgmtEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No knowledge found. Use \"Paste Vocabulary\" below to add a whole word list at once, or \"Add Knowledge\" for a single word.'**
  String get adminVocabMgmtEmptyState;

  /// No description provided for @adminVocabMgmtTextsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Texts & Translations'**
  String get adminVocabMgmtTextsSectionTitle;

  /// No description provided for @adminVocabMgmtEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String adminVocabMgmtEntriesCount(int count);

  /// No description provided for @adminVocabMgmtEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminVocabMgmtEditTooltip;

  /// No description provided for @adminVocabMgmtDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminVocabMgmtDeleteTooltip;

  /// No description provided for @adminVocabMgmtVocabularySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get adminVocabMgmtVocabularySectionTitle;

  /// No description provided for @adminVocabMgmtWordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String adminVocabMgmtWordsCount(int count);

  /// No description provided for @adminVocabMgmtEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminVocabMgmtEditAction;

  /// No description provided for @adminVocabMgmtDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminVocabMgmtDeleteAction;

  /// No description provided for @adminVocabMgmtEditKnowledgeEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Knowledge Entry'**
  String get adminVocabMgmtEditKnowledgeEntryTitle;

  /// No description provided for @adminVocabMgmtAddKnowledgeEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Knowledge Entry'**
  String get adminVocabMgmtAddKnowledgeEntryTitle;

  /// No description provided for @adminVocabMgmtEwondoWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo word or phrase'**
  String get adminVocabMgmtEwondoWordLabel;

  /// No description provided for @adminVocabMgmtExampleSentenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Example sentence'**
  String get adminVocabMgmtExampleSentenceLabel;

  /// No description provided for @adminVocabMgmtPhoneticLabel.
  ///
  /// In en, this message translates to:
  /// **'Phonetic transcription (optional)'**
  String get adminVocabMgmtPhoneticLabel;

  /// No description provided for @adminVocabMgmtPhoneticHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. mbɔ́lɔ́ — shown under the word on the lesson screen'**
  String get adminVocabMgmtPhoneticHint;

  /// No description provided for @adminVocabMgmtPronunciationAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation audio (helps Nnanga\'s \"hear it\" playback for learners)'**
  String get adminVocabMgmtPronunciationAudioLabel;

  /// No description provided for @adminVocabMgmtEnglishMeaningLabel.
  ///
  /// In en, this message translates to:
  /// **'English meaning'**
  String get adminVocabMgmtEnglishMeaningLabel;

  /// No description provided for @adminVocabMgmtEnglishTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'English translation'**
  String get adminVocabMgmtEnglishTranslationLabel;

  /// No description provided for @adminVocabMgmtFrenchMeaningLabel.
  ///
  /// In en, this message translates to:
  /// **'French meaning'**
  String get adminVocabMgmtFrenchMeaningLabel;

  /// No description provided for @adminVocabMgmtFrenchTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'French translation'**
  String get adminVocabMgmtFrenchTranslationLabel;

  /// No description provided for @adminVocabMgmtDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get adminVocabMgmtDifficultyLabel;

  /// No description provided for @adminVocabMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminVocabMgmtCancel;

  /// No description provided for @adminVocabMgmtSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminVocabMgmtSave;

  /// No description provided for @adminVocabMgmtAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminVocabMgmtAdd;

  /// No description provided for @adminVocabMgmtEditTextEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Text & Translation'**
  String get adminVocabMgmtEditTextEntryTitle;

  /// No description provided for @adminVocabMgmtAddTextEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Text & Translation'**
  String get adminVocabMgmtAddTextEntryTitle;

  /// No description provided for @adminVocabMgmtEwondoTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo text'**
  String get adminVocabMgmtEwondoTextLabel;

  /// No description provided for @adminVocabMgmtTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get adminVocabMgmtTranslationLabel;

  /// No description provided for @adminVocabMgmtPasteVocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Vocabulary'**
  String get adminVocabMgmtPasteVocabularyTitle;

  /// No description provided for @adminVocabMgmtPreviewImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview Import'**
  String get adminVocabMgmtPreviewImportTitle;

  /// No description provided for @adminVocabMgmtParseAction.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get adminVocabMgmtParseAction;

  /// No description provided for @adminVocabMgmtBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get adminVocabMgmtBackAction;

  /// No description provided for @adminVocabMgmtImportWordsAction.
  ///
  /// In en, this message translates to:
  /// **'Import {count} Word(s)'**
  String adminVocabMgmtImportWordsAction(int count);

  /// No description provided for @adminVocabMgmtPasteInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste a word list — one per line, or a blank line between richer entries.'**
  String get adminVocabMgmtPasteInstructions;

  /// No description provided for @adminVocabMgmtPasteFormatHelp.
  ///
  /// In en, this message translates to:
  /// **'Simple lines: \"word | English meaning | French meaning\" (meanings optional). Or spell it out over several lines with EN:, FR:, Example:, Example EN:, Example FR:, Phonetic:, and Level: — only the word itself is required.'**
  String get adminVocabMgmtPasteFormatHelp;

  /// No description provided for @adminVocabMgmtPasteFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your word list here…'**
  String get adminVocabMgmtPasteFieldHint;

  /// No description provided for @adminVocabMgmtWordsDetectedSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} word(s) detected — {validCount} ready to import.'**
  String adminVocabMgmtWordsDetectedSummary(int total, int validCount);

  /// No description provided for @adminVocabMgmtNothingToPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview — go back and adjust the pasted text.'**
  String get adminVocabMgmtNothingToPreview;

  /// No description provided for @adminDailyMgmtDailyWordAdded.
  ///
  /// In en, this message translates to:
  /// **'Daily word added.'**
  String get adminDailyMgmtDailyWordAdded;

  /// No description provided for @adminDailyMgmtCouldNotAddDailyWord.
  ///
  /// In en, this message translates to:
  /// **'Could not add daily word.'**
  String get adminDailyMgmtCouldNotAddDailyWord;

  /// No description provided for @adminDailyMgmtDailyWordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Daily word updated.'**
  String get adminDailyMgmtDailyWordUpdated;

  /// No description provided for @adminDailyMgmtCouldNotUpdateDailyWord.
  ///
  /// In en, this message translates to:
  /// **'Could not update daily word.'**
  String get adminDailyMgmtCouldNotUpdateDailyWord;

  /// No description provided for @adminDailyMgmtCouldNotDeleteDailyWord.
  ///
  /// In en, this message translates to:
  /// **'Could not delete daily word.'**
  String get adminDailyMgmtCouldNotDeleteDailyWord;

  /// No description provided for @adminDailyMgmtDailyVerseAdded.
  ///
  /// In en, this message translates to:
  /// **'Daily verse added.'**
  String get adminDailyMgmtDailyVerseAdded;

  /// No description provided for @adminDailyMgmtCouldNotAddDailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Could not add daily verse.'**
  String get adminDailyMgmtCouldNotAddDailyVerse;

  /// No description provided for @adminDailyMgmtDailyVerseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Daily verse updated.'**
  String get adminDailyMgmtDailyVerseUpdated;

  /// No description provided for @adminDailyMgmtCouldNotUpdateDailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Could not update daily verse.'**
  String get adminDailyMgmtCouldNotUpdateDailyVerse;

  /// No description provided for @adminDailyMgmtCouldNotDeleteDailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Could not delete daily verse.'**
  String get adminDailyMgmtCouldNotDeleteDailyVerse;

  /// No description provided for @adminDailyMgmtLanguageFallback.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get adminDailyMgmtLanguageFallback;

  /// No description provided for @adminDailyMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Phrase & Verse of the Day'**
  String get adminDailyMgmtTitle;

  /// No description provided for @adminDailyMgmtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rotating daily word/verse pools for {language}'**
  String adminDailyMgmtSubtitle(String language);

  /// No description provided for @adminDailyMgmtAddDailyWordAction.
  ///
  /// In en, this message translates to:
  /// **'Add Daily Word'**
  String get adminDailyMgmtAddDailyWordAction;

  /// No description provided for @adminDailyMgmtAddDailyVerseAction.
  ///
  /// In en, this message translates to:
  /// **'Add Daily Verse'**
  String get adminDailyMgmtAddDailyVerseAction;

  /// No description provided for @adminDailyMgmtDescription.
  ///
  /// In en, this message translates to:
  /// **'A different entry from each pool is shown automatically every day on the learner dashboard — no need to pick \"today\'s\" item by hand.'**
  String get adminDailyMgmtDescription;

  /// No description provided for @adminDailyMgmtDailyWordsChip.
  ///
  /// In en, this message translates to:
  /// **'Daily Words'**
  String get adminDailyMgmtDailyWordsChip;

  /// No description provided for @adminDailyMgmtDailyVersesChip.
  ///
  /// In en, this message translates to:
  /// **'Daily Verses'**
  String get adminDailyMgmtDailyVersesChip;

  /// No description provided for @adminDailyMgmtSearchWordsHint.
  ///
  /// In en, this message translates to:
  /// **'Search Ewondo words...'**
  String get adminDailyMgmtSearchWordsHint;

  /// No description provided for @adminDailyMgmtSearchVersesHint.
  ///
  /// In en, this message translates to:
  /// **'Search verses or reference...'**
  String get adminDailyMgmtSearchVersesHint;

  /// No description provided for @adminDailyMgmtNoDailyWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No daily words yet'**
  String get adminDailyMgmtNoDailyWordsTitle;

  /// No description provided for @adminDailyMgmtNoDailyWordsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add Ewondo words to rotate through on the learner dashboard.'**
  String get adminDailyMgmtNoDailyWordsMessage;

  /// No description provided for @adminDailyMgmtEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminDailyMgmtEditAction;

  /// No description provided for @adminDailyMgmtDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDailyMgmtDeleteAction;

  /// No description provided for @adminDailyMgmtNoDailyVersesTitle.
  ///
  /// In en, this message translates to:
  /// **'No daily verses yet'**
  String get adminDailyMgmtNoDailyVersesTitle;

  /// No description provided for @adminDailyMgmtNoDailyVersesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add Ewondo Bible verses to rotate through on the learner dashboard.'**
  String get adminDailyMgmtNoDailyVersesMessage;

  /// No description provided for @adminDailyMgmtEditDailyWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Daily Word'**
  String get adminDailyMgmtEditDailyWordTitle;

  /// No description provided for @adminDailyMgmtAddDailyWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Daily Word'**
  String get adminDailyMgmtAddDailyWordTitle;

  /// No description provided for @adminDailyMgmtEwondoWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo word'**
  String get adminDailyMgmtEwondoWordLabel;

  /// No description provided for @adminDailyMgmtEnglishMeaningLabel.
  ///
  /// In en, this message translates to:
  /// **'English meaning'**
  String get adminDailyMgmtEnglishMeaningLabel;

  /// No description provided for @adminDailyMgmtFrenchMeaningLabel.
  ///
  /// In en, this message translates to:
  /// **'French meaning'**
  String get adminDailyMgmtFrenchMeaningLabel;

  /// No description provided for @adminDailyMgmtUsageHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage hint (optional)'**
  String get adminDailyMgmtUsageHintLabel;

  /// No description provided for @adminDailyMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminDailyMgmtCancel;

  /// No description provided for @adminDailyMgmtSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminDailyMgmtSave;

  /// No description provided for @adminDailyMgmtAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminDailyMgmtAdd;

  /// No description provided for @adminDailyMgmtEditDailyVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Daily Verse'**
  String get adminDailyMgmtEditDailyVerseTitle;

  /// No description provided for @adminDailyMgmtAddDailyVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Daily Verse'**
  String get adminDailyMgmtAddDailyVerseTitle;

  /// No description provided for @adminDailyMgmtReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference (e.g. Yoannes 3:16)'**
  String get adminDailyMgmtReferenceLabel;

  /// No description provided for @adminDailyMgmtEwondoTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo text'**
  String get adminDailyMgmtEwondoTextLabel;

  /// No description provided for @adminDailyMgmtEnglishTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'English translation'**
  String get adminDailyMgmtEnglishTranslationLabel;

  /// No description provided for @adminDailyMgmtFrenchTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'French translation'**
  String get adminDailyMgmtFrenchTranslationLabel;

  /// No description provided for @adminDailyMgmtCouldNotLoadVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Could not load vocabulary.'**
  String get adminDailyMgmtCouldNotLoadVocabulary;

  /// No description provided for @adminDailyMgmtPickVocabularyWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a Vocabulary word'**
  String get adminDailyMgmtPickVocabularyWordTitle;

  /// No description provided for @adminDailyMgmtSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adminDailyMgmtSearchLabel;

  /// No description provided for @adminDailyMgmtSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get adminDailyMgmtSomethingWentWrong;

  /// No description provided for @adminDailyMgmtNoVocabularyYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary yet'**
  String get adminDailyMgmtNoVocabularyYetTitle;

  /// No description provided for @adminDailyMgmtNoVocabularyYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add words in Vocabulary Management first.'**
  String get adminDailyMgmtNoVocabularyYetMessage;

  /// No description provided for @adminDailyMgmtCouldNotLoadBibleChapters.
  ///
  /// In en, this message translates to:
  /// **'Could not load Bible chapters.'**
  String get adminDailyMgmtCouldNotLoadBibleChapters;

  /// No description provided for @adminDailyMgmtCouldNotLoadVerses.
  ///
  /// In en, this message translates to:
  /// **'Could not load verses.'**
  String get adminDailyMgmtCouldNotLoadVerses;

  /// No description provided for @adminDailyMgmtPickChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a chapter'**
  String get adminDailyMgmtPickChapterTitle;

  /// No description provided for @adminDailyMgmtNoBibleContentYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bible content yet'**
  String get adminDailyMgmtNoBibleContentYetTitle;

  /// No description provided for @adminDailyMgmtNoBibleContentYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add chapters in Bible Management first.'**
  String get adminDailyMgmtNoBibleContentYetMessage;

  /// No description provided for @adminDailyMgmtNoVersesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No verses yet'**
  String get adminDailyMgmtNoVersesYetTitle;

  /// No description provided for @adminDailyMgmtNoVersesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'This chapter has no verses.'**
  String get adminDailyMgmtNoVersesYetMessage;

  /// No description provided for @adminDailyMgmtBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get adminDailyMgmtBackAction;

  /// No description provided for @adminDailyMgmtVerseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String adminDailyMgmtVerseCount(int count);

  /// No description provided for @adminDailyMgmtVerseNumber.
  ///
  /// In en, this message translates to:
  /// **'Verse {number}'**
  String adminDailyMgmtVerseNumber(int number);

  /// No description provided for @adminBookMgmtAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get adminBookMgmtAddBook;

  /// No description provided for @adminBookMgmtAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add book.'**
  String get adminBookMgmtAddError;

  /// No description provided for @adminBookMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminBookMgmtCancel;

  /// No description provided for @adminBookMgmtCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminBookMgmtCategoryAll;

  /// No description provided for @adminBookMgmtCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get adminBookMgmtCreate;

  /// No description provided for @adminBookMgmtDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminBookMgmtDelete;

  /// No description provided for @adminBookMgmtDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed for every learner.'**
  String adminBookMgmtDeleteBody(String title);

  /// No description provided for @adminBookMgmtDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete book.'**
  String get adminBookMgmtDeleteError;

  /// No description provided for @adminBookMgmtDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete book?'**
  String get adminBookMgmtDeleteTitle;

  /// No description provided for @adminBookMgmtDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Book deleted.'**
  String get adminBookMgmtDeletedMessage;

  /// No description provided for @adminBookMgmtEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminBookMgmtEdit;

  /// No description provided for @adminBookMgmtEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Book\" to create the first one.'**
  String get adminBookMgmtEmptyMessage;

  /// No description provided for @adminBookMgmtEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get adminBookMgmtEmptyTitle;

  /// No description provided for @adminBookMgmtErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get adminBookMgmtErrorTitle;

  /// No description provided for @adminBookMgmtLanguageFallback.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get adminBookMgmtLanguageFallback;

  /// No description provided for @adminBookMgmtLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load books.'**
  String get adminBookMgmtLoadError;

  /// No description provided for @adminBookMgmtNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content yet'**
  String get adminBookMgmtNoContent;

  /// No description provided for @adminBookMgmtPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String adminBookMgmtPagesCount(int count);

  /// No description provided for @adminBookMgmtSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get adminBookMgmtSearchLabel;

  /// No description provided for @adminBookMgmtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Books for {title}'**
  String adminBookMgmtSubtitle(String title);

  /// No description provided for @adminBookMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Management'**
  String get adminBookMgmtTitle;

  /// No description provided for @adminBookMgmtTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminBookMgmtTitleLabel;

  /// No description provided for @adminLangMgmtAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminLangMgmtAdd;

  /// No description provided for @adminLangMgmtAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add language.'**
  String get adminLangMgmtAddError;

  /// No description provided for @adminLangMgmtAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Language'**
  String get adminLangMgmtAddTitle;

  /// No description provided for @adminLangMgmtAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Language added. It starts as a draft — publish it once its content is ready.'**
  String get adminLangMgmtAddedMessage;

  /// No description provided for @adminLangMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminLangMgmtCancel;

  /// No description provided for @adminLangMgmtCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code (e.g. bas)'**
  String get adminLangMgmtCodeLabel;

  /// No description provided for @adminLangMgmtCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get adminLangMgmtCountryLabel;

  /// No description provided for @adminLangMgmtDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminLangMgmtDelete;

  /// No description provided for @adminLangMgmtDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently removed. This only works if it has no courses yet.'**
  String adminLangMgmtDeleteBody(String name);

  /// No description provided for @adminLangMgmtDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete language.'**
  String get adminLangMgmtDeleteError;

  /// No description provided for @adminLangMgmtDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete language?'**
  String get adminLangMgmtDeleteTitle;

  /// No description provided for @adminLangMgmtDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Language deleted.'**
  String get adminLangMgmtDeletedMessage;

  /// No description provided for @adminLangMgmtDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminLangMgmtDraft;

  /// No description provided for @adminLangMgmtEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Language\" to create the first one.'**
  String get adminLangMgmtEmptyMessage;

  /// No description provided for @adminLangMgmtEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No languages yet'**
  String get adminLangMgmtEmptyTitle;

  /// No description provided for @adminLangMgmtErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get adminLangMgmtErrorTitle;

  /// No description provided for @adminLangMgmtLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load languages.'**
  String get adminLangMgmtLoadError;

  /// No description provided for @adminLangMgmtNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Bassa)'**
  String get adminLangMgmtNameLabel;

  /// No description provided for @adminLangMgmtPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminLangMgmtPublished;

  /// No description provided for @adminLangMgmtSubtitleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String adminLangMgmtSubtitleCount(int count);

  /// No description provided for @adminLangMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get adminLangMgmtTitle;

  /// No description provided for @adminLangMgmtUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update language.'**
  String get adminLangMgmtUpdateError;

  /// No description provided for @adminLessonImagesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminLessonImagesAdd;

  /// No description provided for @adminLessonImagesAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add image.'**
  String get adminLessonImagesAddError;

  /// No description provided for @adminLessonImagesAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get adminLessonImagesAddImage;

  /// No description provided for @adminLessonImagesAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Image added.'**
  String get adminLessonImagesAddedMessage;

  /// No description provided for @adminLessonImagesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminLessonImagesCancel;

  /// No description provided for @adminLessonImagesCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get adminLessonImagesCaptionLabel;

  /// No description provided for @adminLessonImagesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminLessonImagesDelete;

  /// No description provided for @adminLessonImagesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove the image for \"{word}\"?'**
  String adminLessonImagesDeleteBody(String word);

  /// No description provided for @adminLessonImagesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get adminLessonImagesDeleteTitle;

  /// No description provided for @adminLessonImagesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrate a Word'**
  String get adminLessonImagesDialogTitle;

  /// No description provided for @adminLessonImagesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an image to illustrate a word in this lesson.'**
  String get adminLessonImagesEmptyMessage;

  /// No description provided for @adminLessonImagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get adminLessonImagesEmptyTitle;

  /// No description provided for @adminLessonImagesIntro.
  ///
  /// In en, this message translates to:
  /// **'Add images to illustrate words from this lesson. Add as many as you like.'**
  String get adminLessonImagesIntro;

  /// No description provided for @adminLessonImagesRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove image.'**
  String get adminLessonImagesRemoveError;

  /// No description provided for @adminLessonImagesRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Image removed.'**
  String get adminLessonImagesRemovedMessage;

  /// No description provided for @adminLessonImagesTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Lesson Images'**
  String get adminLessonImagesTitleFallback;

  /// No description provided for @adminLessonImagesTitleWithLesson.
  ///
  /// In en, this message translates to:
  /// **'Images — {lesson}'**
  String adminLessonImagesTitleWithLesson(String lesson);

  /// No description provided for @adminLessonImagesWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Word this illustrates'**
  String get adminLessonImagesWordLabel;

  /// No description provided for @adminModuleMgmtAllCourses.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get adminModuleMgmtAllCourses;

  /// No description provided for @adminModuleMgmtAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Module Management'**
  String get adminModuleMgmtAppBarTitle;

  /// No description provided for @adminModuleMgmtCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminModuleMgmtCancel;

  /// No description provided for @adminModuleMgmtCourseLabel.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get adminModuleMgmtCourseLabel;

  /// No description provided for @adminModuleMgmtCourseLessonsSummary.
  ///
  /// In en, this message translates to:
  /// **'{course} • {count} lessons'**
  String adminModuleMgmtCourseLessonsSummary(String course, int count);

  /// No description provided for @adminModuleMgmtCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get adminModuleMgmtCreate;

  /// No description provided for @adminModuleMgmtCreateCourseFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a course first.'**
  String get adminModuleMgmtCreateCourseFirst;

  /// No description provided for @adminModuleMgmtCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create module.'**
  String get adminModuleMgmtCreateError;

  /// No description provided for @adminModuleMgmtCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Module created.'**
  String get adminModuleMgmtCreatedMessage;

  /// No description provided for @adminModuleMgmtDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminModuleMgmtDelete;

  /// No description provided for @adminModuleMgmtDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String adminModuleMgmtDeleteBody(String title);

  /// No description provided for @adminModuleMgmtDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete module.'**
  String get adminModuleMgmtDeleteError;

  /// No description provided for @adminModuleMgmtDeleteLessonsFirst.
  ///
  /// In en, this message translates to:
  /// **'Delete this module\'s {count} lesson(s) first.'**
  String adminModuleMgmtDeleteLessonsFirst(int count);

  /// No description provided for @adminModuleMgmtDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Module'**
  String get adminModuleMgmtDeleteTitle;

  /// No description provided for @adminModuleMgmtDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Module deleted.'**
  String get adminModuleMgmtDeletedMessage;

  /// No description provided for @adminModuleMgmtDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminModuleMgmtDescriptionLabel;

  /// No description provided for @adminModuleMgmtEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Module'**
  String get adminModuleMgmtEditTitle;

  /// No description provided for @adminModuleMgmtFrenchDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'French Description (optional)'**
  String get adminModuleMgmtFrenchDescriptionLabel;

  /// No description provided for @adminModuleMgmtFrenchTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'French Title (optional)'**
  String get adminModuleMgmtFrenchTitleLabel;

  /// No description provided for @adminModuleMgmtNewModule.
  ///
  /// In en, this message translates to:
  /// **'New Module'**
  String get adminModuleMgmtNewModule;

  /// No description provided for @adminModuleMgmtNoModulesFound.
  ///
  /// In en, this message translates to:
  /// **'No modules found.'**
  String get adminModuleMgmtNoModulesFound;

  /// No description provided for @adminModuleMgmtSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminModuleMgmtSave;

  /// No description provided for @adminModuleMgmtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search modules...'**
  String get adminModuleMgmtSearchHint;

  /// No description provided for @adminModuleMgmtTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminModuleMgmtTitleLabel;

  /// No description provided for @adminModuleMgmtUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update module.'**
  String get adminModuleMgmtUpdateError;

  /// No description provided for @adminModuleMgmtUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Module updated.'**
  String get adminModuleMgmtUpdatedMessage;

  /// No description provided for @adminProfileAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get adminProfileAccountDetails;

  /// No description provided for @adminProfileAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get adminProfileAccountStatus;

  /// No description provided for @adminProfileActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminProfileActive;

  /// No description provided for @adminProfileAdministratorRole.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminProfileAdministratorRole;

  /// No description provided for @adminProfileDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get adminProfileDeactivated;

  /// No description provided for @adminProfileEditProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get adminProfileEditProfileLabel;

  /// No description provided for @adminProfileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get adminProfileFullNameLabel;

  /// No description provided for @adminProfileLastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get adminProfileLastLogin;

  /// No description provided for @adminProfileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get adminProfileLogOut;

  /// No description provided for @adminProfileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get adminProfileMemberSince;

  /// No description provided for @adminProfileNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current password'**
  String get adminProfileNewPasswordHint;

  /// No description provided for @adminProfileNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get adminProfileNewPasswordLabel;

  /// No description provided for @adminProfileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminProfileSaveChanges;

  /// No description provided for @adminProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your administrator account'**
  String get adminProfileSubtitle;

  /// No description provided for @adminProfileThisSession.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get adminProfileThisSession;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get adminProfileTitle;

  /// No description provided for @adminProfileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get adminProfileUpdateError;

  /// No description provided for @adminProfileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get adminProfileUpdatedMessage;

  /// No description provided for @adminProfileUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo.'**
  String get adminProfileUploadError;

  /// No description provided for @adminBookEditorAddPageError.
  ///
  /// In en, this message translates to:
  /// **'Could not add page.'**
  String get adminBookEditorAddPageError;

  /// No description provided for @adminBookEditorAddPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Page'**
  String get adminBookEditorAddPageLabel;

  /// No description provided for @adminBookEditorAudioOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio (optional)'**
  String get adminBookEditorAudioOptionalLabel;

  /// No description provided for @adminBookEditorAuthorFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Author (optional)'**
  String get adminBookEditorAuthorFieldLabel;

  /// No description provided for @adminBookEditorAuthoredPagesSegmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Authored Pages'**
  String get adminBookEditorAuthoredPagesSegmentLabel;

  /// No description provided for @adminBookEditorBookSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Book saved.'**
  String get adminBookEditorBookSavedMessage;

  /// No description provided for @adminBookEditorCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminBookEditorCategoryLabel;

  /// No description provided for @adminBookEditorChangeCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Cover'**
  String get adminBookEditorChangeCoverLabel;

  /// No description provided for @adminBookEditorContainsIllustrationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contains illustrations'**
  String get adminBookEditorContainsIllustrationsLabel;

  /// No description provided for @adminBookEditorContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminBookEditorContentTitle;

  /// No description provided for @adminBookEditorCoverImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover Image'**
  String get adminBookEditorCoverImageLabel;

  /// No description provided for @adminBookEditorCurrentFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Current file: {fileType} — {fileUrl}'**
  String adminBookEditorCurrentFileLabel(String fileType, String fileUrl);

  /// No description provided for @adminBookEditorDeletePageError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete page.'**
  String get adminBookEditorDeletePageError;

  /// No description provided for @adminBookEditorDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get adminBookEditorDescriptionFieldLabel;

  /// No description provided for @adminBookEditorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get adminBookEditorDetailsTitle;

  /// No description provided for @adminBookEditorEnglishTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'English Translation (optional)'**
  String get adminBookEditorEnglishTranslationLabel;

  /// No description provided for @adminBookEditorEwondoTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Ewondo Text'**
  String get adminBookEditorEwondoTextLabel;

  /// No description provided for @adminBookEditorFrenchDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'French description (optional)'**
  String get adminBookEditorFrenchDescriptionLabel;

  /// No description provided for @adminBookEditorFrenchTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'French Translation (optional)'**
  String get adminBookEditorFrenchTranslationLabel;

  /// No description provided for @adminBookEditorIllustrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Illustration'**
  String get adminBookEditorIllustrationLabel;

  /// No description provided for @adminBookEditorLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get adminBookEditorLevelLabel;

  /// No description provided for @adminBookEditorNoFileUploadedMessage.
  ///
  /// In en, this message translates to:
  /// **'No file uploaded yet.'**
  String get adminBookEditorNoFileUploadedMessage;

  /// No description provided for @adminBookEditorNoPagesMessage.
  ///
  /// In en, this message translates to:
  /// **'No pages yet. Add the first one below.'**
  String get adminBookEditorNoPagesMessage;

  /// No description provided for @adminBookEditorPageNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String adminBookEditorPageNumberLabel(int number);

  /// No description provided for @adminBookEditorReadingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading Time (min)'**
  String get adminBookEditorReadingTimeLabel;

  /// No description provided for @adminBookEditorRecommendedAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended Age (min. years)'**
  String get adminBookEditorRecommendedAgeLabel;

  /// No description provided for @adminBookEditorReorderPagesError.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder pages.'**
  String get adminBookEditorReorderPagesError;

  /// No description provided for @adminBookEditorReplaceAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Replace Audio'**
  String get adminBookEditorReplaceAudioLabel;

  /// No description provided for @adminBookEditorReplaceFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Replace File'**
  String get adminBookEditorReplaceFileLabel;

  /// No description provided for @adminBookEditorSaveBookError.
  ///
  /// In en, this message translates to:
  /// **'Could not save book.'**
  String get adminBookEditorSaveBookError;

  /// No description provided for @adminBookEditorSavePageError.
  ///
  /// In en, this message translates to:
  /// **'Could not save page.'**
  String get adminBookEditorSavePageError;

  /// No description provided for @adminBookEditorSavePageLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Page'**
  String get adminBookEditorSavePageLabel;

  /// No description provided for @adminBookEditorSavingEllipsisLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get adminBookEditorSavingEllipsisLabel;

  /// No description provided for @adminBookEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Book'**
  String get adminBookEditorTitle;

  /// No description provided for @adminBookEditorTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminBookEditorTitleFieldLabel;

  /// No description provided for @adminBookEditorUploadAudioError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload audio.'**
  String get adminBookEditorUploadAudioError;

  /// No description provided for @adminBookEditorUploadCoverError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload cover image.'**
  String get adminBookEditorUploadCoverError;

  /// No description provided for @adminBookEditorUploadFileError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload file.'**
  String get adminBookEditorUploadFileError;

  /// No description provided for @adminBookEditorUploadFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF or EPUB'**
  String get adminBookEditorUploadFileLabel;

  /// No description provided for @adminBookEditorUploadIllustrationError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload illustration.'**
  String get adminBookEditorUploadIllustrationError;

  /// No description provided for @adminBookEditorUploadedFileSegmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploaded File'**
  String get adminBookEditorUploadedFileSegmentLabel;

  /// No description provided for @adminSyllabaryMgmtAnalyzeError.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze this content.'**
  String get adminSyllabaryMgmtAnalyzeError;

  /// No description provided for @adminSyllabaryMgmtAnalyzeWithAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get adminSyllabaryMgmtAnalyzeWithAiLabel;

  /// No description provided for @adminSyllabaryMgmtAnalyzingMessage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing chart photo…'**
  String get adminSyllabaryMgmtAnalyzingMessage;

  /// No description provided for @adminSyllabaryMgmtApproveImportLabel.
  ///
  /// In en, this message translates to:
  /// **'Approve & Import'**
  String get adminSyllabaryMgmtApproveImportLabel;

  /// No description provided for @adminSyllabaryMgmtChooseFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a File'**
  String get adminSyllabaryMgmtChooseFileLabel;

  /// No description provided for @adminSyllabaryMgmtClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminSyllabaryMgmtClearLabel;

  /// No description provided for @adminSyllabaryMgmtClipboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing usable found on the clipboard.'**
  String get adminSyllabaryMgmtClipboardEmptyMessage;

  /// No description provided for @adminSyllabaryMgmtContentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Preview'**
  String get adminSyllabaryMgmtContentPreviewTitle;

  /// No description provided for @adminSyllabaryMgmtDeleteEntryError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete entry.'**
  String get adminSyllabaryMgmtDeleteEntryError;

  /// No description provided for @adminSyllabaryMgmtDeleteLetterDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Delete all {count} row(s) for \"{letter}\"?'**
  String adminSyllabaryMgmtDeleteLetterDialogContent(int count, String letter);

  /// No description provided for @adminSyllabaryMgmtDeleteLetterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{letter}\"'**
  String adminSyllabaryMgmtDeleteLetterDialogTitle(String letter);

  /// No description provided for @adminSyllabaryMgmtDeleteLetterError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete letter.'**
  String get adminSyllabaryMgmtDeleteLetterError;

  /// No description provided for @adminSyllabaryMgmtDeleteLetterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all rows for \"{letter}\"'**
  String adminSyllabaryMgmtDeleteLetterTooltip(String letter);

  /// No description provided for @adminSyllabaryMgmtDimensionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dimensions: {width} × {height}'**
  String adminSyllabaryMgmtDimensionsLabel(int width, int height);

  /// No description provided for @adminSyllabaryMgmtDropZoneText.
  ///
  /// In en, this message translates to:
  /// **'Paste an image, a table, or text here\nor drag and drop a file'**
  String get adminSyllabaryMgmtDropZoneText;

  /// No description provided for @adminSyllabaryMgmtEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No syllabary content yet. Tap \"Upload Chart\" below — paste, drop, or choose a photo, PDF, Word, Excel, or text file of a chart, and the AI will extract it for you to review before saving.'**
  String get adminSyllabaryMgmtEmptyStateMessage;

  /// No description provided for @adminSyllabaryMgmtEnglishTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'English translation (optional)'**
  String get adminSyllabaryMgmtEnglishTranslationLabel;

  /// No description provided for @adminSyllabaryMgmtExampleSentenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Example sentence'**
  String get adminSyllabaryMgmtExampleSentenceLabel;

  /// No description provided for @adminSyllabaryMgmtExampleWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Example word'**
  String get adminSyllabaryMgmtExampleWordLabel;

  /// No description provided for @adminSyllabaryMgmtExtractionNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'AI extraction notes'**
  String get adminSyllabaryMgmtExtractionNotesLabel;

  /// No description provided for @adminSyllabaryMgmtFrenchTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'French translation'**
  String get adminSyllabaryMgmtFrenchTranslationLabel;

  /// No description provided for @adminSyllabaryMgmtImportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} row(s).'**
  String adminSyllabaryMgmtImportedMessage(int count);

  /// No description provided for @adminSyllabaryMgmtImportedWithFailuresMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {succeeded} row(s), {failed} failed{errorSuffix}.'**
  String adminSyllabaryMgmtImportedWithFailuresMessage(
    int succeeded,
    int failed,
    String errorSuffix,
  );

  /// No description provided for @adminSyllabaryMgmtLetterDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{letter}\" deleted.'**
  String adminSyllabaryMgmtLetterDeletedMessage(String letter);

  /// No description provided for @adminSyllabaryMgmtLetterFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. L (blank = vowel-only)'**
  String get adminSyllabaryMgmtLetterFieldHint;

  /// No description provided for @adminSyllabaryMgmtLetterFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get adminSyllabaryMgmtLetterFieldLabel;

  /// No description provided for @adminSyllabaryMgmtLettersDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} letters — review each below.'**
  String adminSyllabaryMgmtLettersDetectedMessage(int count);

  /// No description provided for @adminSyllabaryMgmtLettersSummary.
  ///
  /// In en, this message translates to:
  /// **'{letterCount} letter(s), {rowCount} row(s) total'**
  String adminSyllabaryMgmtLettersSummary(int letterCount, int rowCount);

  /// No description provided for @adminSyllabaryMgmtLettersTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get adminSyllabaryMgmtLettersTitle;

  /// No description provided for @adminSyllabaryMgmtListTitle.
  ///
  /// In en, this message translates to:
  /// **'Syllabus Management'**
  String get adminSyllabaryMgmtListTitle;

  /// No description provided for @adminSyllabaryMgmtNoChartsDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'No syllabary charts were detected. Try Re-analyze with a clearer photo or document, or go back and upload a different one.'**
  String get adminSyllabaryMgmtNoChartsDetectedMessage;

  /// No description provided for @adminSyllabaryMgmtNoRowsDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'No rows detected — check the notes on the review screen.'**
  String get adminSyllabaryMgmtNoRowsDetectedMessage;

  /// No description provided for @adminSyllabaryMgmtNoRowsForLetterMessage.
  ///
  /// In en, this message translates to:
  /// **'No rows detected for this letter.'**
  String get adminSyllabaryMgmtNoRowsForLetterMessage;

  /// No description provided for @adminSyllabaryMgmtNoneDetectedLabel.
  ///
  /// In en, this message translates to:
  /// **'None detected'**
  String get adminSyllabaryMgmtNoneDetectedLabel;

  /// No description provided for @adminSyllabaryMgmtPasteFromClipboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get adminSyllabaryMgmtPasteFromClipboardLabel;

  /// No description provided for @adminSyllabaryMgmtPastedTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Pasted text'**
  String get adminSyllabaryMgmtPastedTextLabel;

  /// No description provided for @adminSyllabaryMgmtReanalyzeAction.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze'**
  String get adminSyllabaryMgmtReanalyzeAction;

  /// No description provided for @adminSyllabaryMgmtReanalyzeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This replaces the current draft, including any edits you made.'**
  String get adminSyllabaryMgmtReanalyzeDialogContent;

  /// No description provided for @adminSyllabaryMgmtReanalyzeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze?'**
  String get adminSyllabaryMgmtReanalyzeDialogTitle;

  /// No description provided for @adminSyllabaryMgmtRemoveLetterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove this letter and its rows'**
  String get adminSyllabaryMgmtRemoveLetterTooltip;

  /// No description provided for @adminSyllabaryMgmtRemoveRowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove this row'**
  String get adminSyllabaryMgmtRemoveRowTooltip;

  /// No description provided for @adminSyllabaryMgmtReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Chart'**
  String get adminSyllabaryMgmtReviewTitle;

  /// No description provided for @adminSyllabaryMgmtRowCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} row(s)'**
  String adminSyllabaryMgmtRowCountLabel(int count);

  /// No description provided for @adminSyllabaryMgmtRowNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {number}'**
  String adminSyllabaryMgmtRowNumberLabel(int number);

  /// No description provided for @adminSyllabaryMgmtSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String adminSyllabaryMgmtSizeLabel(String size);

  /// No description provided for @adminSyllabaryMgmtStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'A photo, a table, or text — pick whichever is easiest.'**
  String get adminSyllabaryMgmtStep1Subtitle;

  /// No description provided for @adminSyllabaryMgmtStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Paste or Import Content'**
  String get adminSyllabaryMgmtStep1Title;

  /// No description provided for @adminSyllabaryMgmtSupportedFormatsText.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PNG, JPG, PDF, Word, Excel, TXT'**
  String get adminSyllabaryMgmtSupportedFormatsText;

  /// No description provided for @adminSyllabaryMgmtSyllableCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} syllable(s)'**
  String adminSyllabaryMgmtSyllableCountLabel(int count);

  /// No description provided for @adminSyllabaryMgmtSyllableLabel.
  ///
  /// In en, this message translates to:
  /// **'Syllable'**
  String get adminSyllabaryMgmtSyllableLabel;

  /// No description provided for @adminSyllabaryMgmtTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String adminSyllabaryMgmtTypeLabel(String type);

  /// No description provided for @adminSyllabaryMgmtUnknownServerError.
  ///
  /// In en, this message translates to:
  /// **'Unknown server error.'**
  String get adminSyllabaryMgmtUnknownServerError;

  /// No description provided for @adminSyllabaryMgmtUploadChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Chart'**
  String get adminSyllabaryMgmtUploadChartLabel;

  /// No description provided for @adminSyllabaryMgmtVowelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vowel'**
  String get adminSyllabaryMgmtVowelLabel;

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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get commonUnassigned;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get commonOptional;

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

  /// No description provided for @rememberMeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMeLabel;

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
  /// **'Sign Up'**
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
  /// **'Create an account'**
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
  /// **'Sign Up'**
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

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navAI.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get navAI;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @learnerNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get learnerNavHome;

  /// No description provided for @learnerNavMyCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get learnerNavMyCourses;

  /// No description provided for @learnerNavLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get learnerNavLibrary;

  /// No description provided for @learnerNavLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get learnerNavLessons;

  /// No description provided for @learnerNavVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get learnerNavVocabulary;

  /// No description provided for @learnerNavAiTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get learnerNavAiTutor;

  /// No description provided for @learnerNavFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get learnerNavFavorites;

  /// No description provided for @learnerNavHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get learnerNavHistory;

  /// No description provided for @learnerNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get learnerNavSettings;

  /// No description provided for @learnerShellTagline.
  ///
  /// In en, this message translates to:
  /// **'Mbolo! Let\'s learn together'**
  String get learnerShellTagline;

  /// No description provided for @learnerHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No lessons viewed yet. Start a lesson to see it here.'**
  String get learnerHistoryEmptyMessage;

  /// No description provided for @learnerHistoryViewedOn.
  ///
  /// In en, this message translates to:
  /// **'Viewed {date}'**
  String learnerHistoryViewedOn(String date);

  /// No description provided for @learnerFavoritesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Bookmark a lesson to see it here.'**
  String get learnerFavoritesEmptyMessage;

  /// No description provided for @learnerFavoritesLessonsSection.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get learnerFavoritesLessonsSection;

  /// No description provided for @learnerFavoritesBooksSection.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get learnerFavoritesBooksSection;

  /// No description provided for @lessonsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonsHubTitle;

  /// No description provided for @lessonsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse every lesson in a course'**
  String get lessonsHubSubtitle;

  /// No description provided for @lessonsHubSelectLessonMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a lesson to see its details.'**
  String get lessonsHubSelectLessonMessage;

  /// No description provided for @lessonsHubEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This course has no lessons yet.'**
  String get lessonsHubEmptyMessage;

  /// No description provided for @lessonsHubStartLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get lessonsHubStartLessonButton;

  /// No description provided for @lessonsHubLearningObjectivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Objectives'**
  String get lessonsHubLearningObjectivesTitle;

  /// No description provided for @lessonsHubWhatYouWillLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Learn'**
  String get lessonsHubWhatYouWillLearnTitle;

  /// No description provided for @lessonsHubMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String lessonsHubMinutesShort(int minutes);

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

  /// No description provided for @certificateEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate earned!'**
  String get certificateEarnedTitle;

  /// No description provided for @certificateEarnedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed every lesson and quiz. Well done!'**
  String get certificateEarnedMessage;

  /// No description provided for @certificateEarnedButton.
  ///
  /// In en, this message translates to:
  /// **'View my certificate'**
  String get certificateEarnedButton;

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

  /// No description provided for @downloadForOfflineButton.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get downloadForOfflineButton;

  /// No description provided for @downloadingOfflineLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String downloadingOfflineLabel(int percent);

  /// No description provided for @downloadedOfflineLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloaded for offline'**
  String get downloadedOfflineLabel;

  /// No description provided for @removeDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownloadButton;

  /// No description provided for @removeDownloadConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove downloaded course?'**
  String get removeDownloadConfirmTitle;

  /// No description provided for @removeDownloadConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to download it again to use it offline.'**
  String get removeDownloadConfirmMessage;

  /// No description provided for @downloadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the course. Check your connection and try again.'**
  String get downloadFailedMessage;

  /// No description provided for @downloadCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Course downloaded — available offline now.'**
  String get downloadCompleteMessage;

  /// No description provided for @quizRequiresConnectivityMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — connect to the internet to take this quiz.'**
  String get quizRequiresConnectivityMessage;

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

  /// No description provided for @previousLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousLessonButton;

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
  /// **'Book Library'**
  String get booksTitle;

  /// No description provided for @booksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover and read Ewondo books.'**
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

  /// No description provided for @booksHubCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get booksHubCategoryAll;

  /// No description provided for @booksHubSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a book...'**
  String get booksHubSearchHint;

  /// No description provided for @booksHubSelectBookMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a book to see its details.'**
  String get booksHubSelectBookMessage;

  /// No description provided for @booksHubReadButton.
  ///
  /// In en, this message translates to:
  /// **'Read the book'**
  String get booksHubReadButton;

  /// No description provided for @booksHubAddToFavoritesButton.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get booksHubAddToFavoritesButton;

  /// No description provided for @booksHubRemoveFromFavoritesButton.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get booksHubRemoveFromFavoritesButton;

  /// No description provided for @booksHubNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get booksHubNewBadge;

  /// No description provided for @booksHubCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get booksHubCategoryLabel;

  /// No description provided for @booksHubLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get booksHubLevelLabel;

  /// No description provided for @booksHubLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get booksHubLanguageLabel;

  /// No description provided for @booksHubPagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get booksHubPagesLabel;

  /// No description provided for @booksHubPublishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get booksHubPublishedLabel;

  /// No description provided for @booksHubMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String booksHubMinutesShort(int minutes);

  /// No description provided for @booksHubRecommendedAgeShort.
  ///
  /// In en, this message translates to:
  /// **'{age}+ years'**
  String booksHubRecommendedAgeShort(int age);

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
  /// **'Learning Language'**
  String get switchLanguageTitle;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageTitle;

  /// No description provided for @bookReaderTextSizeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get bookReaderTextSizeTooltip;

  /// No description provided for @uploadPhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhotoTooltip;

  /// No description provided for @couldNotUploadPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo.'**
  String get couldNotUploadPhotoError;

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

  /// No description provided for @chooseLanguageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load languages. Check your connection to the server and try again.'**
  String get chooseLanguageLoadError;

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

  /// No description provided for @adminNeedsWiderScreen.
  ///
  /// In en, this message translates to:
  /// **'The admin dashboard needs a wider screen.'**
  String get adminNeedsWiderScreen;

  /// No description provided for @adminResizeBrowserMessage.
  ///
  /// In en, this message translates to:
  /// **'Please resize your browser window or use a desktop device.'**
  String get adminResizeBrowserMessage;

  /// No description provided for @adminNavOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get adminNavOverview;

  /// No description provided for @adminNavLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get adminNavLanguages;

  /// No description provided for @adminNavUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminNavUsers;

  /// No description provided for @adminNavCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get adminNavCertificates;

  /// No description provided for @adminNavReportsActivity.
  ///
  /// In en, this message translates to:
  /// **'Reports & Activity'**
  String get adminNavReportsActivity;

  /// No description provided for @adminNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminNavDashboard;

  /// No description provided for @adminNavLearners.
  ///
  /// In en, this message translates to:
  /// **'Learners'**
  String get adminNavLearners;

  /// No description provided for @adminNavCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get adminNavCourses;

  /// No description provided for @adminNavLessonsContent.
  ///
  /// In en, this message translates to:
  /// **'Lessons & Content'**
  String get adminNavLessonsContent;

  /// No description provided for @adminNavVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get adminNavVocabulary;

  /// No description provided for @adminNavAssessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get adminNavAssessments;

  /// No description provided for @adminNavAiTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get adminNavAiTutor;

  /// No description provided for @adminNavBible.
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get adminNavBible;

  /// No description provided for @adminNavBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get adminNavBooks;

  /// No description provided for @adminNavDaily.
  ///
  /// In en, this message translates to:
  /// **'Phrase & Verse of the Day'**
  String get adminNavDaily;

  /// No description provided for @adminNavReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminNavReports;

  /// No description provided for @adminNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminNavSettings;

  /// No description provided for @adminLanguageActiveSuffix.
  ///
  /// In en, this message translates to:
  /// **'{name} · Active'**
  String adminLanguageActiveSuffix(String name);

  /// No description provided for @adminBackToAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'Back to All Languages'**
  String get adminBackToAllLanguages;

  /// No description provided for @adminRoleFallback.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRoleFallback;

  /// No description provided for @adminSuperAdminFallback.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get adminSuperAdminFallback;

  /// No description provided for @adminLanguageFallback.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get adminLanguageFallback;

  /// No description provided for @adminDashboardOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get adminDashboardOverviewTitle;

  /// No description provided for @adminDashboardOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening across the platform today.'**
  String get adminDashboardOverviewSubtitle;

  /// No description provided for @adminStatActiveLanguages.
  ///
  /// In en, this message translates to:
  /// **'Active Languages'**
  String get adminStatActiveLanguages;

  /// No description provided for @adminStatTotalLearners.
  ///
  /// In en, this message translates to:
  /// **'Total Learners'**
  String get adminStatTotalLearners;

  /// No description provided for @adminStatPublishedCourses.
  ///
  /// In en, this message translates to:
  /// **'Published Courses'**
  String get adminStatPublishedCourses;

  /// No description provided for @adminStatLessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lessons Completed'**
  String get adminStatLessonsCompleted;

  /// No description provided for @adminLanguageManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Management'**
  String get adminLanguageManagementTitle;

  /// No description provided for @adminAddLanguageButton.
  ///
  /// In en, this message translates to:
  /// **'Add Language'**
  String get adminAddLanguageButton;

  /// No description provided for @adminViewAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'View All Languages'**
  String get adminViewAllLanguages;

  /// No description provided for @adminColLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get adminColLanguage;

  /// No description provided for @adminColCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get adminColCode;

  /// No description provided for @adminColLearners.
  ///
  /// In en, this message translates to:
  /// **'Learners'**
  String get adminColLearners;

  /// No description provided for @adminColCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get adminColCourses;

  /// No description provided for @adminColProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get adminColProgress;

  /// No description provided for @adminColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminColStatus;

  /// No description provided for @adminColActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminColActions;

  /// No description provided for @adminOpenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get adminOpenDashboard;

  /// No description provided for @adminStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatusActive;

  /// No description provided for @adminStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminStatusDraft;

  /// No description provided for @adminAddLanguageNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Bassa)'**
  String get adminAddLanguageNameHint;

  /// No description provided for @adminAddLanguageCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Code (e.g. bas)'**
  String get adminAddLanguageCodeHint;

  /// No description provided for @adminAddLanguageCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get adminAddLanguageCountryHint;

  /// No description provided for @adminLanguageAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Language added. It starts inactive — publish it once its content is ready.'**
  String get adminLanguageAddedMessage;

  /// No description provided for @adminCouldNotAddLanguage.
  ///
  /// In en, this message translates to:
  /// **'Could not add language.'**
  String get adminCouldNotAddLanguage;

  /// No description provided for @adminCourseCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Completion'**
  String get adminCourseCompletionTitle;

  /// No description provided for @adminLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get adminLevelBeginner;

  /// No description provided for @adminLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get adminLevelIntermediate;

  /// No description provided for @adminLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get adminLevelAdvanced;

  /// No description provided for @adminQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get adminQuickActionsTitle;

  /// No description provided for @adminQuickActionCreateCourse.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get adminQuickActionCreateCourse;

  /// No description provided for @adminQuickActionAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get adminQuickActionAddUser;

  /// No description provided for @adminQuickActionUploadContent.
  ///
  /// In en, this message translates to:
  /// **'Upload Content'**
  String get adminQuickActionUploadContent;

  /// No description provided for @adminRecentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get adminRecentActivityTitle;

  /// No description provided for @adminNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get adminNoRecentActivity;

  /// No description provided for @adminViewAllActivity.
  ///
  /// In en, this message translates to:
  /// **'View All Activity'**
  String get adminViewAllActivity;

  /// No description provided for @adminLearnerActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Learner Activity'**
  String get adminLearnerActivityTitle;

  /// No description provided for @adminLegendNewLearners.
  ///
  /// In en, this message translates to:
  /// **'New Learners'**
  String get adminLegendNewLearners;

  /// No description provided for @adminLegendActiveLearners.
  ///
  /// In en, this message translates to:
  /// **'Active Learners'**
  String get adminLegendActiveLearners;

  /// No description provided for @adminNoActivityData.
  ///
  /// In en, this message translates to:
  /// **'No activity data yet.'**
  String get adminNoActivityData;

  /// No description provided for @adminAiContentReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Content Review'**
  String get adminAiContentReviewTitle;

  /// No description provided for @adminAiReviewCountMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} AI-generated lesson drafts are waiting for review'**
  String adminAiReviewCountMessage(int count);

  /// No description provided for @adminReviewContentButton.
  ///
  /// In en, this message translates to:
  /// **'Review Content'**
  String get adminReviewContentButton;

  /// No description provided for @adminSystemNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'System Notice'**
  String get adminSystemNoticeTitle;

  /// No description provided for @adminAllSystemsOperational.
  ///
  /// In en, this message translates to:
  /// **'All systems operational'**
  String get adminAllSystemsOperational;

  /// No description provided for @adminLastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String adminLastUpdatedLabel(String date);

  /// No description provided for @adminAuditVerbCreated.
  ///
  /// In en, this message translates to:
  /// **'created a'**
  String get adminAuditVerbCreated;

  /// No description provided for @adminAuditVerbUpdated.
  ///
  /// In en, this message translates to:
  /// **'updated a'**
  String get adminAuditVerbUpdated;

  /// No description provided for @adminAuditVerbDeleted.
  ///
  /// In en, this message translates to:
  /// **'deleted a'**
  String get adminAuditVerbDeleted;

  /// No description provided for @adminAuditActivityLine.
  ///
  /// In en, this message translates to:
  /// **'{actor} {verb} {entity}'**
  String adminAuditActivityLine(String actor, String verb, String entity);

  /// No description provided for @adminLanguageDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'{language} Dashboard'**
  String adminLanguageDashboardTitle(String language);

  /// No description provided for @adminLanguageDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content and learner activity for {language}.'**
  String adminLanguageDashboardSubtitle(String language);

  /// No description provided for @adminNewCourseButton.
  ///
  /// In en, this message translates to:
  /// **'New Course'**
  String get adminNewCourseButton;

  /// No description provided for @adminStatLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get adminStatLessons;

  /// No description provided for @adminCourseManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Management'**
  String get adminCourseManagementTitle;

  /// No description provided for @adminViewAllCourses.
  ///
  /// In en, this message translates to:
  /// **'View All Courses'**
  String get adminViewAllCourses;

  /// No description provided for @adminColCourseSingle.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get adminColCourseSingle;

  /// No description provided for @adminColLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get adminColLevel;

  /// No description provided for @adminContentWorkflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Workflow'**
  String get adminContentWorkflowTitle;

  /// No description provided for @adminWorkflowDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminWorkflowDraft;

  /// No description provided for @adminWorkflowInReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get adminWorkflowInReview;

  /// No description provided for @adminWorkflowApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminWorkflowApproved;

  /// No description provided for @adminWorkflowPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminWorkflowPublished;

  /// No description provided for @adminContentQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Quality'**
  String get adminContentQualityTitle;

  /// No description provided for @adminQuickActionNewLesson.
  ///
  /// In en, this message translates to:
  /// **'New Lesson'**
  String get adminQuickActionNewLesson;

  /// No description provided for @adminQuickActionNewQuiz.
  ///
  /// In en, this message translates to:
  /// **'New Quiz'**
  String get adminQuickActionNewQuiz;

  /// No description provided for @adminQuickActionTrainAi.
  ///
  /// In en, this message translates to:
  /// **'Train the AI'**
  String get adminQuickActionTrainAi;

  /// No description provided for @adminRecentCertificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Certificates'**
  String get adminRecentCertificatesTitle;

  /// No description provided for @adminNoCertificatesYet.
  ///
  /// In en, this message translates to:
  /// **'No certificates issued yet.'**
  String get adminNoCertificatesYet;

  /// No description provided for @adminCertificateCompletedLine.
  ///
  /// In en, this message translates to:
  /// **'{learner} completed {course}'**
  String adminCertificateCompletedLine(String learner, String course);

  /// No description provided for @adminNnangaAiReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Nnanga AI Review'**
  String get adminNnangaAiReviewTitle;

  /// No description provided for @adminNnangaReviewCountMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} AI-generated {language} lesson drafts are waiting for review'**
  String adminNnangaReviewCountMessage(int count, String language);

  /// No description provided for @adminTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminTabAll;

  /// No description provided for @adminUpdatedCountMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} course(s) updated.'**
  String adminUpdatedCountMessage(int count);

  /// No description provided for @adminCouldNotUpdateCourses.
  ///
  /// In en, this message translates to:
  /// **'Could not update courses.'**
  String get adminCouldNotUpdateCourses;

  /// No description provided for @adminAssignReviewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Reviewer'**
  String get adminAssignReviewerTitle;

  /// No description provided for @adminAssignReviewerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Assign a reviewer to {count} selected course(s).'**
  String adminAssignReviewerPrompt(int count);

  /// No description provided for @adminNoReviewersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teachers or admins available.'**
  String get adminNoReviewersAvailable;

  /// No description provided for @adminReviewerAssignedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reviewer assigned.'**
  String get adminReviewerAssignedMessage;

  /// No description provided for @adminCouldNotAssignReviewer.
  ///
  /// In en, this message translates to:
  /// **'Could not assign reviewer.'**
  String get adminCouldNotAssignReviewer;

  /// No description provided for @adminCourseManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage every course in {language}.'**
  String adminCourseManagementSubtitle(String language);

  /// No description provided for @adminStatTotalCourses.
  ///
  /// In en, this message translates to:
  /// **'Total Courses'**
  String get adminStatTotalCourses;

  /// No description provided for @adminStatDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get adminStatDrafts;

  /// No description provided for @adminSearchCoursesHint.
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get adminSearchCoursesHint;

  /// No description provided for @adminAllLevelsLabel.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get adminAllLevelsLabel;

  /// No description provided for @adminBulkPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get adminBulkPublish;

  /// No description provided for @adminBulkMoveToDraft.
  ///
  /// In en, this message translates to:
  /// **'Move to Draft'**
  String get adminBulkMoveToDraft;

  /// No description provided for @adminBulkArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get adminBulkArchive;

  /// No description provided for @adminColLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get adminColLessons;

  /// No description provided for @adminColReviewer.
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get adminColReviewer;

  /// No description provided for @adminPublishingPipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Publishing Pipeline'**
  String get adminPublishingPipelineTitle;

  /// No description provided for @adminContentHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Health'**
  String get adminContentHealthTitle;

  /// No description provided for @adminRecentCourseActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Course Activity'**
  String get adminRecentCourseActivityTitle;

  /// No description provided for @adminWorkflowArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get adminWorkflowArchived;

  /// No description provided for @adminHealthLessonsPublished.
  ///
  /// In en, this message translates to:
  /// **'Lessons published'**
  String get adminHealthLessonsPublished;

  /// No description provided for @adminHealthLessonsApproved.
  ///
  /// In en, this message translates to:
  /// **'Lessons approved'**
  String get adminHealthLessonsApproved;

  /// No description provided for @adminHealthLessonsInReview.
  ///
  /// In en, this message translates to:
  /// **'Lessons in review'**
  String get adminHealthLessonsInReview;

  /// No description provided for @adminHealthLessonsInDraft.
  ///
  /// In en, this message translates to:
  /// **'Lessons in draft'**
  String get adminHealthLessonsInDraft;

  /// No description provided for @adminWizardStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Course Details'**
  String get adminWizardStepDetails;

  /// No description provided for @adminWizardStepCurriculum.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get adminWizardStepCurriculum;

  /// No description provided for @adminWizardStepResources.
  ///
  /// In en, this message translates to:
  /// **'Learning Resources'**
  String get adminWizardStepResources;

  /// No description provided for @adminWizardStepAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get adminWizardStepAssessment;

  /// No description provided for @adminWizardStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review & Publish'**
  String get adminWizardStepReview;

  /// No description provided for @adminTitleMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters.'**
  String get adminTitleMinLengthError;

  /// No description provided for @adminCourseCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Course created. Continue building it out below.'**
  String get adminCourseCreatedMessage;

  /// No description provided for @adminCouldNotSaveCourse.
  ///
  /// In en, this message translates to:
  /// **'Could not save course.'**
  String get adminCouldNotSaveCourse;

  /// No description provided for @adminLearningResourcesSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Learning resources saved.'**
  String get adminLearningResourcesSavedMessage;

  /// No description provided for @adminCouldNotSaveGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not save.'**
  String get adminCouldNotSaveGeneric;

  /// No description provided for @adminCoverUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cover updated.'**
  String get adminCoverUpdatedMessage;

  /// No description provided for @adminCouldNotUploadCover.
  ///
  /// In en, this message translates to:
  /// **'Could not upload cover.'**
  String get adminCouldNotUploadCover;

  /// No description provided for @adminArchiveCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Course'**
  String get adminArchiveCourseTitle;

  /// No description provided for @adminArchiveCourseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archived courses are hidden from learners but not deleted. Continue?'**
  String get adminArchiveCourseConfirm;

  /// No description provided for @adminCourseArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Course archived.'**
  String get adminCourseArchivedMessage;

  /// No description provided for @adminCouldNotArchiveCourse.
  ///
  /// In en, this message translates to:
  /// **'Could not archive course.'**
  String get adminCouldNotArchiveCourse;

  /// No description provided for @adminCoursePublishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Course published.'**
  String get adminCoursePublishedMessage;

  /// No description provided for @adminCouldNotPublishCourse.
  ///
  /// In en, this message translates to:
  /// **'Could not publish course.'**
  String get adminCouldNotPublishCourse;

  /// No description provided for @adminModuleLessonsFirstError.
  ///
  /// In en, this message translates to:
  /// **'Delete this module\'s lessons first.'**
  String get adminModuleLessonsFirstError;

  /// No description provided for @adminCouldNotAddModule.
  ///
  /// In en, this message translates to:
  /// **'Could not add module.'**
  String get adminCouldNotAddModule;

  /// No description provided for @adminCouldNotUpdateModule.
  ///
  /// In en, this message translates to:
  /// **'Could not update module.'**
  String get adminCouldNotUpdateModule;

  /// No description provided for @adminCouldNotDeleteModule.
  ///
  /// In en, this message translates to:
  /// **'Could not delete module.'**
  String get adminCouldNotDeleteModule;

  /// No description provided for @adminLessonContentMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Lesson content must be at least 10 characters.'**
  String get adminLessonContentMinLengthError;

  /// No description provided for @adminCouldNotAddLesson.
  ///
  /// In en, this message translates to:
  /// **'Could not add lesson.'**
  String get adminCouldNotAddLesson;

  /// No description provided for @adminCouldNotUpdateLesson.
  ///
  /// In en, this message translates to:
  /// **'Could not update lesson.'**
  String get adminCouldNotUpdateLesson;

  /// No description provided for @adminCouldNotDeleteLesson.
  ///
  /// In en, this message translates to:
  /// **'Could not delete lesson.'**
  String get adminCouldNotDeleteLesson;

  /// No description provided for @adminCouldNotMoveLesson.
  ///
  /// In en, this message translates to:
  /// **'Could not move lesson.'**
  String get adminCouldNotMoveLesson;

  /// No description provided for @adminCouldNotReorderLesson.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder lesson.'**
  String get adminCouldNotReorderLesson;

  /// No description provided for @adminAddModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Module'**
  String get adminAddModuleTitle;

  /// No description provided for @adminRenameModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Module'**
  String get adminRenameModuleTitle;

  /// No description provided for @adminAddLessonToTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Lesson to \"{module}\"'**
  String adminAddLessonToTitle(String module);

  /// No description provided for @adminEditLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit \"{lesson}\"'**
  String adminEditLessonTitle(String lesson);

  /// No description provided for @adminFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminFieldTitle;

  /// No description provided for @adminFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminFieldDescription;

  /// No description provided for @adminFieldFrenchTitle.
  ///
  /// In en, this message translates to:
  /// **'French Title'**
  String get adminFieldFrenchTitle;

  /// No description provided for @adminFieldFrenchDescription.
  ///
  /// In en, this message translates to:
  /// **'French Description'**
  String get adminFieldFrenchDescription;

  /// No description provided for @adminFieldSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get adminFieldSummary;

  /// No description provided for @adminFieldContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminFieldContent;

  /// No description provided for @adminFieldFrenchSummary.
  ///
  /// In en, this message translates to:
  /// **'French Summary'**
  String get adminFieldFrenchSummary;

  /// No description provided for @adminFieldFrenchContent.
  ///
  /// In en, this message translates to:
  /// **'French Content'**
  String get adminFieldFrenchContent;

  /// No description provided for @adminCreateCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get adminCreateCourseTitle;

  /// No description provided for @adminEditCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get adminEditCourseTitle;

  /// No description provided for @adminBuildNewCourseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a new course for {language}.'**
  String adminBuildNewCourseSubtitle(String language);

  /// No description provided for @adminThisLanguageFallback.
  ///
  /// In en, this message translates to:
  /// **'This language'**
  String get adminThisLanguageFallback;

  /// No description provided for @adminBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get adminBackButton;

  /// No description provided for @adminSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get adminSavingLabel;

  /// No description provided for @adminCreateAndContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Create & Continue'**
  String get adminCreateAndContinueButton;

  /// No description provided for @adminNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get adminNextButton;

  /// No description provided for @adminCourseCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Cover'**
  String get adminCourseCoverTitle;

  /// No description provided for @adminUploadCoverButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Cover'**
  String get adminUploadCoverButton;

  /// No description provided for @adminUploadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get adminUploadingLabel;

  /// No description provided for @adminGenerateWithAiTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI cover generation is not available yet.'**
  String get adminGenerateWithAiTooltip;

  /// No description provided for @adminGenerateWithAiButton.
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get adminGenerateWithAiButton;

  /// No description provided for @adminPublishingSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Publishing Settings'**
  String get adminPublishingSettingsTitle;

  /// No description provided for @adminVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get adminVisibilityLabel;

  /// No description provided for @adminVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get adminVisibilityPublic;

  /// No description provided for @adminVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get adminVisibilityPrivate;

  /// No description provided for @adminEnrollmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Enrollment'**
  String get adminEnrollmentLabel;

  /// No description provided for @adminEnrollmentOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminEnrollmentOpen;

  /// No description provided for @adminEnrollmentInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'Invite Only'**
  String get adminEnrollmentInviteOnly;

  /// No description provided for @adminIssueCertificateLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Certificate'**
  String get adminIssueCertificateLabel;

  /// No description provided for @adminCourseTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Team'**
  String get adminCourseTeamTitle;

  /// No description provided for @adminInstructorLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get adminInstructorLabel;

  /// No description provided for @adminContentReadinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Readiness'**
  String get adminContentReadinessTitle;

  /// No description provided for @adminReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get adminReadyLabel;

  /// No description provided for @adminDangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get adminDangerZoneTitle;

  /// No description provided for @adminArchiveCourseButton.
  ///
  /// In en, this message translates to:
  /// **'Archive Course'**
  String get adminArchiveCourseButton;

  /// No description provided for @adminSubtitleOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtitle (optional)'**
  String get adminSubtitleOptionalLabel;

  /// No description provided for @adminFrenchTitleOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French Title (optional)'**
  String get adminFrenchTitleOptionalLabel;

  /// No description provided for @adminCategoryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get adminCategoryOptionalLabel;

  /// No description provided for @adminFrenchDescriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French Description (optional)'**
  String get adminFrenchDescriptionOptionalLabel;

  /// No description provided for @adminEstimatedHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Hours'**
  String get adminEstimatedHoursLabel;

  /// No description provided for @adminTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get adminTagsLabel;

  /// No description provided for @adminAddTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag and press enter'**
  String get adminAddTagHint;

  /// No description provided for @adminLearningObjectivesLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning Objectives'**
  String get adminLearningObjectivesLabel;

  /// No description provided for @adminAddObjectiveHint.
  ///
  /// In en, this message translates to:
  /// **'Add an objective and press enter'**
  String get adminAddObjectiveHint;

  /// No description provided for @adminModulesLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Modules & Lessons'**
  String get adminModulesLessonsTitle;

  /// No description provided for @adminNoModulesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No modules yet. Add one to start adding lessons.'**
  String get adminNoModulesYetMessage;

  /// No description provided for @adminLessonsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String adminLessonsCountLabel(int count);

  /// No description provided for @adminRenameModuleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename module'**
  String get adminRenameModuleTooltip;

  /// No description provided for @adminDeleteModuleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete module'**
  String get adminDeleteModuleTooltip;

  /// No description provided for @adminMenuBlockEditor.
  ///
  /// In en, this message translates to:
  /// **'Block Editor'**
  String get adminMenuBlockEditor;

  /// No description provided for @adminMenuMoveToAnotherModule.
  ///
  /// In en, this message translates to:
  /// **'Move to another module'**
  String get adminMenuMoveToAnotherModule;

  /// No description provided for @adminMenuChangePosition.
  ///
  /// In en, this message translates to:
  /// **'Change position'**
  String get adminMenuChangePosition;

  /// No description provided for @adminMenuManageImages.
  ///
  /// In en, this message translates to:
  /// **'Manage images'**
  String get adminMenuManageImages;

  /// No description provided for @adminMenuManageQuiz.
  ///
  /// In en, this message translates to:
  /// **'Manage quiz'**
  String get adminMenuManageQuiz;

  /// No description provided for @adminAddLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Add Lesson'**
  String get adminAddLessonButton;

  /// No description provided for @adminSupportLanguageCodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Support Language Codes'**
  String get adminSupportLanguageCodesLabel;

  /// No description provided for @adminSupportLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. fr, en — press enter'**
  String get adminSupportLanguageHint;

  /// No description provided for @adminPrerequisiteCourseLabel.
  ///
  /// In en, this message translates to:
  /// **'Prerequisite Course'**
  String get adminPrerequisiteCourseLabel;

  /// No description provided for @adminManageQuizFromBuilderMessage.
  ///
  /// In en, this message translates to:
  /// **'Manage each lesson\'s quiz from the existing Quiz Builder.'**
  String get adminManageQuizFromBuilderMessage;

  /// No description provided for @adminAddLessonsFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Add lessons in the Curriculum step first.'**
  String get adminAddLessonsFirstMessage;

  /// No description provided for @adminManageQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Manage Quiz'**
  String get adminManageQuizButton;

  /// No description provided for @adminModulesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} modules'**
  String adminModulesCountLabel(int count);

  /// No description provided for @adminHoursSuffixLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String adminHoursSuffixLabel(int hours);

  /// No description provided for @adminReadinessChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Readiness Checklist'**
  String get adminReadinessChecklistTitle;

  /// No description provided for @adminChecklistCourseDetailsComplete.
  ///
  /// In en, this message translates to:
  /// **'Course details complete'**
  String get adminChecklistCourseDetailsComplete;

  /// No description provided for @adminChecklistLessonsReady.
  ///
  /// In en, this message translates to:
  /// **'Lessons ready ({ready}/{total})'**
  String adminChecklistLessonsReady(int ready, int total);

  /// No description provided for @adminChecklistAssessmentPresent.
  ///
  /// In en, this message translates to:
  /// **'Assessment present'**
  String get adminChecklistAssessmentPresent;

  /// No description provided for @adminChecklistAudioMissing.
  ///
  /// In en, this message translates to:
  /// **'Audio missing on {count} lesson(s)'**
  String adminChecklistAudioMissing(int count);

  /// No description provided for @adminSetPublicationDateButton.
  ///
  /// In en, this message translates to:
  /// **'Set publication date'**
  String get adminSetPublicationDateButton;

  /// No description provided for @adminPublishCourseButton.
  ///
  /// In en, this message translates to:
  /// **'Publish Course'**
  String get adminPublishCourseButton;

  /// No description provided for @adminBlockTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get adminBlockTypeText;

  /// No description provided for @adminBlockTypeDialogue.
  ///
  /// In en, this message translates to:
  /// **'Dialogue'**
  String get adminBlockTypeDialogue;

  /// No description provided for @adminBlockTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get adminBlockTypeAudio;

  /// No description provided for @adminBlockTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get adminBlockTypeImage;

  /// No description provided for @adminBlockTypeVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get adminBlockTypeVocabulary;

  /// No description provided for @adminBlockTypeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get adminBlockTypeQuiz;

  /// No description provided for @adminBlockTypePronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get adminBlockTypePronunciation;

  /// No description provided for @adminBlockTypeExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get adminBlockTypeExercise;

  /// No description provided for @adminBlockTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get adminBlockTypeVideo;

  /// No description provided for @adminAiActionGenerateExamples.
  ///
  /// In en, this message translates to:
  /// **'Generate Examples'**
  String get adminAiActionGenerateExamples;

  /// No description provided for @adminAiActionCreateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get adminAiActionCreateQuiz;

  /// No description provided for @adminAiActionSimplifyContent.
  ///
  /// In en, this message translates to:
  /// **'Simplify Content'**
  String get adminAiActionSimplifyContent;

  /// No description provided for @adminAiActionCheckTranslations.
  ///
  /// In en, this message translates to:
  /// **'Check Translations'**
  String get adminAiActionCheckTranslations;

  /// No description provided for @adminCouldNotAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Could not add block.'**
  String get adminCouldNotAddBlock;

  /// No description provided for @adminRemoveBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Block'**
  String get adminRemoveBlockTitle;

  /// No description provided for @adminRemoveBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this block from the lesson?'**
  String get adminRemoveBlockConfirm;

  /// No description provided for @adminRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminRemoveButton;

  /// No description provided for @adminCouldNotRemoveBlock.
  ///
  /// In en, this message translates to:
  /// **'Could not remove block.'**
  String get adminCouldNotRemoveBlock;

  /// No description provided for @adminCouldNotReorderBlocks.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder blocks.'**
  String get adminCouldNotReorderBlocks;

  /// No description provided for @adminSubmittedForReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Submitted for review.'**
  String get adminSubmittedForReviewMessage;

  /// No description provided for @adminCouldNotSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Could not submit for review.'**
  String get adminCouldNotSubmitForReview;

  /// No description provided for @adminCouldNotPostComment.
  ///
  /// In en, this message translates to:
  /// **'Could not post comment.'**
  String get adminCouldNotPostComment;

  /// No description provided for @adminNnangaNoRespondError.
  ///
  /// In en, this message translates to:
  /// **'Nnanga could not respond.'**
  String get adminNnangaNoRespondError;

  /// No description provided for @adminNnangaSuggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Nnanga suggestion'**
  String get adminNnangaSuggestionLabel;

  /// No description provided for @adminAddedAsTextBlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Added as a new Text block.'**
  String get adminAddedAsTextBlockMessage;

  /// No description provided for @adminCouldNotApplySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Could not apply suggestion.'**
  String get adminCouldNotApplySuggestion;

  /// No description provided for @adminDraftQuestionsAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft questions added to the quiz.'**
  String get adminDraftQuestionsAddedMessage;

  /// No description provided for @adminCouldNotApplyQuizDraft.
  ///
  /// In en, this message translates to:
  /// **'Could not apply quiz draft.'**
  String get adminCouldNotApplyQuizDraft;

  /// No description provided for @adminLessonEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Editor'**
  String get adminLessonEditorTitle;

  /// No description provided for @adminSubmitForReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get adminSubmitForReviewButton;

  /// No description provided for @adminAddBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Block'**
  String get adminAddBlockTitle;

  /// No description provided for @adminNoBlocksYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No blocks yet. Add one from the palette on the left to start authoring this lesson.'**
  String get adminNoBlocksYetMessage;

  /// No description provided for @adminMoveUpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get adminMoveUpTooltip;

  /// No description provided for @adminMoveDownTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get adminMoveDownTooltip;

  /// No description provided for @adminRemoveBlockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove block'**
  String get adminRemoveBlockTooltip;

  /// No description provided for @adminSaveBlockButton.
  ///
  /// In en, this message translates to:
  /// **'Save Block'**
  String get adminSaveBlockButton;

  /// No description provided for @adminEyebrowLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Eyebrow label (optional)'**
  String get adminEyebrowLabelOptional;

  /// No description provided for @adminFrenchContentOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French content (optional)'**
  String get adminFrenchContentOptionalLabel;

  /// No description provided for @adminSpeakerLabel.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get adminSpeakerLabel;

  /// No description provided for @adminLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get adminLineLabel;

  /// No description provided for @adminFrenchLineOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'French line (optional)'**
  String get adminFrenchLineOptionalLabel;

  /// No description provided for @adminAddTurnButton.
  ///
  /// In en, this message translates to:
  /// **'Add Turn'**
  String get adminAddTurnButton;

  /// No description provided for @adminAudioUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio URL'**
  String get adminAudioUrlLabel;

  /// No description provided for @adminUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get adminUploadButton;

  /// No description provided for @adminVideoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get adminVideoUrlLabel;

  /// No description provided for @adminVideoNotVisibleNotice.
  ///
  /// In en, this message translates to:
  /// **'Video is saved but not yet shown to learners — no player exists on the lesson screen yet.'**
  String get adminVideoNotVisibleNotice;

  /// No description provided for @adminWordLabelField.
  ///
  /// In en, this message translates to:
  /// **'Word / label'**
  String get adminWordLabelField;

  /// No description provided for @adminImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get adminImageUrlLabel;

  /// No description provided for @adminCaptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get adminCaptionOptionalLabel;

  /// No description provided for @adminSelectWordHint.
  ///
  /// In en, this message translates to:
  /// **'Select a word'**
  String get adminSelectWordHint;

  /// No description provided for @adminInstructionsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get adminInstructionsOptionalLabel;

  /// No description provided for @adminNoQuizYetNotice.
  ///
  /// In en, this message translates to:
  /// **'No quiz exists for this lesson yet. Create one from the Assessment step, then save this block again.'**
  String get adminNoQuizYetNotice;

  /// No description provided for @adminLinkedToQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'Linked to this lesson\'s quiz.'**
  String get adminLinkedToQuizMessage;

  /// No description provided for @adminExerciseNotVisibleNotice.
  ///
  /// In en, this message translates to:
  /// **'Exercise blocks are saved but not yet rendered to learners — no interactive-exercise widget exists yet.'**
  String get adminExerciseNotVisibleNotice;

  /// No description provided for @adminExerciseDataJsonLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise data (JSON)'**
  String get adminExerciseDataJsonLabel;

  /// No description provided for @adminExerciseInvalidJsonError.
  ///
  /// In en, this message translates to:
  /// **'Exercise content must be valid JSON.'**
  String get adminExerciseInvalidJsonError;

  /// No description provided for @adminCouldNotSaveBlock.
  ///
  /// In en, this message translates to:
  /// **'Could not save block.'**
  String get adminCouldNotSaveBlock;

  /// No description provided for @adminCouldNotUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not upload image.'**
  String get adminCouldNotUploadImage;

  /// No description provided for @adminCouldNotUploadAudio.
  ///
  /// In en, this message translates to:
  /// **'Could not upload audio.'**
  String get adminCouldNotUploadAudio;

  /// No description provided for @adminNnangaAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Nnanga AI Assistant'**
  String get adminNnangaAssistantTitle;

  /// No description provided for @adminNnangaInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional instruction for Nnanga...'**
  String get adminNnangaInstructionHint;

  /// No description provided for @adminThinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get adminThinkingLabel;

  /// No description provided for @adminAskNnangaButton.
  ///
  /// In en, this message translates to:
  /// **'Ask Nnanga'**
  String get adminAskNnangaButton;

  /// No description provided for @adminAddDraftQuestionsButton.
  ///
  /// In en, this message translates to:
  /// **'Add Draft Questions to Quiz'**
  String get adminAddDraftQuestionsButton;

  /// No description provided for @adminApplyAsTextBlockButton.
  ///
  /// In en, this message translates to:
  /// **'Apply as New Text Block'**
  String get adminApplyAsTextBlockButton;

  /// No description provided for @adminContentChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Checklist'**
  String get adminContentChecklistTitle;

  /// No description provided for @adminChecklistTextContent.
  ///
  /// In en, this message translates to:
  /// **'Text content'**
  String get adminChecklistTextContent;

  /// No description provided for @adminChecklistFrenchTranslation.
  ///
  /// In en, this message translates to:
  /// **'French translation'**
  String get adminChecklistFrenchTranslation;

  /// No description provided for @adminChecklistQuizLinked.
  ///
  /// In en, this message translates to:
  /// **'Quiz linked'**
  String get adminChecklistQuizLinked;

  /// No description provided for @adminReviewCollaborationTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & Collaboration'**
  String get adminReviewCollaborationTitle;

  /// No description provided for @adminCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get adminCommentsLabel;

  /// No description provided for @adminNoCommentsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get adminNoCommentsYetMessage;

  /// No description provided for @adminAddCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get adminAddCommentHint;

  /// No description provided for @commonNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get commonNoResults;

  /// No description provided for @adminOverallLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get adminOverallLabel;

  /// No description provided for @adminNavNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminNavNotifications;

  /// No description provided for @adminNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminNotificationsTitle;

  /// No description provided for @adminNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a broadcast to every learner or notify one person directly.'**
  String get adminNotificationsSubtitle;

  /// No description provided for @adminBroadcastCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to All Learners'**
  String get adminBroadcastCardTitle;

  /// No description provided for @adminBroadcastCardDescription.
  ///
  /// In en, this message translates to:
  /// **'This message is sent immediately to every active learner account.'**
  String get adminBroadcastCardDescription;

  /// No description provided for @adminNotifyUserCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify a Specific User'**
  String get adminNotifyUserCardTitle;

  /// No description provided for @adminNotifyUserCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for a user below, then send them a direct notification.'**
  String get adminNotifyUserCardDescription;

  /// No description provided for @adminSearchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get adminSearchUserHint;

  /// No description provided for @adminNoUserSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'No user selected yet.'**
  String get adminNoUserSelectedHint;

  /// No description provided for @adminNotifyRecipientLine.
  ///
  /// In en, this message translates to:
  /// **'To: {name} ({email})'**
  String adminNotifyRecipientLine(String name, String email);

  /// No description provided for @adminNotificationTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminNotificationTitleHint;

  /// No description provided for @adminNotificationMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get adminNotificationMessageHint;

  /// No description provided for @adminSendBroadcastButton.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast'**
  String get adminSendBroadcastButton;

  /// No description provided for @adminSendNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get adminSendNotificationButton;

  /// No description provided for @adminBroadcastSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Broadcast sent to all learners.'**
  String get adminBroadcastSentMessage;

  /// No description provided for @adminCouldNotSendBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Could not send broadcast.'**
  String get adminCouldNotSendBroadcast;

  /// No description provided for @adminNotificationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification sent.'**
  String get adminNotificationSentMessage;

  /// No description provided for @adminCouldNotSendNotification.
  ///
  /// In en, this message translates to:
  /// **'Could not send notification.'**
  String get adminCouldNotSendNotification;

  /// No description provided for @dashboardProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Learning Progress'**
  String get dashboardProgressTitle;

  /// No description provided for @lessonsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons completed'**
  String lessonsCompletedCount(int count);

  /// No description provided for @exploreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreSectionTitle;

  /// No description provided for @exploreSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover, learn, and grow with NdaMinkoaba.'**
  String get exploreSectionSubtitle;

  /// No description provided for @exploreVocabularyDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn new words and enrich your Ewondo vocabulary.'**
  String get exploreVocabularyDescription;

  /// No description provided for @exploreLearnDescription.
  ///
  /// In en, this message translates to:
  /// **'Lessons, exercises, and activities to progress at your own pace.'**
  String get exploreLearnDescription;

  /// No description provided for @exploreBibleDescription.
  ///
  /// In en, this message translates to:
  /// **'Read, listen to, and reflect on the Word of God in Ewondo, French, and English.'**
  String get exploreBibleDescription;

  /// No description provided for @exploreBooksDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore a collection of educational and inspiring books.'**
  String get exploreBooksDescription;

  /// No description provided for @nnangaPromoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Ewondo with your personal AI tutor'**
  String get nnangaPromoSubtitle;

  /// No description provided for @startPracticeButton.
  ///
  /// In en, this message translates to:
  /// **'START PRACTICE'**
  String get startPracticeButton;

  /// No description provided for @phraseOfDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Phrase of the Day'**
  String get phraseOfDayTitle;

  /// No description provided for @learnHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Ewondo'**
  String get learnHubTitle;

  /// No description provided for @learnHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a level and continue your journey.'**
  String get learnHubSubtitle;

  /// No description provided for @dailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoalTitle;

  /// No description provided for @dailyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete 1 lesson today'**
  String get dailyGoalSubtitle;

  /// No description provided for @todaysLessonLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S LESSON'**
  String get todaysLessonLabel;

  /// No description provided for @listenAndRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen and Repeat'**
  String get listenAndRepeatTitle;

  /// No description provided for @tapSpeakerRepeatCaption.
  ///
  /// In en, this message translates to:
  /// **'Tap the speaker, then repeat the phrase.'**
  String get tapSpeakerRepeatCaption;

  /// No description provided for @inConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'In Conversation'**
  String get inConversationTitle;

  /// No description provided for @quickCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Check'**
  String get quickCheckTitle;

  /// No description provided for @voiceMessageSendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send that voice message — please try again.'**
  String get voiceMessageSendError;

  /// No description provided for @practiceModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceModeLabel;

  /// No description provided for @freeConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Free Conversation'**
  String get freeConversationLabel;

  /// No description provided for @explainPromptPrefix.
  ///
  /// In en, this message translates to:
  /// **'Explain: {text}'**
  String explainPromptPrefix(String text);

  /// No description provided for @translatePromptPrefix.
  ///
  /// In en, this message translates to:
  /// **'Translate: {text}'**
  String translatePromptPrefix(String text);

  /// No description provided for @explainActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get explainActionLabel;

  /// No description provided for @translateActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translateActionLabel;

  /// No description provided for @correctionLabel.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correctionLabel;

  /// No description provided for @translationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationLabel;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your Ewondo skills'**
  String get practiceSubtitle;

  /// No description provided for @practiceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading Practice.'**
  String get practiceLoadError;

  /// No description provided for @dailyPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Practice'**
  String get dailyPracticeTitle;

  /// No description provided for @dailyGoalReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal reached!'**
  String get dailyGoalReachedMessage;

  /// No description provided for @minutesToGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes to reach today\'s goal'**
  String minutesToGoalMessage(int minutes);

  /// No description provided for @minutesUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnitLabel;

  /// No description provided for @continuePracticeButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE PRACTICE'**
  String get continuePracticeButton;

  /// No description provided for @smartReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Review'**
  String get smartReviewTitle;

  /// No description provided for @wordsReadyForReview.
  ///
  /// In en, this message translates to:
  /// **'{count} words are ready for review'**
  String wordsReadyForReview(int count);

  /// No description provided for @noWordsDueMessage.
  ///
  /// In en, this message translates to:
  /// **'No words due for review right now'**
  String get noWordsDueMessage;

  /// No description provided for @reviewNowButton.
  ///
  /// In en, this message translates to:
  /// **'REVIEW NOW'**
  String get reviewNowButton;

  /// No description provided for @thisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekTitle;

  /// No description provided for @practiceDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} practice days'**
  String practiceDaysCount(int count);

  /// No description provided for @almostThereTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThereTitle;

  /// No description provided for @completeSessionsForBadge.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} more sessions to earn the {badgeName} badge.'**
  String completeSessionsForBadge(int count, String badgeName);

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @noBadgesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No badges yet.'**
  String get noBadgesYetMessage;

  /// No description provided for @completeMoreForBadge.
  ///
  /// In en, this message translates to:
  /// **'Complete {remaining} more to earn this badge'**
  String completeMoreForBadge(int remaining);

  /// No description provided for @tapToRevealHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToRevealHint;

  /// No description provided for @gradeAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gradeAgainLabel;

  /// No description provided for @gradeHardLabel.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get gradeHardLabel;

  /// No description provided for @gradeGoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGoodLabel;

  /// No description provided for @gradeEasyLabel.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gradeEasyLabel;

  /// No description provided for @smartReviewCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Complete!'**
  String get smartReviewCompleteTitle;

  /// No description provided for @smartReviewCompleteSummary.
  ///
  /// In en, this message translates to:
  /// **'You reviewed {count} words today.'**
  String smartReviewCompleteSummary(int count);

  /// No description provided for @backToPracticeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Practice'**
  String get backToPracticeButton;

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreakLabel;

  /// No description provided for @yourPronunciationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Pronunciation'**
  String get yourPronunciationTitle;

  /// No description provided for @micPermissionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to practice pronunciation.'**
  String get micPermissionRequiredError;

  /// No description provided for @recordingSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit your recording — please try again.'**
  String get recordingSubmitError;

  /// No description provided for @recordingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recordingStatusLabel;

  /// No description provided for @scoringStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Scoring…'**
  String get scoringStatusLabel;

  /// No description provided for @scoredStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Scored'**
  String get scoredStatusLabel;

  /// No description provided for @notScoredStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Not scored'**
  String get notScoredStatusLabel;

  /// No description provided for @readyToRecordStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get readyToRecordStatusLabel;

  /// No description provided for @stopRecordingButton.
  ///
  /// In en, this message translates to:
  /// **'STOP RECORDING'**
  String get stopRecordingButton;

  /// No description provided for @startRecordingButton.
  ///
  /// In en, this message translates to:
  /// **'START RECORDING'**
  String get startRecordingButton;

  /// No description provided for @scoringFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t score that attempt.'**
  String get scoringFailedFallback;
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
