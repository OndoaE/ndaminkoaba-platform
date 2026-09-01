// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get adminQuizBuilderDefaultTitle => 'Lesson Quiz';

  @override
  String get adminQuizBuilderCreateError => 'Could not create quiz.';

  @override
  String get adminQuizBuilderEditQuizTitle => 'Edit Quiz';

  @override
  String get adminQuizBuilderTitleLabel => 'Title';

  @override
  String get adminQuizBuilderDescriptionLabel => 'Description';

  @override
  String get adminQuizBuilderFrenchTitleLabel => 'French Title (optional)';

  @override
  String get adminQuizBuilderFrenchDescriptionLabel =>
      'French Description (optional)';

  @override
  String get adminQuizBuilderPassingScoreLabel => 'Passing Score (%)';

  @override
  String get adminQuizBuilderCancel => 'Cancel';

  @override
  String get adminQuizBuilderSave => 'Save';

  @override
  String get adminQuizBuilderQuizUpdated => 'Quiz updated.';

  @override
  String get adminQuizBuilderUpdateQuizError => 'Could not update quiz.';

  @override
  String get adminQuizBuilderDeleteQuizTitle => 'Delete Quiz';

  @override
  String adminQuizBuilderDeleteQuizConfirm(String title, int count) {
    return 'Delete \"$title\" and all $count question(s)? Learners will no longer be able to complete this lesson via quiz.';
  }

  @override
  String get adminQuizBuilderDelete => 'Delete';

  @override
  String get adminQuizBuilderDeleteQuizError => 'Could not delete quiz.';

  @override
  String get adminQuizBuilderQuestionAdded => 'Question added.';

  @override
  String get adminQuizBuilderAddQuestionError => 'Could not add question.';

  @override
  String get adminQuizBuilderUnknownServerError => 'Unknown server error.';

  @override
  String adminQuizBuilderImportSuccess(int count) {
    return 'Imported $count question(s).';
  }

  @override
  String adminQuizBuilderImportPartial(
    int succeeded,
    int failed,
    String errorSuffix,
  ) {
    return 'Imported $succeeded question(s), $failed failed$errorSuffix.';
  }

  @override
  String get adminQuizBuilderQuestionUpdated => 'Question updated.';

  @override
  String get adminQuizBuilderUpdateQuestionError =>
      'Could not update question.';

  @override
  String get adminQuizBuilderDeleteQuestionError =>
      'Could not delete question.';

  @override
  String get adminQuizBuilderUpdateAnswerKeyError =>
      'Could not update answer key.';

  @override
  String adminQuizBuilderAppBarTitle(String lessonTitle) {
    return 'Quiz — $lessonTitle';
  }

  @override
  String get adminQuizBuilderDefaultLessonTitle => 'Lesson';

  @override
  String get adminQuizBuilderNoQuizYetTitle => 'This lesson has no quiz yet';

  @override
  String get adminQuizBuilderNoQuizYetDescription =>
      'Create one so learners can complete this lesson by passing it.';

  @override
  String get adminQuizBuilderQuizTitleLabel => 'Quiz Title';

  @override
  String get adminQuizBuilderCreateQuizButton => 'Create Quiz';

  @override
  String adminQuizBuilderPassMarkSummary(int score, int count) {
    return 'Pass mark: $score% • $count questions';
  }

  @override
  String get adminQuizBuilderEditQuizInfoTooltip => 'Edit quiz info';

  @override
  String get adminQuizBuilderDeleteQuizTooltip => 'Delete quiz';

  @override
  String get adminQuizBuilderQuestionsHeading => 'Questions';

  @override
  String get adminQuizBuilderPasteQuizButton => 'Paste Quiz';

  @override
  String get adminQuizBuilderAddQuestionButton => 'Add Question';

  @override
  String get adminQuizBuilderNoQuestionsYet =>
      'No questions yet. A quiz needs at least one question before a learner can take it.';

  @override
  String get adminQuizBuilderPasteQuizHint =>
      'Already have a quiz written elsewhere? Use \"Paste Quiz\" above to copy and paste it in and have the questions and choices created for you.';

  @override
  String get adminQuizBuilderEditQuestionTooltip => 'Edit question';

  @override
  String get adminQuizBuilderDeleteQuestionTooltip => 'Delete question';

  @override
  String get adminQuizBuilderNoCorrectAnswerSet =>
      'No correct answer set — tap a choice above to mark it.';

  @override
  String get adminQuizBuilderQuestionTooShortError =>
      'Question text must be at least 5 characters.';

  @override
  String get adminQuizBuilderTooFewChoicesError =>
      'Add at least 2 answer choices.';

  @override
  String get adminQuizBuilderEditQuestionDialogTitle => 'Edit Question';

  @override
  String get adminQuizBuilderQuestionLabel => 'Question';

  @override
  String get adminQuizBuilderExplanationLabel => 'Explanation (optional)';

  @override
  String get adminQuizBuilderFrenchQuestionLabel =>
      'French Question (optional)';

  @override
  String get adminQuizBuilderFrenchExplanationLabel =>
      'French Explanation (optional)';

  @override
  String get adminQuizBuilderChoicesHelper =>
      'Choices — select the correct one';

  @override
  String adminQuizBuilderChoiceHint(int number) {
    return 'Choice $number';
  }

  @override
  String get adminQuizBuilderFrenchOptionalHint => 'French (optional)';

  @override
  String get adminQuizBuilderAddAnotherChoiceButton => 'Add another choice';

  @override
  String get adminQuizBuilderPreviewImportTitle => 'Preview Import';

  @override
  String get adminQuizBuilderParseButton => 'Parse';

  @override
  String get adminQuizBuilderBackButton => 'Back';

  @override
  String adminQuizBuilderImportButton(int count) {
    return 'Import $count Question(s)';
  }

  @override
  String get adminQuizBuilderPasteInstructions =>
      'Paste one or more questions, with a blank line between each question.';

  @override
  String get adminQuizBuilderPasteExample =>
      '1. What is the Ewondo word for \"water\"?\nA) Mendim *\nB) Ayong\nC) Nti\nExplanation: Mendim means water.\n\n2. Next question...\nA) Choice one\nB) Choice two\nAnswer: B';

  @override
  String get adminQuizBuilderPasteFormatHelp =>
      'Mark the correct choice with a trailing * or add an \"Answer: B\" / \"Réponse : B\" line. Add \"FR: ...\" on its own line right after a question or choice for the French translation. Numbered questions with all the answers listed separately at the bottom under a heading \"Answer Key\" (e.g. \"7. B) Parents\") also work.';

  @override
  String get adminQuizBuilderPasteHint => 'Paste your quiz text here…';

  @override
  String adminQuizBuilderDetectedCount(int total, int valid) {
    return '$total question(s) detected — $valid ready to import.';
  }

  @override
  String get adminQuizBuilderNothingToPreview =>
      'Nothing to preview — go back and adjust the pasted text.';

  @override
  String get adminQuizMgmtEditQuizTitle => 'Edit Quiz';

  @override
  String get adminQuizMgmtTitleLabel => 'Title';

  @override
  String get adminQuizMgmtDescriptionLabel => 'Description';

  @override
  String get adminQuizMgmtFrenchTitleLabel => 'French Title (optional)';

  @override
  String get adminQuizMgmtFrenchDescriptionLabel =>
      'French Description (optional)';

  @override
  String get adminQuizMgmtPassingScoreLabel => 'Passing Score (%)';

  @override
  String get adminQuizMgmtCancel => 'Cancel';

  @override
  String get adminQuizMgmtSave => 'Save';

  @override
  String get adminQuizMgmtQuizUpdated => 'Quiz updated.';

  @override
  String get adminQuizMgmtUpdateQuizError => 'Could not update quiz.';

  @override
  String get adminQuizMgmtDeleteQuizTitle => 'Delete Quiz';

  @override
  String adminQuizMgmtDeleteQuizConfirm(String title, int count) {
    return 'Delete \"$title\" and all $count question(s)? This cannot be undone.';
  }

  @override
  String get adminQuizMgmtDelete => 'Delete';

  @override
  String get adminQuizMgmtQuizDeleted => 'Quiz deleted.';

  @override
  String get adminQuizMgmtDeleteQuizError => 'Could not delete quiz.';

  @override
  String get adminQuizMgmtAppBarTitle => 'Quiz Management';

  @override
  String get adminQuizMgmtNewQuizButton => 'New Quiz';

  @override
  String get adminQuizMgmtSearchHint => 'Search quizzes...';

  @override
  String get adminQuizMgmtAllCoursesFilter => 'All Courses';

  @override
  String get adminQuizMgmtNoQuizzesFound => 'No quizzes found.';

  @override
  String adminQuizMgmtQuestionsSummary(int count, int passingScore) {
    return '$count questions • pass $passingScore%';
  }

  @override
  String get adminBibleChapterDefaultVersion => 'ESV';

  @override
  String get adminBibleChapterFileReadError => 'Could not read that file.';

  @override
  String adminBibleChapterFileLoaded(String fileName) {
    return 'Loaded $fileName.';
  }

  @override
  String get adminBibleChapterInvalidChapterError =>
      'Enter a valid chapter number.';

  @override
  String get adminBibleChapterNoVersesFoundError =>
      'No numbered verses found. Paste one verse per line, each starting with its verse number.';

  @override
  String get adminBibleChapterNoUsfmMarkersError =>
      'Could not find any \\v verse markers. Make sure you pasted valid USFM text (e.g. \"\\c 1 \\v 1 In the beginning...\").';

  @override
  String get adminBibleChapterEnterBookNameError => 'Enter a book name.';

  @override
  String get adminBibleChapterNoEwondoVersesError =>
      'No verses with Ewondo text to save — preview the comparison first.';

  @override
  String adminBibleChapterSavedMultiChapters(
    int count,
    int chapterCount,
    String book,
  ) {
    return 'Saved $count verse(s) across $chapterCount chapters of $book.';
  }

  @override
  String adminBibleChapterSavedSingleChapter(int count, String book) {
    return 'Saved $count verse(s) for $book.';
  }

  @override
  String get adminBibleChapterSaveError => 'Could not save chapter.';

  @override
  String get adminBibleChapterDeleteChapterTitle => 'Delete Chapter';

  @override
  String adminBibleChapterDeleteChapterConfirm(
    int count,
    String book,
    int chapter,
    String version,
  ) {
    return 'Delete all $count verse(s) of $book $chapter ($version)?';
  }

  @override
  String get adminBibleChapterCancel => 'Cancel';

  @override
  String get adminBibleChapterDelete => 'Delete';

  @override
  String get adminBibleChapterDeleteError => 'Could not delete chapter.';

  @override
  String get adminBibleChapterUploadFileButton => 'Upload File';

  @override
  String adminBibleChapterChapterHeading(int chapter) {
    return 'Chapter $chapter';
  }

  @override
  String adminBibleChapterVerseCount(int count) {
    return '$count verses';
  }

  @override
  String get adminBibleChapterMissingEwondoText => 'Missing Ewondo text';

  @override
  String get adminBibleChapterMissingEnglishText => 'Missing English text';

  @override
  String get adminBibleChapterMissingFrenchText => 'Missing French text';

  @override
  String get adminBibleChapterDefaultLanguageName => 'Language';

  @override
  String get adminBibleChapterTitle => 'Bible Management';

  @override
  String adminBibleChapterSubtitle(String title) {
    return 'Bible chapters and verses for $title';
  }

  @override
  String get adminBibleChapterUsfmModeInstructions =>
      'Upload (or paste) an entire book\'s USFM in Ewondo alongside its English (ESV) USFM. Chapters and verses are detected automatically from the \\c and \\v markers and matched verse by verse.';

  @override
  String get adminBibleChapterManualModeInstructions =>
      'Paste a full chapter in Ewondo (New Testament) alongside its English (ESV) translation. Each is matched verse by verse so Nnanga learns accurate, side-by-side translations.';

  @override
  String get adminBibleChapterSingleChapterOption => 'Single Chapter';

  @override
  String get adminBibleChapterUsfmWholeBookOption => 'USFM (Whole Book)';

  @override
  String get adminBibleChapterBookDetailsTitle => 'Book Details';

  @override
  String get adminBibleChapterChapterDetailsTitle => 'Chapter Details';

  @override
  String get adminBibleChapterAutoFilledHint =>
      'Auto-filled from the USFM \\h/\\mt1 title once previewed — edit if needed.';

  @override
  String get adminBibleChapterBookLabel => 'Book';

  @override
  String get adminBibleChapterChapterLabel => 'Chapter';

  @override
  String get adminBibleChapterVersionLabel => 'Version';

  @override
  String get adminBibleChapterEwondoUsfmLabel => 'Ewondo USFM (entire book)';

  @override
  String get adminBibleChapterEwondoChapterLabel => 'Ewondo Chapter Text';

  @override
  String get adminBibleChapterUploadOrPasteHelper =>
      'Upload a .usfm/.sfm/.txt file, or paste the text directly.';

  @override
  String get adminBibleChapterOneVersePerLineHelper =>
      'One verse per line, each starting with its verse number.';

  @override
  String get adminBibleChapterEwondoUsfmHintExample =>
      '\\id JHN\n\\h John\n\\c 1\n\\v 1 Kiki avele, Nkobo a nga bo...\n\\v 2 ...';

  @override
  String get adminBibleChapterManualHintExample =>
      '1 In the beginning was the Word...\n2 He was in the beginning with God...';

  @override
  String get adminBibleChapterEnglishUsfmLabel =>
      'English USFM (entire book, ESV)';

  @override
  String get adminBibleChapterEnglishChapterLabel =>
      'English Chapter Text (ESV)';

  @override
  String get adminBibleChapterEnglishUsfmHintExample =>
      '\\id JHN\n\\h John\n\\c 1\n\\v 1 In the beginning was the Word...\n\\v 2 ...';

  @override
  String get adminBibleChapterFrenchUsfmLabel =>
      'French USFM (entire book, optional)';

  @override
  String get adminBibleChapterFrenchChapterLabel =>
      'French Chapter Text (optional)';

  @override
  String get adminBibleChapterFrenchUsfmHintExample =>
      '\\id JHN\n\\h Jean\n\\c 1\n\\v 1 Au commencement était la Parole...\n\\v 2 ...';

  @override
  String get adminBibleChapterFrenchManualHintExample =>
      '1 Au commencement était la Parole...\n2 Elle était au commencement avec Dieu...';

  @override
  String get adminBibleChapterPreviewButton =>
      'Preview Verse-by-Verse Comparison';

  @override
  String get adminBibleChapterComparisonTitle => 'Verse-by-Verse Comparison';

  @override
  String adminBibleChapterVersesAcrossChapters(
    int verseCount,
    int chapterCount,
  ) {
    return '$verseCount verses across $chapterCount chapter(s)';
  }

  @override
  String get adminBibleChapterSaveBookButton => 'Save Book';

  @override
  String get adminBibleChapterSaveChapterButton => 'Save Chapter';

  @override
  String get adminBibleChapterSavedChaptersHeading => 'Saved Chapters';

  @override
  String get adminBibleChapterEmptyTitle => 'No chapters yet';

  @override
  String get adminBibleChapterEmptyMessage =>
      'Paste and save a chapter above to see it here.';

  @override
  String get adminBibleChapterDeleteChapterTooltip => 'Delete chapter';

  @override
  String get adminLessonEditorTabInfo => 'Lesson Info';

  @override
  String get adminLessonEditorTabContent => 'Content';

  @override
  String get adminLessonEditorTabActivities => 'Activities';

  @override
  String get adminLessonEditorTabQuiz => 'Quiz';

  @override
  String get adminLessonEditorTabResources => 'Resources';

  @override
  String get adminLessonEditorTabSettings => 'Settings';

  @override
  String get adminLessonEditorSavedInfoMessage => 'Lesson info saved.';

  @override
  String get adminLessonEditorCouldNotSaveInfo => 'Could not save lesson info.';

  @override
  String get adminLessonEditorDraftSavedMessage => 'Draft saved.';

  @override
  String get adminLessonEditorCouldNotSaveDraft => 'Could not save draft.';

  @override
  String get adminLessonEditorPublishedMessage => 'Lesson published.';

  @override
  String get adminLessonEditorCouldNotPublish => 'Could not publish lesson.';

  @override
  String get adminLessonEditorAppBarTitle => 'Edit Lesson';

  @override
  String get adminLessonEditorPreviewLearnerViewButton =>
      'Preview (Learner View)';

  @override
  String get adminLessonEditorSaveDraftButton => 'Save Draft';

  @override
  String get adminLessonEditorPublishingLabel => 'Publishing…';

  @override
  String get adminLessonEditorPublishLessonButton => 'Publish Lesson';

  @override
  String get adminLessonEditorLessonInfoSectionTitle => 'Lesson Information';

  @override
  String get adminLessonEditorLessonTitleLabel => 'Lesson Title';

  @override
  String get adminLessonEditorShortDescriptionLabel => 'Short Description';

  @override
  String get adminLessonEditorLessonCategoryLabel => 'Lesson Category';

  @override
  String get adminLessonEditorLevelLabel => 'Level';

  @override
  String get adminLessonEditorEstimatedTimeLabel => 'Estimated Time (min)';

  @override
  String get adminLessonEditorOrderLabel => 'Order';

  @override
  String get adminLessonEditorCoverImageSectionTitle => 'Lesson Cover / Image';

  @override
  String get adminLessonEditorCoverImageHint =>
      'This image will appear on the learner view.';

  @override
  String get adminLessonEditorChangeImageButton => 'Change Image';

  @override
  String get adminLessonEditorRemoveImageButton => 'Remove Image';

  @override
  String get adminLessonEditorLearningObjectivesLabel =>
      'Learning Objectives (one per line)';

  @override
  String get adminLessonEditorOutcomesLabel =>
      'What Learners Will Learn (one per line)';

  @override
  String get adminLessonEditorNoActivitiesYetMessage => 'No activities yet.';

  @override
  String get adminLessonEditorNoQuizYetMessage =>
      'This lesson has no quiz yet.';

  @override
  String get adminLessonEditorHasQuizMessage =>
      'This lesson has a quiz linked to it.';

  @override
  String get adminLessonEditorResourcesDescription =>
      'Illustrated word images attached to this lesson. Add or remove per-word images from the dedicated Images screen.';

  @override
  String get adminLessonEditorManageLessonImagesButton =>
      'Manage Lesson Images';

  @override
  String get adminLessonEditorSettingsDescription =>
      'Reviewer assignment and comments are in the panel on the right.';

  @override
  String get adminLessonEditorLessonSummaryCardTitle => 'Lesson Summary';

  @override
  String get adminLessonEditorLessonIdLabel => 'Lesson ID';

  @override
  String get adminLessonEditorCreatedLabel => 'Created';

  @override
  String get adminLessonEditorLastUpdatedLabel => 'Last Updated';

  @override
  String get adminLessonEditorImagePreviewCardTitle =>
      'Lesson Image Preview (Learner View)';

  @override
  String get adminLessonEditorTipsCardTitle => 'Tips';

  @override
  String get adminLessonEditorTip1 =>
      'Use high quality images (1280x720 recommended)';

  @override
  String get adminLessonEditorTip2 => 'Images make lessons more engaging';

  @override
  String get adminLessonEditorTip3 =>
      'You can add multiple images in the content';

  @override
  String get adminLessonEditorTip4 => 'Keep lessons focused and interactive';

  @override
  String get adminLessonEditorUrlHint => 'https://...';

  @override
  String get adminLessonEditorInsertButton => 'Insert';

  @override
  String get adminLessonEditorEmbedUrlDialogTitle => 'Embed URL';

  @override
  String get adminLessonMgmtFrenchSummaryOptionalLabel =>
      'French Summary (optional)';

  @override
  String get adminLessonMgmtFrenchContentOptionalLabel =>
      'French Content (optional)';

  @override
  String get adminLessonMgmtConversationHelpText =>
      'In Conversation (optional) — one line per turn: \"Speaker: Text || French text\"';

  @override
  String get adminLessonMgmtConversationLabel => 'Conversation';

  @override
  String get adminLessonMgmtConversationHint =>
      'Amina: Mbolo, wa nga zu na? || Bonjour, comment vas-tu ?';

  @override
  String get adminLessonMgmtDeleteLessonTitle => 'Delete Lesson';

  @override
  String adminLessonMgmtDeleteConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String adminLessonMgmtDeleteConfirmWithQuiz(String title) {
    return 'Delete \"$title\"? Its quiz must be deleted first (from Quiz Management).';
  }

  @override
  String get adminLessonMgmtUpdatedMessage => 'Lesson updated.';

  @override
  String get adminLessonMgmtMovedMessage => 'Lesson moved.';

  @override
  String get adminLessonMgmtReorderedMessage => 'Lesson reordered.';

  @override
  String get adminLessonMgmtDeletedMessage => 'Lesson deleted.';

  @override
  String get adminLessonMgmtAppBarTitle => 'Lesson Management';

  @override
  String get adminLessonMgmtSearchHint => 'Search lessons...';

  @override
  String get adminLessonMgmtAllCoursesFilter => 'All Courses';

  @override
  String get adminLessonMgmtNoLessonsFoundMessage => 'No lessons found.';

  @override
  String adminLessonMgmtLessonRowTitle(int number, String title) {
    return 'Lesson $number: $title';
  }

  @override
  String get moveLessonDialogTitle => 'Move Lesson';

  @override
  String get moveLessonDialogDestinationCourseLabel => 'Destination course';

  @override
  String get moveLessonDialogDestinationModuleLabel => 'Destination module';

  @override
  String get moveLessonDialogAlreadyInModuleMessage =>
      'This lesson is already in that module.';

  @override
  String get moveLessonDialogMoveButton => 'Move';

  @override
  String get reorderLessonDialogTitle => 'Change Lesson Position';

  @override
  String reorderLessonDialogNewPositionLabel(int currentPosition) {
    return 'New position (currently Lesson $currentPosition)';
  }

  @override
  String get reorderLessonDialogMoveButton => 'Move';

  @override
  String get adminUsersCouldNotUpdateUser => 'Could not update user.';

  @override
  String get adminUsersCouldNotUpdateRole => 'Could not update role.';

  @override
  String get adminUsersDeleteUserTitle => 'Delete User';

  @override
  String adminUsersDeleteConfirm(String name) {
    return 'Permanently delete $name? This cannot be undone. Users with existing courses, progress, or other linked records cannot be deleted — deactivate them instead.';
  }

  @override
  String get adminUsersCancel => 'Cancel';

  @override
  String get adminUsersDelete => 'Delete';

  @override
  String get adminUsersCouldNotDeleteUser => 'Could not delete user.';

  @override
  String get adminUsersTitle => 'Users';

  @override
  String adminUsersSubtitle(int count) {
    return '$count total';
  }

  @override
  String get adminUsersNewUser => 'New User';

  @override
  String get adminUsersSearchHint => 'Search by name or email...';

  @override
  String get adminUsersActive => 'Active';

  @override
  String get adminUsersDeactivated => 'Deactivated';

  @override
  String get adminUsersDeactivateAction => 'Deactivate';

  @override
  String get adminUsersActivateAction => 'Activate';

  @override
  String get adminUsersMakeAdminAction => 'Make Administrator';

  @override
  String get adminUsersMakeTeacherAction => 'Make Teacher';

  @override
  String get adminUsersMakeLearnerAction => 'Make Learner';

  @override
  String get adminUsersThisIsYourAccount => 'This is your account';

  @override
  String get adminVocabMgmtTitle => 'Vocabulary Management';

  @override
  String get adminVocabMgmtCouldNotDeleteWord => 'Could not delete word.';

  @override
  String get adminVocabMgmtWordAdded => 'Knowledge entry added.';

  @override
  String get adminVocabMgmtCouldNotAddWord => 'Could not add word.';

  @override
  String get adminVocabMgmtUnknownServerError => 'Unknown server error.';

  @override
  String adminVocabMgmtImportedWords(int count) {
    return 'Imported $count word(s).';
  }

  @override
  String adminVocabMgmtImportedWordsWithFailures(int succeeded, int failed) {
    return 'Imported $succeeded word(s), $failed failed';
  }

  @override
  String get adminVocabMgmtWordUpdated => 'Knowledge entry updated.';

  @override
  String get adminVocabMgmtCouldNotUpdateWord => 'Could not update word.';

  @override
  String get adminVocabMgmtCouldNotDeleteText => 'Could not delete text.';

  @override
  String get adminVocabMgmtTextAdded => 'Text & translation added.';

  @override
  String get adminVocabMgmtCouldNotAddText => 'Could not add text.';

  @override
  String get adminVocabMgmtTextUpdated => 'Text & translation updated.';

  @override
  String get adminVocabMgmtCouldNotUpdateText => 'Could not update text.';

  @override
  String get adminVocabMgmtAddTextAction => 'Add Text & Translation';

  @override
  String get adminVocabMgmtPasteVocabularyAction => 'Paste Vocabulary';

  @override
  String get adminVocabMgmtAddKnowledgeAction => 'Add Knowledge';

  @override
  String get adminVocabMgmtKnowledgeBaseDescription =>
      'This is Nnanga\'s knowledge base. It searches these words and their lessons to answer learners — the more you add, the better it answers.';

  @override
  String get adminVocabMgmtSearchHint => 'Search knowledge...';

  @override
  String get adminVocabMgmtAllLevels => 'All Levels';

  @override
  String get adminVocabMgmtEmptyState =>
      'No knowledge found. Use \"Paste Vocabulary\" below to add a whole word list at once, or \"Add Knowledge\" for a single word.';

  @override
  String get adminVocabMgmtTextsSectionTitle => 'Texts & Translations';

  @override
  String adminVocabMgmtEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get adminVocabMgmtEditTooltip => 'Edit';

  @override
  String get adminVocabMgmtDeleteTooltip => 'Delete';

  @override
  String get adminVocabMgmtVocabularySectionTitle => 'Vocabulary';

  @override
  String adminVocabMgmtWordsCount(int count) {
    return '$count words';
  }

  @override
  String get adminVocabMgmtEditAction => 'Edit';

  @override
  String get adminVocabMgmtDeleteAction => 'Delete';

  @override
  String get adminVocabMgmtEditKnowledgeEntryTitle => 'Edit Knowledge Entry';

  @override
  String get adminVocabMgmtAddKnowledgeEntryTitle => 'Add Knowledge Entry';

  @override
  String get adminVocabMgmtEwondoWordLabel => 'Ewondo word or phrase';

  @override
  String get adminVocabMgmtExampleSentenceLabel => 'Example sentence';

  @override
  String get adminVocabMgmtPhoneticLabel => 'Phonetic transcription (optional)';

  @override
  String get adminVocabMgmtPhoneticHint =>
      'e.g. mbɔ́lɔ́ — shown under the word on the lesson screen';

  @override
  String get adminVocabMgmtPronunciationAudioLabel =>
      'Pronunciation audio (helps Nnanga\'s \"hear it\" playback for learners)';

  @override
  String get adminVocabMgmtEnglishMeaningLabel => 'English meaning';

  @override
  String get adminVocabMgmtEnglishTranslationLabel => 'English translation';

  @override
  String get adminVocabMgmtFrenchMeaningLabel => 'French meaning';

  @override
  String get adminVocabMgmtFrenchTranslationLabel => 'French translation';

  @override
  String get adminVocabMgmtDifficultyLabel => 'Difficulty';

  @override
  String get adminVocabMgmtCancel => 'Cancel';

  @override
  String get adminVocabMgmtSave => 'Save';

  @override
  String get adminVocabMgmtAdd => 'Add';

  @override
  String get adminVocabMgmtEditTextEntryTitle => 'Edit Text & Translation';

  @override
  String get adminVocabMgmtAddTextEntryTitle => 'Add Text & Translation';

  @override
  String get adminVocabMgmtEwondoTextLabel => 'Ewondo text';

  @override
  String get adminVocabMgmtTranslationLabel => 'Translation';

  @override
  String get adminVocabMgmtPasteVocabularyTitle => 'Paste Vocabulary';

  @override
  String get adminVocabMgmtPreviewImportTitle => 'Preview Import';

  @override
  String get adminVocabMgmtParseAction => 'Parse';

  @override
  String get adminVocabMgmtBackAction => 'Back';

  @override
  String adminVocabMgmtImportWordsAction(int count) {
    return 'Import $count Word(s)';
  }

  @override
  String get adminVocabMgmtPasteInstructions =>
      'Paste a word list — one per line, or a blank line between richer entries.';

  @override
  String get adminVocabMgmtPasteFormatHelp =>
      'Simple lines: \"word | English meaning | French meaning\" (meanings optional). Or spell it out over several lines with EN:, FR:, Example:, Example EN:, Example FR:, Phonetic:, and Level: — only the word itself is required.';

  @override
  String get adminVocabMgmtPasteFieldHint => 'Paste your word list here…';

  @override
  String adminVocabMgmtWordsDetectedSummary(int total, int validCount) {
    return '$total word(s) detected — $validCount ready to import.';
  }

  @override
  String get adminVocabMgmtNothingToPreview =>
      'Nothing to preview — go back and adjust the pasted text.';

  @override
  String get adminDailyMgmtDailyWordAdded => 'Daily word added.';

  @override
  String get adminDailyMgmtCouldNotAddDailyWord => 'Could not add daily word.';

  @override
  String get adminDailyMgmtDailyWordUpdated => 'Daily word updated.';

  @override
  String get adminDailyMgmtCouldNotUpdateDailyWord =>
      'Could not update daily word.';

  @override
  String get adminDailyMgmtCouldNotDeleteDailyWord =>
      'Could not delete daily word.';

  @override
  String get adminDailyMgmtDailyVerseAdded => 'Daily verse added.';

  @override
  String get adminDailyMgmtCouldNotAddDailyVerse =>
      'Could not add daily verse.';

  @override
  String get adminDailyMgmtDailyVerseUpdated => 'Daily verse updated.';

  @override
  String get adminDailyMgmtCouldNotUpdateDailyVerse =>
      'Could not update daily verse.';

  @override
  String get adminDailyMgmtCouldNotDeleteDailyVerse =>
      'Could not delete daily verse.';

  @override
  String get adminDailyMgmtLanguageFallback => 'Language';

  @override
  String get adminDailyMgmtTitle => 'Phrase & Verse of the Day';

  @override
  String adminDailyMgmtSubtitle(String language) {
    return 'Rotating daily word/verse pools for $language';
  }

  @override
  String get adminDailyMgmtAddDailyWordAction => 'Add Daily Word';

  @override
  String get adminDailyMgmtAddDailyVerseAction => 'Add Daily Verse';

  @override
  String get adminDailyMgmtDescription =>
      'A different entry from each pool is shown automatically every day on the learner dashboard — no need to pick \"today\'s\" item by hand.';

  @override
  String get adminDailyMgmtDailyWordsChip => 'Daily Words';

  @override
  String get adminDailyMgmtDailyVersesChip => 'Daily Verses';

  @override
  String get adminDailyMgmtSearchWordsHint => 'Search Ewondo words...';

  @override
  String get adminDailyMgmtSearchVersesHint => 'Search verses or reference...';

  @override
  String get adminDailyMgmtNoDailyWordsTitle => 'No daily words yet';

  @override
  String get adminDailyMgmtNoDailyWordsMessage =>
      'Add Ewondo words to rotate through on the learner dashboard.';

  @override
  String get adminDailyMgmtEditAction => 'Edit';

  @override
  String get adminDailyMgmtDeleteAction => 'Delete';

  @override
  String get adminDailyMgmtNoDailyVersesTitle => 'No daily verses yet';

  @override
  String get adminDailyMgmtNoDailyVersesMessage =>
      'Add Ewondo Bible verses to rotate through on the learner dashboard.';

  @override
  String get adminDailyMgmtEditDailyWordTitle => 'Edit Daily Word';

  @override
  String get adminDailyMgmtAddDailyWordTitle => 'Add Daily Word';

  @override
  String get adminDailyMgmtEwondoWordLabel => 'Ewondo word';

  @override
  String get adminDailyMgmtEnglishMeaningLabel => 'English meaning';

  @override
  String get adminDailyMgmtFrenchMeaningLabel => 'French meaning';

  @override
  String get adminDailyMgmtUsageHintLabel => 'Usage hint (optional)';

  @override
  String get adminDailyMgmtCancel => 'Cancel';

  @override
  String get adminDailyMgmtSave => 'Save';

  @override
  String get adminDailyMgmtAdd => 'Add';

  @override
  String get adminDailyMgmtEditDailyVerseTitle => 'Edit Daily Verse';

  @override
  String get adminDailyMgmtAddDailyVerseTitle => 'Add Daily Verse';

  @override
  String get adminDailyMgmtReferenceLabel => 'Reference (e.g. Yoannes 3:16)';

  @override
  String get adminDailyMgmtEwondoTextLabel => 'Ewondo text';

  @override
  String get adminDailyMgmtEnglishTranslationLabel => 'English translation';

  @override
  String get adminDailyMgmtFrenchTranslationLabel => 'French translation';

  @override
  String get adminDailyMgmtCouldNotLoadVocabulary =>
      'Could not load vocabulary.';

  @override
  String get adminDailyMgmtPickVocabularyWordTitle => 'Pick a Vocabulary word';

  @override
  String get adminDailyMgmtSearchLabel => 'Search';

  @override
  String get adminDailyMgmtSomethingWentWrong => 'Something went wrong';

  @override
  String get adminDailyMgmtNoVocabularyYetTitle => 'No vocabulary yet';

  @override
  String get adminDailyMgmtNoVocabularyYetMessage =>
      'Add words in Vocabulary Management first.';

  @override
  String get adminDailyMgmtCouldNotLoadBibleChapters =>
      'Could not load Bible chapters.';

  @override
  String get adminDailyMgmtCouldNotLoadVerses => 'Could not load verses.';

  @override
  String get adminDailyMgmtPickChapterTitle => 'Pick a chapter';

  @override
  String get adminDailyMgmtNoBibleContentYetTitle => 'No Bible content yet';

  @override
  String get adminDailyMgmtNoBibleContentYetMessage =>
      'Add chapters in Bible Management first.';

  @override
  String get adminDailyMgmtNoVersesYetTitle => 'No verses yet';

  @override
  String get adminDailyMgmtNoVersesYetMessage => 'This chapter has no verses.';

  @override
  String get adminDailyMgmtBackAction => 'Back';

  @override
  String adminDailyMgmtVerseCount(int count) {
    return '$count verses';
  }

  @override
  String adminDailyMgmtVerseNumber(int number) {
    return 'Verse $number';
  }

  @override
  String get adminBookMgmtAddBook => 'Add Book';

  @override
  String get adminBookMgmtAddError => 'Could not add book.';

  @override
  String get adminBookMgmtCancel => 'Cancel';

  @override
  String get adminBookMgmtCategoryAll => 'All';

  @override
  String get adminBookMgmtCreate => 'Create';

  @override
  String get adminBookMgmtDelete => 'Delete';

  @override
  String adminBookMgmtDeleteBody(String title) {
    return '\"$title\" will be removed for every learner.';
  }

  @override
  String get adminBookMgmtDeleteError => 'Could not delete book.';

  @override
  String get adminBookMgmtDeleteTitle => 'Delete book?';

  @override
  String get adminBookMgmtDeletedMessage => 'Book deleted.';

  @override
  String get adminBookMgmtEdit => 'Edit';

  @override
  String get adminBookMgmtEmptyMessage =>
      'Tap \"Add Book\" to create the first one.';

  @override
  String get adminBookMgmtEmptyTitle => 'No books yet';

  @override
  String get adminBookMgmtErrorTitle => 'Something went wrong';

  @override
  String get adminBookMgmtLanguageFallback => 'Language';

  @override
  String get adminBookMgmtLoadError => 'Could not load books.';

  @override
  String get adminBookMgmtNoContent => 'No content yet';

  @override
  String adminBookMgmtPagesCount(int count) {
    return '$count pages';
  }

  @override
  String get adminBookMgmtSearchLabel => 'Search books';

  @override
  String adminBookMgmtSubtitle(String title) {
    return 'Books for $title';
  }

  @override
  String get adminBookMgmtTitle => 'Book Management';

  @override
  String get adminBookMgmtTitleLabel => 'Title';

  @override
  String get adminLangMgmtAdd => 'Add';

  @override
  String get adminLangMgmtAddError => 'Could not add language.';

  @override
  String get adminLangMgmtAddTitle => 'Add Language';

  @override
  String get adminLangMgmtAddedMessage =>
      'Language added. It starts as a draft — publish it once its content is ready.';

  @override
  String get adminLangMgmtCancel => 'Cancel';

  @override
  String get adminLangMgmtCodeLabel => 'Code (e.g. bas)';

  @override
  String get adminLangMgmtCountryLabel => 'Country (optional)';

  @override
  String get adminLangMgmtDelete => 'Delete';

  @override
  String adminLangMgmtDeleteBody(String name) {
    return '\"$name\" will be permanently removed. This only works if it has no courses yet.';
  }

  @override
  String get adminLangMgmtDeleteError => 'Could not delete language.';

  @override
  String get adminLangMgmtDeleteTitle => 'Delete language?';

  @override
  String get adminLangMgmtDeletedMessage => 'Language deleted.';

  @override
  String get adminLangMgmtDraft => 'Draft';

  @override
  String get adminLangMgmtEmptyMessage =>
      'Tap \"Add Language\" to create the first one.';

  @override
  String get adminLangMgmtEmptyTitle => 'No languages yet';

  @override
  String get adminLangMgmtErrorTitle => 'Something went wrong';

  @override
  String get adminLangMgmtLoadError => 'Could not load languages.';

  @override
  String get adminLangMgmtNameLabel => 'Name (e.g. Bassa)';

  @override
  String get adminLangMgmtPublished => 'Published';

  @override
  String adminLangMgmtSubtitleCount(int count) {
    return '$count total';
  }

  @override
  String get adminLangMgmtTitle => 'Languages';

  @override
  String get adminLangMgmtUpdateError => 'Could not update language.';

  @override
  String get adminLessonImagesAdd => 'Add';

  @override
  String get adminLessonImagesAddError => 'Could not add image.';

  @override
  String get adminLessonImagesAddImage => 'Add Image';

  @override
  String get adminLessonImagesAddedMessage => 'Image added.';

  @override
  String get adminLessonImagesCancel => 'Cancel';

  @override
  String get adminLessonImagesCaptionLabel => 'Caption (optional)';

  @override
  String get adminLessonImagesDelete => 'Delete';

  @override
  String adminLessonImagesDeleteBody(String word) {
    return 'Remove the image for \"$word\"?';
  }

  @override
  String get adminLessonImagesDeleteTitle => 'Delete Image';

  @override
  String get adminLessonImagesDialogTitle => 'Illustrate a Word';

  @override
  String get adminLessonImagesEmptyMessage =>
      'Add an image to illustrate a word in this lesson.';

  @override
  String get adminLessonImagesEmptyTitle => 'No images yet';

  @override
  String get adminLessonImagesIntro =>
      'Add images to illustrate words from this lesson. Add as many as you like.';

  @override
  String get adminLessonImagesRemoveError => 'Could not remove image.';

  @override
  String get adminLessonImagesRemovedMessage => 'Image removed.';

  @override
  String get adminLessonImagesTitleFallback => 'Lesson Images';

  @override
  String adminLessonImagesTitleWithLesson(String lesson) {
    return 'Images — $lesson';
  }

  @override
  String get adminLessonImagesWordLabel => 'Word this illustrates';

  @override
  String get adminModuleMgmtAllCourses => 'All Courses';

  @override
  String get adminModuleMgmtAppBarTitle => 'Module Management';

  @override
  String get adminModuleMgmtCancel => 'Cancel';

  @override
  String get adminModuleMgmtCourseLabel => 'Course';

  @override
  String adminModuleMgmtCourseLessonsSummary(String course, int count) {
    return '$course • $count lessons';
  }

  @override
  String get adminModuleMgmtCreate => 'Create';

  @override
  String get adminModuleMgmtCreateCourseFirst => 'Create a course first.';

  @override
  String get adminModuleMgmtCreateError => 'Could not create module.';

  @override
  String get adminModuleMgmtCreatedMessage => 'Module created.';

  @override
  String get adminModuleMgmtDelete => 'Delete';

  @override
  String adminModuleMgmtDeleteBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get adminModuleMgmtDeleteError => 'Could not delete module.';

  @override
  String adminModuleMgmtDeleteLessonsFirst(int count) {
    return 'Delete this module\'s $count lesson(s) first.';
  }

  @override
  String get adminModuleMgmtDeleteTitle => 'Delete Module';

  @override
  String get adminModuleMgmtDeletedMessage => 'Module deleted.';

  @override
  String get adminModuleMgmtDescriptionLabel => 'Description';

  @override
  String get adminModuleMgmtEditTitle => 'Edit Module';

  @override
  String get adminModuleMgmtFrenchDescriptionLabel =>
      'French Description (optional)';

  @override
  String get adminModuleMgmtFrenchTitleLabel => 'French Title (optional)';

  @override
  String get adminModuleMgmtNewModule => 'New Module';

  @override
  String get adminModuleMgmtNoModulesFound => 'No modules found.';

  @override
  String get adminModuleMgmtSave => 'Save';

  @override
  String get adminModuleMgmtSearchHint => 'Search modules...';

  @override
  String get adminModuleMgmtTitleLabel => 'Title';

  @override
  String get adminModuleMgmtUpdateError => 'Could not update module.';

  @override
  String get adminModuleMgmtUpdatedMessage => 'Module updated.';

  @override
  String get adminProfileAccountDetails => 'Account Details';

  @override
  String get adminProfileAccountStatus => 'Account Status';

  @override
  String get adminProfileActive => 'Active';

  @override
  String get adminProfileAdministratorRole => 'Administrator';

  @override
  String get adminProfileDeactivated => 'Deactivated';

  @override
  String get adminProfileEditProfileLabel => 'Edit Profile';

  @override
  String get adminProfileFullNameLabel => 'Full Name';

  @override
  String get adminProfileLastLogin => 'Last Login';

  @override
  String get adminProfileLogOut => 'Log Out';

  @override
  String get adminProfileMemberSince => 'Member Since';

  @override
  String get adminProfileNewPasswordHint =>
      'Leave blank to keep current password';

  @override
  String get adminProfileNewPasswordLabel => 'New Password';

  @override
  String get adminProfileSaveChanges => 'Save Changes';

  @override
  String get adminProfileSubtitle => 'Manage your administrator account';

  @override
  String get adminProfileThisSession => 'This session';

  @override
  String get adminProfileTitle => 'My Profile';

  @override
  String get adminProfileUpdateError => 'Could not update profile.';

  @override
  String get adminProfileUpdatedMessage => 'Profile updated.';

  @override
  String get adminProfileUploadError => 'Could not upload photo.';

  @override
  String get adminBookEditorAddPageError => 'Could not add page.';

  @override
  String get adminBookEditorAddPageLabel => 'Add Page';

  @override
  String get adminBookEditorAudioOptionalLabel => 'Audio (optional)';

  @override
  String get adminBookEditorAuthorFieldLabel => 'Author (optional)';

  @override
  String get adminBookEditorAuthoredPagesSegmentLabel => 'Authored Pages';

  @override
  String get adminBookEditorBookSavedMessage => 'Book saved.';

  @override
  String get adminBookEditorCategoryLabel => 'Category';

  @override
  String get adminBookEditorChangeCoverLabel => 'Change Cover';

  @override
  String get adminBookEditorContainsIllustrationsLabel =>
      'Contains illustrations';

  @override
  String get adminBookEditorContentTitle => 'Content';

  @override
  String get adminBookEditorCoverImageLabel => 'Cover Image';

  @override
  String adminBookEditorCurrentFileLabel(String fileType, String fileUrl) {
    return 'Current file: $fileType — $fileUrl';
  }

  @override
  String get adminBookEditorDeletePageError => 'Could not delete page.';

  @override
  String get adminBookEditorDescriptionFieldLabel => 'Description (optional)';

  @override
  String get adminBookEditorDetailsTitle => 'Details';

  @override
  String get adminBookEditorEnglishTranslationLabel =>
      'English Translation (optional)';

  @override
  String get adminBookEditorEwondoTextLabel => 'Ewondo Text';

  @override
  String get adminBookEditorFrenchDescriptionLabel =>
      'French description (optional)';

  @override
  String get adminBookEditorFrenchTranslationLabel =>
      'French Translation (optional)';

  @override
  String get adminBookEditorIllustrationLabel => 'Illustration';

  @override
  String get adminBookEditorLevelLabel => 'Level';

  @override
  String get adminBookEditorNoFileUploadedMessage => 'No file uploaded yet.';

  @override
  String get adminBookEditorNoPagesMessage =>
      'No pages yet. Add the first one below.';

  @override
  String adminBookEditorPageNumberLabel(int number) {
    return 'Page $number';
  }

  @override
  String get adminBookEditorReadingTimeLabel => 'Reading Time (min)';

  @override
  String get adminBookEditorRecommendedAgeLabel =>
      'Recommended Age (min. years)';

  @override
  String get adminBookEditorReorderPagesError => 'Could not reorder pages.';

  @override
  String get adminBookEditorReplaceAudioLabel => 'Replace Audio';

  @override
  String get adminBookEditorReplaceFileLabel => 'Replace File';

  @override
  String get adminBookEditorSaveBookError => 'Could not save book.';

  @override
  String get adminBookEditorSavePageError => 'Could not save page.';

  @override
  String get adminBookEditorSavePageLabel => 'Save Page';

  @override
  String get adminBookEditorSavingEllipsisLabel => 'Saving…';

  @override
  String get adminBookEditorTitle => 'Edit Book';

  @override
  String get adminBookEditorTitleFieldLabel => 'Title';

  @override
  String get adminBookEditorUploadAudioError => 'Could not upload audio.';

  @override
  String get adminBookEditorUploadCoverError => 'Could not upload cover image.';

  @override
  String get adminBookEditorUploadFileError => 'Could not upload file.';

  @override
  String get adminBookEditorUploadFileLabel => 'Upload PDF or EPUB';

  @override
  String get adminBookEditorUploadIllustrationError =>
      'Could not upload illustration.';

  @override
  String get adminBookEditorUploadedFileSegmentLabel => 'Uploaded File';

  @override
  String get adminSyllabaryMgmtAnalyzeError =>
      'Could not analyze this content.';

  @override
  String get adminSyllabaryMgmtAnalyzeWithAiLabel => 'Analyze with AI';

  @override
  String get adminSyllabaryMgmtAnalyzingMessage => 'Analyzing chart photo…';

  @override
  String get adminSyllabaryMgmtApproveImportLabel => 'Approve & Import';

  @override
  String get adminSyllabaryMgmtChooseFileLabel => 'Choose a File';

  @override
  String get adminSyllabaryMgmtClearLabel => 'Clear';

  @override
  String get adminSyllabaryMgmtClipboardEmptyMessage =>
      'Nothing usable found on the clipboard.';

  @override
  String get adminSyllabaryMgmtContentPreviewTitle => 'Content Preview';

  @override
  String get adminSyllabaryMgmtDeleteEntryError => 'Could not delete entry.';

  @override
  String adminSyllabaryMgmtDeleteLetterDialogContent(int count, String letter) {
    return 'Delete all $count row(s) for \"$letter\"?';
  }

  @override
  String adminSyllabaryMgmtDeleteLetterDialogTitle(String letter) {
    return 'Delete \"$letter\"';
  }

  @override
  String get adminSyllabaryMgmtDeleteLetterError => 'Could not delete letter.';

  @override
  String adminSyllabaryMgmtDeleteLetterTooltip(String letter) {
    return 'Delete all rows for \"$letter\"';
  }

  @override
  String adminSyllabaryMgmtDimensionsLabel(int width, int height) {
    return 'Dimensions: $width × $height';
  }

  @override
  String get adminSyllabaryMgmtDropZoneText =>
      'Paste an image, a table, or text here\nor drag and drop a file';

  @override
  String get adminSyllabaryMgmtEmptyStateMessage =>
      'No syllabary content yet. Tap \"Upload Chart\" below — paste, drop, or choose a photo, PDF, Word, Excel, or text file of a chart, and the AI will extract it for you to review before saving.';

  @override
  String get adminSyllabaryMgmtEnglishTranslationLabel =>
      'English translation (optional)';

  @override
  String get adminSyllabaryMgmtExampleSentenceLabel => 'Example sentence';

  @override
  String get adminSyllabaryMgmtExampleWordLabel => 'Example word';

  @override
  String get adminSyllabaryMgmtExtractionNotesLabel => 'AI extraction notes';

  @override
  String get adminSyllabaryMgmtFrenchTranslationLabel => 'French translation';

  @override
  String adminSyllabaryMgmtImportedMessage(int count) {
    return 'Imported $count row(s).';
  }

  @override
  String adminSyllabaryMgmtImportedWithFailuresMessage(
    int succeeded,
    int failed,
    String errorSuffix,
  ) {
    return 'Imported $succeeded row(s), $failed failed$errorSuffix.';
  }

  @override
  String adminSyllabaryMgmtLetterDeletedMessage(String letter) {
    return '\"$letter\" deleted.';
  }

  @override
  String get adminSyllabaryMgmtLetterFieldHint => 'e.g. L (blank = vowel-only)';

  @override
  String get adminSyllabaryMgmtLetterFieldLabel => 'Letter';

  @override
  String adminSyllabaryMgmtLettersDetectedMessage(int count) {
    return 'Detected $count letters — review each below.';
  }

  @override
  String adminSyllabaryMgmtLettersSummary(int letterCount, int rowCount) {
    return '$letterCount letter(s), $rowCount row(s) total';
  }

  @override
  String get adminSyllabaryMgmtLettersTitle => 'Letters';

  @override
  String get adminSyllabaryMgmtListTitle => 'Syllabus Management';

  @override
  String get adminSyllabaryMgmtNoChartsDetectedMessage =>
      'No syllabary charts were detected. Try Re-analyze with a clearer photo or document, or go back and upload a different one.';

  @override
  String get adminSyllabaryMgmtNoRowsDetectedMessage =>
      'No rows detected — check the notes on the review screen.';

  @override
  String get adminSyllabaryMgmtNoRowsForLetterMessage =>
      'No rows detected for this letter.';

  @override
  String get adminSyllabaryMgmtNoneDetectedLabel => 'None detected';

  @override
  String get adminSyllabaryMgmtPasteFromClipboardLabel =>
      'Paste from Clipboard';

  @override
  String get adminSyllabaryMgmtPastedTextLabel => 'Pasted text';

  @override
  String get adminSyllabaryMgmtReanalyzeAction => 'Re-analyze';

  @override
  String get adminSyllabaryMgmtReanalyzeDialogContent =>
      'This replaces the current draft, including any edits you made.';

  @override
  String get adminSyllabaryMgmtReanalyzeDialogTitle => 'Re-analyze?';

  @override
  String get adminSyllabaryMgmtRemoveLetterTooltip =>
      'Remove this letter and its rows';

  @override
  String get adminSyllabaryMgmtRemoveRowTooltip => 'Remove this row';

  @override
  String get adminSyllabaryMgmtReviewTitle => 'Review Chart';

  @override
  String adminSyllabaryMgmtRowCountLabel(int count) {
    return '$count row(s)';
  }

  @override
  String adminSyllabaryMgmtRowNumberLabel(int number) {
    return 'Row $number';
  }

  @override
  String adminSyllabaryMgmtSizeLabel(String size) {
    return 'Size: $size';
  }

  @override
  String get adminSyllabaryMgmtStep1Subtitle =>
      'A photo, a table, or text — pick whichever is easiest.';

  @override
  String get adminSyllabaryMgmtStep1Title => '1. Paste or Import Content';

  @override
  String get adminSyllabaryMgmtSupportedFormatsText =>
      'Supported formats: PNG, JPG, PDF, Word, Excel, TXT';

  @override
  String adminSyllabaryMgmtSyllableCountLabel(int count) {
    return '$count syllable(s)';
  }

  @override
  String get adminSyllabaryMgmtSyllableLabel => 'Syllable';

  @override
  String adminSyllabaryMgmtTypeLabel(String type) {
    return 'Type: $type';
  }

  @override
  String get adminSyllabaryMgmtUnknownServerError => 'Unknown server error.';

  @override
  String get adminSyllabaryMgmtUploadChartLabel => 'Upload Chart';

  @override
  String get adminSyllabaryMgmtVowelLabel => 'Vowel';

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
  String get learnerNavHome => 'Home';

  @override
  String get learnerNavMyCourses => 'My Courses';

  @override
  String get learnerNavLibrary => 'Library';

  @override
  String get learnerNavLessons => 'Lessons';

  @override
  String get learnerNavVocabulary => 'Vocabulary';

  @override
  String get learnerNavAiTutor => 'AI Assistant';

  @override
  String get learnerNavFavorites => 'Favorites';

  @override
  String get learnerNavHistory => 'History';

  @override
  String get learnerNavSettings => 'Settings';

  @override
  String get learnerShellTagline => 'Mbolo! Let\'s learn together';

  @override
  String get learnerHistoryEmptyMessage =>
      'No lessons viewed yet. Start a lesson to see it here.';

  @override
  String learnerHistoryViewedOn(String date) {
    return 'Viewed $date';
  }

  @override
  String get learnerFavoritesEmptyMessage =>
      'No favorites yet. Bookmark a lesson to see it here.';

  @override
  String get learnerFavoritesLessonsSection => 'Lessons';

  @override
  String get learnerFavoritesBooksSection => 'Books';

  @override
  String get lessonsHubTitle => 'Lessons';

  @override
  String get lessonsHubSubtitle => 'Browse every lesson in a course';

  @override
  String get lessonsHubSelectLessonMessage =>
      'Select a lesson to see its details.';

  @override
  String get lessonsHubEmptyMessage => 'This course has no lessons yet.';

  @override
  String get lessonsHubStartLessonButton => 'Start Lesson';

  @override
  String get lessonsHubLearningObjectivesTitle => 'Learning Objectives';

  @override
  String get lessonsHubWhatYouWillLearnTitle => 'What You\'ll Learn';

  @override
  String lessonsHubMinutesShort(int minutes) {
    return '$minutes min';
  }

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
  String get booksTitle => 'Book Library';

  @override
  String get booksSubtitle => 'Discover and read Ewondo books.';

  @override
  String get noBooksTitle => 'No books yet';

  @override
  String get noBooksMessage => 'Check back soon — new books will appear here.';

  @override
  String get bookLoadError => 'Could not load this book. Please try again.';

  @override
  String get booksHubCategoryAll => 'All';

  @override
  String get booksHubSearchHint => 'Search a book...';

  @override
  String get booksHubSelectBookMessage => 'Select a book to see its details.';

  @override
  String get booksHubReadButton => 'Read the book';

  @override
  String get booksHubAddToFavoritesButton => 'Add to favorites';

  @override
  String get booksHubRemoveFromFavoritesButton => 'Remove from favorites';

  @override
  String get booksHubNewBadge => 'New';

  @override
  String get booksHubCategoryLabel => 'Category';

  @override
  String get booksHubLevelLabel => 'Level';

  @override
  String get booksHubLanguageLabel => 'Language';

  @override
  String get booksHubPagesLabel => 'Pages';

  @override
  String get booksHubPublishedLabel => 'Published';

  @override
  String booksHubMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String booksHubRecommendedAgeShort(int age) {
    return '$age+ years';
  }

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
  String get switchLanguageTitle => 'Learning Language';

  @override
  String get appLanguageTitle => 'App Language';

  @override
  String get bookReaderTextSizeTooltip => 'Text size';

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
  String get adminNavSettings => 'Settings';

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
  String get smartReviewCompleteTitle => 'Review Complete!';

  @override
  String smartReviewCompleteSummary(int count) {
    return 'You reviewed $count words today.';
  }

  @override
  String get backToPracticeButton => 'Back to Practice';

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
