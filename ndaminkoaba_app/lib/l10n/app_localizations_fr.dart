// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get adminQuizBuilderDefaultTitle => 'Quiz de la leçon';

  @override
  String get adminQuizBuilderCreateError => 'Impossible de créer le quiz.';

  @override
  String get adminQuizBuilderEditQuizTitle => 'Modifier le quiz';

  @override
  String get adminQuizBuilderTitleLabel => 'Titre';

  @override
  String get adminQuizBuilderDescriptionLabel => 'Description';

  @override
  String get adminQuizBuilderFrenchTitleLabel =>
      'Titre en français (facultatif)';

  @override
  String get adminQuizBuilderFrenchDescriptionLabel =>
      'Description en français (facultatif)';

  @override
  String get adminQuizBuilderPassingScoreLabel => 'Score de réussite (%)';

  @override
  String get adminQuizBuilderCancel => 'Annuler';

  @override
  String get adminQuizBuilderSave => 'Enregistrer';

  @override
  String get adminQuizBuilderQuizUpdated => 'Quiz mis à jour.';

  @override
  String get adminQuizBuilderUpdateQuizError =>
      'Impossible de mettre à jour le quiz.';

  @override
  String get adminQuizBuilderDeleteQuizTitle => 'Supprimer le quiz';

  @override
  String adminQuizBuilderDeleteQuizConfirm(String title, int count) {
    return 'Supprimer « $title » et ses $count question(s) ? Les apprenants ne pourront plus valider cette leçon via le quiz.';
  }

  @override
  String get adminQuizBuilderDelete => 'Supprimer';

  @override
  String get adminQuizBuilderDeleteQuizError =>
      'Impossible de supprimer le quiz.';

  @override
  String get adminQuizBuilderQuestionAdded => 'Question ajoutée.';

  @override
  String get adminQuizBuilderAddQuestionError =>
      'Impossible d\'ajouter la question.';

  @override
  String get adminQuizBuilderUnknownServerError => 'Erreur serveur inconnue.';

  @override
  String adminQuizBuilderImportSuccess(int count) {
    return '$count question(s) importée(s).';
  }

  @override
  String adminQuizBuilderImportPartial(
    int succeeded,
    int failed,
    String errorSuffix,
  ) {
    return '$succeeded question(s) importée(s), $failed échouée(s)$errorSuffix.';
  }

  @override
  String get adminQuizBuilderQuestionUpdated => 'Question mise à jour.';

  @override
  String get adminQuizBuilderUpdateQuestionError =>
      'Impossible de mettre à jour la question.';

  @override
  String get adminQuizBuilderDeleteQuestionError =>
      'Impossible de supprimer la question.';

  @override
  String get adminQuizBuilderUpdateAnswerKeyError =>
      'Impossible de mettre à jour la bonne réponse.';

  @override
  String adminQuizBuilderAppBarTitle(String lessonTitle) {
    return 'Quiz — $lessonTitle';
  }

  @override
  String get adminQuizBuilderDefaultLessonTitle => 'Leçon';

  @override
  String get adminQuizBuilderNoQuizYetTitle =>
      'Cette leçon n\'a pas encore de quiz';

  @override
  String get adminQuizBuilderNoQuizYetDescription =>
      'Créez-en un pour que les apprenants puissent valider cette leçon en le réussissant.';

  @override
  String get adminQuizBuilderQuizTitleLabel => 'Titre du quiz';

  @override
  String get adminQuizBuilderCreateQuizButton => 'Créer le quiz';

  @override
  String adminQuizBuilderPassMarkSummary(int score, int count) {
    return 'Score de réussite : $score % • $count questions';
  }

  @override
  String get adminQuizBuilderEditQuizInfoTooltip =>
      'Modifier les infos du quiz';

  @override
  String get adminQuizBuilderDeleteQuizTooltip => 'Supprimer le quiz';

  @override
  String get adminQuizBuilderQuestionsHeading => 'Questions';

  @override
  String get adminQuizBuilderPasteQuizButton => 'Coller un quiz';

  @override
  String get adminQuizBuilderAddQuestionButton => 'Ajouter une question';

  @override
  String get adminQuizBuilderNoQuestionsYet =>
      'Pas encore de questions. Un quiz doit contenir au moins une question pour qu\'un apprenant puisse le passer.';

  @override
  String get adminQuizBuilderPasteQuizHint =>
      'Vous avez déjà un quiz rédigé ailleurs ? Utilisez « Coller un quiz » ci-dessus pour le copier-coller et créer automatiquement les questions et les choix.';

  @override
  String get adminQuizBuilderEditQuestionTooltip => 'Modifier la question';

  @override
  String get adminQuizBuilderDeleteQuestionTooltip => 'Supprimer la question';

  @override
  String get adminQuizBuilderNoCorrectAnswerSet =>
      'Aucune bonne réponse définie — touchez un choix ci-dessus pour le marquer.';

  @override
  String get adminQuizBuilderQuestionTooShortError =>
      'Le texte de la question doit comporter au moins 5 caractères.';

  @override
  String get adminQuizBuilderTooFewChoicesError =>
      'Ajoutez au moins 2 choix de réponse.';

  @override
  String get adminQuizBuilderEditQuestionDialogTitle => 'Modifier la question';

  @override
  String get adminQuizBuilderQuestionLabel => 'Question';

  @override
  String get adminQuizBuilderExplanationLabel => 'Explication (facultatif)';

  @override
  String get adminQuizBuilderFrenchQuestionLabel =>
      'Question en français (facultatif)';

  @override
  String get adminQuizBuilderFrenchExplanationLabel =>
      'Explication en français (facultatif)';

  @override
  String get adminQuizBuilderChoicesHelper => 'Choix — sélectionnez le bon';

  @override
  String adminQuizBuilderChoiceHint(int number) {
    return 'Choix $number';
  }

  @override
  String get adminQuizBuilderFrenchOptionalHint => 'Français (facultatif)';

  @override
  String get adminQuizBuilderAddAnotherChoiceButton => 'Ajouter un autre choix';

  @override
  String get adminQuizBuilderPreviewImportTitle => 'Aperçu de l\'import';

  @override
  String get adminQuizBuilderParseButton => 'Analyser';

  @override
  String get adminQuizBuilderBackButton => 'Retour';

  @override
  String adminQuizBuilderImportButton(int count) {
    return 'Importer $count question(s)';
  }

  @override
  String get adminQuizBuilderPasteInstructions =>
      'Collez une ou plusieurs questions, avec une ligne vide entre chaque question.';

  @override
  String get adminQuizBuilderPasteExample =>
      '1. Quel est le mot ewondo pour « eau » ?\nA) Mendim *\nB) Ayong\nC) Nti\nExplication : Mendim signifie eau.\n\n2. Question suivante...\nA) Choix un\nB) Choix deux\nRéponse : B';

  @override
  String get adminQuizBuilderPasteFormatHelp =>
      'Marquez la bonne réponse avec un * à la fin, ou ajoutez une ligne \"Answer: B\" / \"Réponse : B\". Ajoutez \"FR: ...\" sur sa propre ligne juste après une question ou un choix pour la traduction en français. Les questions numérotées dont toutes les réponses sont listées séparément en bas sous un titre \"Answer Key\" (par ex. \"7. B) Parents\") fonctionnent aussi.';

  @override
  String get adminQuizBuilderPasteHint => 'Collez le texte de votre quiz ici…';

  @override
  String adminQuizBuilderDetectedCount(int total, int valid) {
    return '$total question(s) détectée(s) — $valid prête(s) à être importée(s).';
  }

  @override
  String get adminQuizBuilderNothingToPreview =>
      'Rien à prévisualiser — revenez en arrière et ajustez le texte collé.';

  @override
  String get adminQuizMgmtEditQuizTitle => 'Modifier le quiz';

  @override
  String get adminQuizMgmtTitleLabel => 'Titre';

  @override
  String get adminQuizMgmtDescriptionLabel => 'Description';

  @override
  String get adminQuizMgmtFrenchTitleLabel => 'Titre en français (facultatif)';

  @override
  String get adminQuizMgmtFrenchDescriptionLabel =>
      'Description en français (facultatif)';

  @override
  String get adminQuizMgmtPassingScoreLabel => 'Score de réussite (%)';

  @override
  String get adminQuizMgmtCancel => 'Annuler';

  @override
  String get adminQuizMgmtSave => 'Enregistrer';

  @override
  String get adminQuizMgmtQuizUpdated => 'Quiz mis à jour.';

  @override
  String get adminQuizMgmtUpdateQuizError =>
      'Impossible de mettre à jour le quiz.';

  @override
  String get adminQuizMgmtDeleteQuizTitle => 'Supprimer le quiz';

  @override
  String adminQuizMgmtDeleteQuizConfirm(String title, int count) {
    return 'Supprimer « $title » et ses $count question(s) ? Cette action est irréversible.';
  }

  @override
  String get adminQuizMgmtDelete => 'Supprimer';

  @override
  String get adminQuizMgmtQuizDeleted => 'Quiz supprimé.';

  @override
  String get adminQuizMgmtDeleteQuizError => 'Impossible de supprimer le quiz.';

  @override
  String get adminQuizMgmtAppBarTitle => 'Gestion des quiz';

  @override
  String get adminQuizMgmtNewQuizButton => 'Nouveau quiz';

  @override
  String get adminQuizMgmtSearchHint => 'Rechercher des quiz...';

  @override
  String get adminQuizMgmtAllCoursesFilter => 'Tous les cours';

  @override
  String get adminQuizMgmtNoQuizzesFound => 'Aucun quiz trouvé.';

  @override
  String adminQuizMgmtQuestionsSummary(int count, int passingScore) {
    return '$count questions • réussite à $passingScore %';
  }

  @override
  String get adminBibleChapterDefaultVersion => 'ESV';

  @override
  String get adminBibleChapterFileReadError => 'Impossible de lire ce fichier.';

  @override
  String adminBibleChapterFileLoaded(String fileName) {
    return '$fileName chargé.';
  }

  @override
  String get adminBibleChapterInvalidChapterError =>
      'Entrez un numéro de chapitre valide.';

  @override
  String get adminBibleChapterNoVersesFoundError =>
      'Aucun verset numéroté trouvé. Collez un verset par ligne, chacun commençant par son numéro.';

  @override
  String get adminBibleChapterNoUsfmMarkersError =>
      'Aucun marqueur de verset \\v trouvé. Assurez-vous d\'avoir collé du texte USFM valide (ex. \"\\c 1 \\v 1 Au commencement...\").';

  @override
  String get adminBibleChapterEnterBookNameError =>
      'Entrez le nom d\'un livre.';

  @override
  String get adminBibleChapterNoEwondoVersesError =>
      'Aucun verset avec du texte ewondo à enregistrer — prévisualisez d\'abord la comparaison.';

  @override
  String adminBibleChapterSavedMultiChapters(
    int count,
    int chapterCount,
    String book,
  ) {
    return '$count verset(s) enregistré(s) sur $chapterCount chapitres de $book.';
  }

  @override
  String adminBibleChapterSavedSingleChapter(int count, String book) {
    return '$count verset(s) enregistré(s) pour $book.';
  }

  @override
  String get adminBibleChapterSaveError =>
      'Impossible d\'enregistrer le chapitre.';

  @override
  String get adminBibleChapterDeleteChapterTitle => 'Supprimer le chapitre';

  @override
  String adminBibleChapterDeleteChapterConfirm(
    int count,
    String book,
    int chapter,
    String version,
  ) {
    return 'Supprimer les $count verset(s) de $book $chapter ($version) ?';
  }

  @override
  String get adminBibleChapterCancel => 'Annuler';

  @override
  String get adminBibleChapterDelete => 'Supprimer';

  @override
  String get adminBibleChapterDeleteError =>
      'Impossible de supprimer le chapitre.';

  @override
  String get adminBibleChapterUploadFileButton => 'Importer un fichier';

  @override
  String adminBibleChapterChapterHeading(int chapter) {
    return 'Chapitre $chapter';
  }

  @override
  String adminBibleChapterVerseCount(int count) {
    return '$count versets';
  }

  @override
  String get adminBibleChapterMissingEwondoText => 'Texte ewondo manquant';

  @override
  String get adminBibleChapterMissingEnglishText => 'Texte anglais manquant';

  @override
  String get adminBibleChapterMissingFrenchText => 'Texte français manquant';

  @override
  String get adminBibleChapterDefaultLanguageName => 'Langue';

  @override
  String get adminBibleChapterTitle => 'Gestion de la Bible';

  @override
  String adminBibleChapterSubtitle(String title) {
    return 'Chapitres et versets bibliques pour $title';
  }

  @override
  String get adminBibleChapterUsfmModeInstructions =>
      'Importez (ou collez) le fichier USFM complet d\'un livre en ewondo, accompagné de sa version USFM en anglais (ESV). Les chapitres et versets sont détectés automatiquement à partir des marqueurs \\c et \\v et associés verset par verset.';

  @override
  String get adminBibleChapterManualModeInstructions =>
      'Collez un chapitre complet en ewondo (Nouveau Testament) accompagné de sa traduction anglaise (ESV). Chaque verset est associé afin que Nnanga apprenne des traductions précises, mises côte à côte.';

  @override
  String get adminBibleChapterSingleChapterOption => 'Chapitre unique';

  @override
  String get adminBibleChapterUsfmWholeBookOption => 'USFM (livre entier)';

  @override
  String get adminBibleChapterBookDetailsTitle => 'Détails du livre';

  @override
  String get adminBibleChapterChapterDetailsTitle => 'Détails du chapitre';

  @override
  String get adminBibleChapterAutoFilledHint =>
      'Rempli automatiquement à partir du titre USFM \\h/\\mt1 une fois prévisualisé — modifiez si nécessaire.';

  @override
  String get adminBibleChapterBookLabel => 'Livre';

  @override
  String get adminBibleChapterChapterLabel => 'Chapitre';

  @override
  String get adminBibleChapterVersionLabel => 'Version';

  @override
  String get adminBibleChapterEwondoUsfmLabel => 'USFM ewondo (livre entier)';

  @override
  String get adminBibleChapterEwondoChapterLabel =>
      'Texte du chapitre en ewondo';

  @override
  String get adminBibleChapterUploadOrPasteHelper =>
      'Importez un fichier .usfm/.sfm/.txt, ou collez le texte directement.';

  @override
  String get adminBibleChapterOneVersePerLineHelper =>
      'Un verset par ligne, chacun commençant par son numéro.';

  @override
  String get adminBibleChapterEwondoUsfmHintExample =>
      '\\id JHN\n\\h John\n\\c 1\n\\v 1 Kiki avele, Nkobo a nga bo...\n\\v 2 ...';

  @override
  String get adminBibleChapterManualHintExample =>
      '1 In the beginning was the Word...\n2 He was in the beginning with God...';

  @override
  String get adminBibleChapterEnglishUsfmLabel =>
      'USFM anglais (livre entier, ESV)';

  @override
  String get adminBibleChapterEnglishChapterLabel =>
      'Texte du chapitre en anglais (ESV)';

  @override
  String get adminBibleChapterEnglishUsfmHintExample =>
      '\\id JHN\n\\h John\n\\c 1\n\\v 1 In the beginning was the Word...\n\\v 2 ...';

  @override
  String get adminBibleChapterFrenchUsfmLabel =>
      'USFM français (livre entier, facultatif)';

  @override
  String get adminBibleChapterFrenchChapterLabel =>
      'Texte du chapitre en français (facultatif)';

  @override
  String get adminBibleChapterFrenchUsfmHintExample =>
      '\\id JHN\n\\h Jean\n\\c 1\n\\v 1 Au commencement était la Parole...\n\\v 2 ...';

  @override
  String get adminBibleChapterFrenchManualHintExample =>
      '1 Au commencement était la Parole...\n2 Elle était au commencement avec Dieu...';

  @override
  String get adminBibleChapterPreviewButton =>
      'Aperçu de la comparaison verset par verset';

  @override
  String get adminBibleChapterComparisonTitle =>
      'Comparaison verset par verset';

  @override
  String adminBibleChapterVersesAcrossChapters(
    int verseCount,
    int chapterCount,
  ) {
    return '$verseCount versets sur $chapterCount chapitre(s)';
  }

  @override
  String get adminBibleChapterSaveBookButton => 'Enregistrer le livre';

  @override
  String get adminBibleChapterSaveChapterButton => 'Enregistrer le chapitre';

  @override
  String get adminBibleChapterSavedChaptersHeading => 'Chapitres enregistrés';

  @override
  String get adminBibleChapterEmptyTitle => 'Pas encore de chapitres';

  @override
  String get adminBibleChapterEmptyMessage =>
      'Collez et enregistrez un chapitre ci-dessus pour le voir apparaître ici.';

  @override
  String get adminBibleChapterDeleteChapterTooltip => 'Supprimer le chapitre';

  @override
  String get adminBibleChapterOverwriteTitle =>
      'Écraser les chapitres existants ?';

  @override
  String adminBibleChapterOverwriteConfirm(int count, String book) {
    return '$count de ces chapitres sont déjà enregistrés pour « $book ». Enregistrer maintenant remplacera leurs versets existants par ceux que vous importez.';
  }

  @override
  String get adminBibleChapterOverwriteButton => 'Écraser';

  @override
  String get adminLessonEditorTabInfo => 'Infos de la leçon';

  @override
  String get adminLessonEditorTabContent => 'Contenu';

  @override
  String get adminLessonEditorTabActivities => 'Activités';

  @override
  String get adminLessonEditorTabQuiz => 'Quiz';

  @override
  String get adminLessonEditorTabResources => 'Ressources';

  @override
  String get adminLessonEditorTabSettings => 'Paramètres';

  @override
  String get adminLessonEditorSavedInfoMessage =>
      'Informations de la leçon enregistrées.';

  @override
  String get adminLessonEditorCouldNotSaveInfo =>
      'Impossible d\'enregistrer les informations de la leçon.';

  @override
  String get adminLessonEditorDraftSavedMessage => 'Brouillon enregistré.';

  @override
  String get adminLessonEditorCouldNotSaveDraft =>
      'Impossible d\'enregistrer le brouillon.';

  @override
  String get adminLessonEditorPublishedMessage => 'Leçon publiée.';

  @override
  String get adminLessonEditorCouldNotPublish =>
      'Impossible de publier la leçon.';

  @override
  String get adminLessonEditorAppBarTitle => 'Modifier la leçon';

  @override
  String get adminLessonEditorPreviewLearnerViewButton =>
      'Aperçu (vue apprenant)';

  @override
  String get adminLessonEditorSaveDraftButton => 'Enregistrer le brouillon';

  @override
  String get adminLessonEditorPublishingLabel => 'Publication…';

  @override
  String get adminLessonEditorPublishLessonButton => 'Publier la leçon';

  @override
  String get adminLessonEditorLessonInfoSectionTitle =>
      'Informations sur la leçon';

  @override
  String get adminLessonEditorLessonTitleLabel => 'Titre de la leçon';

  @override
  String get adminLessonEditorShortDescriptionLabel => 'Description courte';

  @override
  String get adminLessonEditorLessonCategoryLabel => 'Catégorie de la leçon';

  @override
  String get adminLessonEditorLevelLabel => 'Niveau';

  @override
  String get adminLessonEditorEstimatedTimeLabel => 'Durée estimée (min)';

  @override
  String get adminLessonEditorOrderLabel => 'Ordre';

  @override
  String get adminLessonEditorCoverImageSectionTitle =>
      'Couverture / image de la leçon';

  @override
  String get adminLessonEditorCoverImageHint =>
      'Cette image apparaîtra dans la vue apprenant.';

  @override
  String get adminLessonEditorChangeImageButton => 'Changer l\'image';

  @override
  String get adminLessonEditorRemoveImageButton => 'Supprimer l\'image';

  @override
  String get adminLessonEditorLearningObjectivesLabel =>
      'Objectifs d\'apprentissage (un par ligne)';

  @override
  String get adminLessonEditorOutcomesLabel =>
      'Ce que les apprenants vont apprendre (un par ligne)';

  @override
  String get adminLessonEditorNoActivitiesYetMessage =>
      'Aucune activité pour le moment.';

  @override
  String get adminLessonEditorNoQuizYetMessage =>
      'Cette leçon n\'a pas encore de quiz.';

  @override
  String get adminLessonEditorHasQuizMessage =>
      'Cette leçon est liée à un quiz.';

  @override
  String get adminLessonEditorResourcesDescription =>
      'Images illustrées associées à cette leçon. Ajoutez ou retirez des images par mot depuis l\'écran Images dédié.';

  @override
  String get adminLessonEditorManageLessonImagesButton =>
      'Gérer les images de la leçon';

  @override
  String get adminLessonEditorSettingsDescription =>
      'L\'attribution du relecteur et les commentaires se trouvent dans le panneau de droite.';

  @override
  String get adminLessonEditorLessonSummaryCardTitle => 'Résumé de la leçon';

  @override
  String get adminLessonEditorLessonIdLabel => 'ID de la leçon';

  @override
  String get adminLessonEditorCreatedLabel => 'Créée le';

  @override
  String get adminLessonEditorLastUpdatedLabel => 'Dernière mise à jour';

  @override
  String get adminLessonEditorImagePreviewCardTitle =>
      'Aperçu de l\'image de la leçon (vue apprenant)';

  @override
  String get adminLessonEditorTipsCardTitle => 'Astuces';

  @override
  String get adminLessonEditorTip1 =>
      'Utilisez des images de bonne qualité (1280x720 recommandé)';

  @override
  String get adminLessonEditorTip2 =>
      'Les images rendent les leçons plus attrayantes';

  @override
  String get adminLessonEditorTip3 =>
      'Vous pouvez ajouter plusieurs images dans le contenu';

  @override
  String get adminLessonEditorTip4 =>
      'Gardez les leçons ciblées et interactives';

  @override
  String get adminLessonEditorUrlHint => 'https://...';

  @override
  String get adminLessonEditorInsertButton => 'Insérer';

  @override
  String get adminLessonEditorEmbedUrlDialogTitle => 'URL d\'intégration';

  @override
  String get adminLessonMgmtFrenchSummaryOptionalLabel =>
      'Résumé en français (optionnel)';

  @override
  String get adminLessonMgmtFrenchContentOptionalLabel =>
      'Contenu en français (optionnel)';

  @override
  String get adminLessonMgmtConversationHelpText =>
      'En conversation (optionnel) — une ligne par réplique : « Locuteur : Texte || Texte en français »';

  @override
  String get adminLessonMgmtConversationLabel => 'Conversation';

  @override
  String get adminLessonMgmtConversationHint =>
      'Amina: Mbolo, wa nga zu na? || Bonjour, comment vas-tu ?';

  @override
  String get adminLessonMgmtDeleteLessonTitle => 'Supprimer la leçon';

  @override
  String adminLessonMgmtDeleteConfirm(String title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String adminLessonMgmtDeleteConfirmWithQuiz(String title) {
    return 'Supprimer « $title » ? Son quiz doit d\'abord être supprimé (depuis la gestion des quiz).';
  }

  @override
  String get adminLessonMgmtUpdatedMessage => 'Leçon mise à jour.';

  @override
  String get adminLessonMgmtMovedMessage => 'Leçon déplacée.';

  @override
  String get adminLessonMgmtReorderedMessage => 'Leçon réorganisée.';

  @override
  String get adminLessonMgmtDeletedMessage => 'Leçon supprimée.';

  @override
  String get adminLessonMgmtAppBarTitle => 'Gestion des leçons';

  @override
  String get adminLessonMgmtSearchHint => 'Rechercher des leçons...';

  @override
  String get adminLessonMgmtAllCoursesFilter => 'Tous les cours';

  @override
  String get adminLessonMgmtNoLessonsFoundMessage => 'Aucune leçon trouvée.';

  @override
  String adminLessonMgmtLessonRowTitle(int number, String title) {
    return 'Leçon $number : $title';
  }

  @override
  String get moveLessonDialogTitle => 'Déplacer la leçon';

  @override
  String get moveLessonDialogDestinationCourseLabel => 'Cours de destination';

  @override
  String get moveLessonDialogDestinationModuleLabel => 'Module de destination';

  @override
  String get moveLessonDialogAlreadyInModuleMessage =>
      'Cette leçon se trouve déjà dans ce module.';

  @override
  String get moveLessonDialogMoveButton => 'Déplacer';

  @override
  String get reorderLessonDialogTitle => 'Modifier la position de la leçon';

  @override
  String reorderLessonDialogNewPositionLabel(int currentPosition) {
    return 'Nouvelle position (actuellement Leçon $currentPosition)';
  }

  @override
  String get reorderLessonDialogMoveButton => 'Déplacer';

  @override
  String get adminUsersCouldNotUpdateUser =>
      'Impossible de mettre à jour l\'utilisateur.';

  @override
  String get adminUsersCouldNotUpdateRole =>
      'Impossible de mettre à jour le rôle.';

  @override
  String get adminUsersDeleteUserTitle => 'Supprimer l\'utilisateur';

  @override
  String adminUsersDeleteConfirm(String name) {
    return 'Supprimer $name définitivement ? Cette action est irréversible. Les utilisateurs ayant des cours, une progression ou d\'autres données liées ne peuvent pas être supprimés — désactivez-les à la place.';
  }

  @override
  String get adminUsersCancel => 'Annuler';

  @override
  String get adminUsersDelete => 'Supprimer';

  @override
  String get adminUsersCouldNotDeleteUser =>
      'Impossible de supprimer l\'utilisateur.';

  @override
  String get adminUsersTitle => 'Utilisateurs';

  @override
  String adminUsersSubtitle(int count) {
    return '$count au total';
  }

  @override
  String get adminUsersNewUser => 'Nouvel utilisateur';

  @override
  String get adminUsersSearchHint => 'Rechercher par nom ou e-mail...';

  @override
  String get adminUsersActive => 'Actif';

  @override
  String get adminUsersDeactivated => 'Désactivé';

  @override
  String get adminUsersDeactivateAction => 'Désactiver';

  @override
  String get adminUsersActivateAction => 'Activer';

  @override
  String get adminUsersMakeAdminAction => 'Nommer administrateur';

  @override
  String get adminUsersMakeTeacherAction => 'Nommer enseignant';

  @override
  String get adminUsersMakeLearnerAction => 'Nommer apprenant';

  @override
  String get adminUsersThisIsYourAccount => 'Ceci est votre compte';

  @override
  String get adminVocabMgmtTitle => 'Gestion du vocabulaire';

  @override
  String get adminVocabMgmtCouldNotDeleteWord =>
      'Impossible de supprimer le mot.';

  @override
  String get adminVocabMgmtWordAdded => 'Entrée de connaissance ajoutée.';

  @override
  String get adminVocabMgmtCouldNotAddWord => 'Impossible d\'ajouter le mot.';

  @override
  String get adminVocabMgmtUnknownServerError => 'Erreur serveur inconnue.';

  @override
  String adminVocabMgmtImportedWords(int count) {
    return '$count mot(s) importé(s).';
  }

  @override
  String adminVocabMgmtImportedWordsWithFailures(int succeeded, int failed) {
    return '$succeeded mot(s) importé(s), $failed échec(s)';
  }

  @override
  String get adminVocabMgmtWordUpdated => 'Entrée de connaissance mise à jour.';

  @override
  String get adminVocabMgmtCouldNotUpdateWord =>
      'Impossible de mettre à jour le mot.';

  @override
  String get adminVocabMgmtCouldNotDeleteText =>
      'Impossible de supprimer le texte.';

  @override
  String get adminVocabMgmtTextAdded => 'Texte et traduction ajoutés.';

  @override
  String get adminVocabMgmtCouldNotAddText => 'Impossible d\'ajouter le texte.';

  @override
  String get adminVocabMgmtTextUpdated => 'Texte et traduction mis à jour.';

  @override
  String get adminVocabMgmtCouldNotUpdateText =>
      'Impossible de mettre à jour le texte.';

  @override
  String get adminVocabMgmtAddTextAction => 'Ajouter texte et traduction';

  @override
  String get adminVocabMgmtPasteVocabularyAction => 'Coller du vocabulaire';

  @override
  String get adminVocabMgmtAddKnowledgeAction => 'Ajouter une connaissance';

  @override
  String get adminVocabMgmtKnowledgeBaseDescription =>
      'Ceci est la base de connaissances de Nnanga. Elle recherche parmi ces mots et leurs leçons pour répondre aux apprenants — plus vous en ajoutez, mieux elle répond.';

  @override
  String get adminVocabMgmtSearchHint => 'Rechercher dans les connaissances...';

  @override
  String get adminVocabMgmtAllLevels => 'Tous les niveaux';

  @override
  String get adminVocabMgmtEmptyState =>
      'Aucune connaissance trouvée. Utilisez « Coller du vocabulaire » ci-dessous pour ajouter toute une liste de mots à la fois, ou « Ajouter une connaissance » pour un seul mot.';

  @override
  String get adminVocabMgmtTextsSectionTitle => 'Textes et traductions';

  @override
  String adminVocabMgmtEntriesCount(int count) {
    return '$count entrées';
  }

  @override
  String get adminVocabMgmtEditTooltip => 'Modifier';

  @override
  String get adminVocabMgmtDeleteTooltip => 'Supprimer';

  @override
  String get adminVocabMgmtVocabularySectionTitle => 'Vocabulaire';

  @override
  String adminVocabMgmtWordsCount(int count) {
    return '$count mots';
  }

  @override
  String get adminVocabMgmtEditAction => 'Modifier';

  @override
  String get adminVocabMgmtDeleteAction => 'Supprimer';

  @override
  String get adminVocabMgmtEditKnowledgeEntryTitle =>
      'Modifier l\'entrée de connaissance';

  @override
  String get adminVocabMgmtAddKnowledgeEntryTitle =>
      'Ajouter une entrée de connaissance';

  @override
  String get adminVocabMgmtEwondoWordLabel => 'Mot ou expression en ewondo';

  @override
  String get adminVocabMgmtExampleSentenceLabel => 'Phrase d\'exemple';

  @override
  String get adminVocabMgmtPhoneticLabel =>
      'Transcription phonétique (facultatif)';

  @override
  String get adminVocabMgmtPhoneticHint =>
      'ex. mbɔ́lɔ́ — affiché sous le mot sur l\'écran de la leçon';

  @override
  String get adminVocabMgmtPronunciationAudioLabel =>
      'Audio de prononciation (aide la lecture « écouter » de Nnanga pour les apprenants)';

  @override
  String get adminVocabMgmtEnglishMeaningLabel => 'Signification en anglais';

  @override
  String get adminVocabMgmtEnglishTranslationLabel => 'Traduction en anglais';

  @override
  String get adminVocabMgmtFrenchMeaningLabel => 'Signification en français';

  @override
  String get adminVocabMgmtFrenchTranslationLabel => 'Traduction en français';

  @override
  String get adminVocabMgmtDifficultyLabel => 'Difficulté';

  @override
  String get adminVocabMgmtCancel => 'Annuler';

  @override
  String get adminVocabMgmtSave => 'Enregistrer';

  @override
  String get adminVocabMgmtAdd => 'Ajouter';

  @override
  String get adminVocabMgmtEditTextEntryTitle =>
      'Modifier le texte et la traduction';

  @override
  String get adminVocabMgmtAddTextEntryTitle => 'Ajouter texte et traduction';

  @override
  String get adminVocabMgmtEwondoTextLabel => 'Texte en ewondo';

  @override
  String get adminVocabMgmtTranslationLabel => 'Traduction';

  @override
  String get adminVocabMgmtPasteVocabularyTitle => 'Coller du vocabulaire';

  @override
  String get adminVocabMgmtPreviewImportTitle => 'Aperçu de l\'importation';

  @override
  String get adminVocabMgmtParseAction => 'Analyser';

  @override
  String get adminVocabMgmtBackAction => 'Retour';

  @override
  String adminVocabMgmtImportWordsAction(int count) {
    return 'Importer $count mot(s)';
  }

  @override
  String get adminVocabMgmtPasteInstructions =>
      'Collez une liste de mots — un par ligne, ou une ligne vide entre des entrées plus détaillées.';

  @override
  String get adminVocabMgmtPasteFormatHelp =>
      'Lignes simples : « mot | signification en anglais | signification en français » (significations facultatives). Ou détaillez sur plusieurs lignes avec EN:, FR:, Example:, Example EN:, Example FR:, Phonetic: et Level: — seul le mot est obligatoire.';

  @override
  String get adminVocabMgmtPasteFieldHint => 'Collez votre liste de mots ici…';

  @override
  String adminVocabMgmtWordsDetectedSummary(int total, int validCount) {
    return '$total mot(s) détecté(s) — $validCount prêt(s) à être importé(s).';
  }

  @override
  String get adminVocabMgmtNothingToPreview =>
      'Rien à prévisualiser — revenez en arrière et ajustez le texte collé.';

  @override
  String get adminDailyMgmtDailyWordAdded => 'Mot du jour ajouté.';

  @override
  String get adminDailyMgmtCouldNotAddDailyWord =>
      'Impossible d\'ajouter le mot du jour.';

  @override
  String get adminDailyMgmtDailyWordUpdated => 'Mot du jour mis à jour.';

  @override
  String get adminDailyMgmtCouldNotUpdateDailyWord =>
      'Impossible de mettre à jour le mot du jour.';

  @override
  String get adminDailyMgmtCouldNotDeleteDailyWord =>
      'Impossible de supprimer le mot du jour.';

  @override
  String get adminDailyMgmtDailyVerseAdded => 'Verset du jour ajouté.';

  @override
  String get adminDailyMgmtCouldNotAddDailyVerse =>
      'Impossible d\'ajouter le verset du jour.';

  @override
  String get adminDailyMgmtDailyVerseUpdated => 'Verset du jour mis à jour.';

  @override
  String get adminDailyMgmtCouldNotUpdateDailyVerse =>
      'Impossible de mettre à jour le verset du jour.';

  @override
  String get adminDailyMgmtCouldNotDeleteDailyVerse =>
      'Impossible de supprimer le verset du jour.';

  @override
  String get adminDailyMgmtLanguageFallback => 'Langue';

  @override
  String get adminDailyMgmtTitle => 'Phrase et verset du jour';

  @override
  String adminDailyMgmtSubtitle(String language) {
    return 'Réserves rotatives de mots/versets du jour pour $language';
  }

  @override
  String get adminDailyMgmtAddDailyWordAction => 'Ajouter un mot du jour';

  @override
  String get adminDailyMgmtAddDailyVerseAction => 'Ajouter un verset du jour';

  @override
  String get adminDailyMgmtDescription =>
      'Une entrée différente de chaque réserve est affichée automatiquement chaque jour sur le tableau de bord de l\'apprenant — pas besoin de choisir manuellement l\'élément « du jour ».';

  @override
  String get adminDailyMgmtDailyWordsChip => 'Mots du jour';

  @override
  String get adminDailyMgmtDailyVersesChip => 'Versets du jour';

  @override
  String get adminDailyMgmtSearchWordsHint => 'Rechercher des mots ewondo...';

  @override
  String get adminDailyMgmtSearchVersesHint =>
      'Rechercher des versets ou une référence...';

  @override
  String get adminDailyMgmtNoDailyWordsTitle =>
      'Aucun mot du jour pour l\'instant';

  @override
  String get adminDailyMgmtNoDailyWordsMessage =>
      'Ajoutez des mots ewondo à faire défiler sur le tableau de bord de l\'apprenant.';

  @override
  String get adminDailyMgmtEditAction => 'Modifier';

  @override
  String get adminDailyMgmtDeleteAction => 'Supprimer';

  @override
  String get adminDailyMgmtNoDailyVersesTitle =>
      'Aucun verset du jour pour l\'instant';

  @override
  String get adminDailyMgmtNoDailyVersesMessage =>
      'Ajoutez des versets bibliques ewondo à faire défiler sur le tableau de bord de l\'apprenant.';

  @override
  String get adminDailyMgmtEditDailyWordTitle => 'Modifier le mot du jour';

  @override
  String get adminDailyMgmtAddDailyWordTitle => 'Ajouter un mot du jour';

  @override
  String get adminDailyMgmtEwondoWordLabel => 'Mot ewondo';

  @override
  String get adminDailyMgmtEnglishMeaningLabel => 'Signification en anglais';

  @override
  String get adminDailyMgmtFrenchMeaningLabel => 'Signification en français';

  @override
  String get adminDailyMgmtUsageHintLabel =>
      'Astuce d\'utilisation (facultatif)';

  @override
  String get adminDailyMgmtCancel => 'Annuler';

  @override
  String get adminDailyMgmtSave => 'Enregistrer';

  @override
  String get adminDailyMgmtAdd => 'Ajouter';

  @override
  String get adminDailyMgmtEditDailyVerseTitle => 'Modifier le verset du jour';

  @override
  String get adminDailyMgmtAddDailyVerseTitle => 'Ajouter un verset du jour';

  @override
  String get adminDailyMgmtReferenceLabel => 'Référence (ex. Yoannes 3:16)';

  @override
  String get adminDailyMgmtEwondoTextLabel => 'Texte en ewondo';

  @override
  String get adminDailyMgmtEnglishTranslationLabel => 'Traduction en anglais';

  @override
  String get adminDailyMgmtFrenchTranslationLabel => 'Traduction en français';

  @override
  String get adminDailyMgmtCouldNotLoadVocabulary =>
      'Impossible de charger le vocabulaire.';

  @override
  String get adminDailyMgmtPickVocabularyWordTitle =>
      'Choisir un mot du vocabulaire';

  @override
  String get adminDailyMgmtSearchLabel => 'Rechercher';

  @override
  String get adminDailyMgmtSomethingWentWrong => 'Une erreur s\'est produite';

  @override
  String get adminDailyMgmtNoVocabularyYetTitle =>
      'Aucun vocabulaire pour l\'instant';

  @override
  String get adminDailyMgmtNoVocabularyYetMessage =>
      'Ajoutez d\'abord des mots dans la gestion du vocabulaire.';

  @override
  String get adminDailyMgmtCouldNotLoadBibleChapters =>
      'Impossible de charger les chapitres bibliques.';

  @override
  String get adminDailyMgmtCouldNotLoadVerses =>
      'Impossible de charger les versets.';

  @override
  String get adminDailyMgmtPickChapterTitle => 'Choisir un chapitre';

  @override
  String get adminDailyMgmtNoBibleContentYetTitle =>
      'Aucun contenu biblique pour l\'instant';

  @override
  String get adminDailyMgmtNoBibleContentYetMessage =>
      'Ajoutez d\'abord des chapitres dans la gestion biblique.';

  @override
  String get adminDailyMgmtNoVersesYetTitle => 'Aucun verset pour l\'instant';

  @override
  String get adminDailyMgmtNoVersesYetMessage =>
      'Ce chapitre ne contient aucun verset.';

  @override
  String get adminDailyMgmtBackAction => 'Retour';

  @override
  String adminDailyMgmtVerseCount(int count) {
    return '$count versets';
  }

  @override
  String adminDailyMgmtVerseNumber(int number) {
    return 'Verset $number';
  }

  @override
  String get adminBookMgmtAddBook => 'Ajouter un livre';

  @override
  String get adminBookMgmtAddError => 'Impossible d\'ajouter le livre.';

  @override
  String get adminBookMgmtCancel => 'Annuler';

  @override
  String get adminBookMgmtCategoryAll => 'Tout';

  @override
  String get adminBookMgmtCreate => 'Créer';

  @override
  String get adminBookMgmtDelete => 'Supprimer';

  @override
  String adminBookMgmtDeleteBody(String title) {
    return '« $title » sera retiré pour tous les apprenants.';
  }

  @override
  String get adminBookMgmtDeleteError => 'Impossible de supprimer le livre.';

  @override
  String get adminBookMgmtDeleteTitle => 'Supprimer le livre ?';

  @override
  String get adminBookMgmtDeletedMessage => 'Livre supprimé.';

  @override
  String get adminBookMgmtEdit => 'Modifier';

  @override
  String get adminBookMgmtEmptyMessage =>
      'Appuyez sur « Ajouter un livre » pour créer le premier.';

  @override
  String get adminBookMgmtEmptyTitle => 'Aucun livre pour l\'instant';

  @override
  String get adminBookMgmtErrorTitle => 'Une erreur s\'est produite';

  @override
  String get adminBookMgmtLanguageFallback => 'Langue';

  @override
  String get adminBookMgmtLoadError => 'Impossible de charger les livres.';

  @override
  String get adminBookMgmtNoContent => 'Pas encore de contenu';

  @override
  String adminBookMgmtPagesCount(int count) {
    return '$count pages';
  }

  @override
  String get adminBookMgmtSearchLabel => 'Rechercher des livres';

  @override
  String adminBookMgmtSubtitle(String title) {
    return 'Livres pour $title';
  }

  @override
  String get adminBookMgmtTitle => 'Gestion des livres';

  @override
  String get adminBookMgmtTitleLabel => 'Titre';

  @override
  String get adminLangMgmtAdd => 'Ajouter';

  @override
  String get adminLangMgmtAddError => 'Impossible d\'ajouter la langue.';

  @override
  String get adminLangMgmtAddTitle => 'Ajouter une langue';

  @override
  String get adminLangMgmtAddedMessage =>
      'Langue ajoutée. Elle démarre en brouillon — publiez-la une fois son contenu prêt.';

  @override
  String get adminLangMgmtCancel => 'Annuler';

  @override
  String get adminLangMgmtCodeLabel => 'Code (ex. bas)';

  @override
  String get adminLangMgmtCountryLabel => 'Pays (facultatif)';

  @override
  String get adminLangMgmtDelete => 'Supprimer';

  @override
  String adminLangMgmtDeleteBody(String name) {
    return '« $name » sera définitivement supprimée. Cela ne fonctionne que si elle n\'a pas encore de cours.';
  }

  @override
  String get adminLangMgmtDeleteError => 'Impossible de supprimer la langue.';

  @override
  String get adminLangMgmtDeleteTitle => 'Supprimer la langue ?';

  @override
  String get adminLangMgmtDeletedMessage => 'Langue supprimée.';

  @override
  String get adminLangMgmtDraft => 'Brouillon';

  @override
  String get adminLangMgmtEmptyMessage =>
      'Appuyez sur « Ajouter une langue » pour créer la première.';

  @override
  String get adminLangMgmtEmptyTitle => 'Aucune langue pour l\'instant';

  @override
  String get adminLangMgmtErrorTitle => 'Une erreur s\'est produite';

  @override
  String get adminLangMgmtLoadError => 'Impossible de charger les langues.';

  @override
  String get adminLangMgmtNameLabel => 'Nom (ex. Bassa)';

  @override
  String get adminLangMgmtPublished => 'Publié';

  @override
  String adminLangMgmtSubtitleCount(int count) {
    return '$count au total';
  }

  @override
  String get adminLangMgmtTitle => 'Langues';

  @override
  String get adminLangMgmtUpdateError =>
      'Impossible de mettre à jour la langue.';

  @override
  String get adminLessonImagesAdd => 'Ajouter';

  @override
  String get adminLessonImagesAddError => 'Impossible d\'ajouter l\'image.';

  @override
  String get adminLessonImagesAddImage => 'Ajouter une image';

  @override
  String get adminLessonImagesAddedMessage => 'Image ajoutée.';

  @override
  String get adminLessonImagesCancel => 'Annuler';

  @override
  String get adminLessonImagesCaptionLabel => 'Légende (facultatif)';

  @override
  String get adminLessonImagesDelete => 'Supprimer';

  @override
  String adminLessonImagesDeleteBody(String word) {
    return 'Retirer l\'image pour « $word » ?';
  }

  @override
  String get adminLessonImagesDeleteTitle => 'Supprimer l\'image';

  @override
  String get adminLessonImagesDialogTitle => 'Illustrer un mot';

  @override
  String get adminLessonImagesEmptyMessage =>
      'Ajoutez une image pour illustrer un mot de cette leçon.';

  @override
  String get adminLessonImagesEmptyTitle => 'Aucune image pour l\'instant';

  @override
  String get adminLessonImagesIntro =>
      'Ajoutez des images pour illustrer les mots de cette leçon. Ajoutez-en autant que vous le souhaitez.';

  @override
  String get adminLessonImagesRemoveError => 'Impossible de retirer l\'image.';

  @override
  String get adminLessonImagesRemovedMessage => 'Image retirée.';

  @override
  String get adminLessonImagesTitleFallback => 'Images de la leçon';

  @override
  String adminLessonImagesTitleWithLesson(String lesson) {
    return 'Images — $lesson';
  }

  @override
  String get adminLessonImagesWordLabel => 'Mot illustré';

  @override
  String get adminModuleMgmtAllCourses => 'Tous les cours';

  @override
  String get adminModuleMgmtAppBarTitle => 'Gestion des modules';

  @override
  String get adminModuleMgmtCancel => 'Annuler';

  @override
  String get adminModuleMgmtCourseLabel => 'Cours';

  @override
  String adminModuleMgmtCourseLessonsSummary(String course, int count) {
    return '$course • $count leçons';
  }

  @override
  String get adminModuleMgmtCreate => 'Créer';

  @override
  String get adminModuleMgmtCreateCourseFirst => 'Créez d\'abord un cours.';

  @override
  String get adminModuleMgmtCreateError => 'Impossible de créer le module.';

  @override
  String get adminModuleMgmtCreatedMessage => 'Module créé.';

  @override
  String get adminModuleMgmtDelete => 'Supprimer';

  @override
  String adminModuleMgmtDeleteBody(String title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String get adminModuleMgmtDeleteError => 'Impossible de supprimer le module.';

  @override
  String adminModuleMgmtDeleteLessonsFirst(int count) {
    return 'Supprimez d\'abord les $count leçon(s) de ce module.';
  }

  @override
  String get adminModuleMgmtDeleteTitle => 'Supprimer le module';

  @override
  String get adminModuleMgmtDeletedMessage => 'Module supprimé.';

  @override
  String get adminModuleMgmtDescriptionLabel => 'Description';

  @override
  String get adminModuleMgmtEditTitle => 'Modifier le module';

  @override
  String get adminModuleMgmtFrenchDescriptionLabel =>
      'Description en français (facultatif)';

  @override
  String get adminModuleMgmtFrenchTitleLabel =>
      'Titre en français (facultatif)';

  @override
  String get adminModuleMgmtNewModule => 'Nouveau module';

  @override
  String get adminModuleMgmtNoModulesFound => 'Aucun module trouvé.';

  @override
  String get adminModuleMgmtSave => 'Enregistrer';

  @override
  String get adminModuleMgmtSearchHint => 'Rechercher des modules...';

  @override
  String get adminModuleMgmtTitleLabel => 'Titre';

  @override
  String get adminModuleMgmtUpdateError =>
      'Impossible de mettre à jour le module.';

  @override
  String get adminModuleMgmtUpdatedMessage => 'Module mis à jour.';

  @override
  String get adminProfileAccountDetails => 'Détails du compte';

  @override
  String get adminProfileAccountStatus => 'Statut du compte';

  @override
  String get adminProfileActive => 'Actif';

  @override
  String get adminProfileAdministratorRole => 'Administrateur';

  @override
  String get adminProfileDeactivated => 'Désactivé';

  @override
  String get adminProfileEditProfileLabel => 'Modifier le profil';

  @override
  String get adminProfileFullNameLabel => 'Nom complet';

  @override
  String get adminProfileLastLogin => 'Dernière connexion';

  @override
  String get adminProfileLogOut => 'Déconnexion';

  @override
  String get adminProfileMemberSince => 'Membre depuis';

  @override
  String get adminProfileNewPasswordHint =>
      'Laissez vide pour conserver le mot de passe actuel';

  @override
  String get adminProfileNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get adminProfileSaveChanges => 'Enregistrer les modifications';

  @override
  String get adminProfileSubtitle => 'Gérez votre compte administrateur';

  @override
  String get adminProfileThisSession => 'Cette session';

  @override
  String get adminProfileTitle => 'Mon profil';

  @override
  String get adminProfileUpdateError =>
      'Impossible de mettre à jour le profil.';

  @override
  String get adminProfileUpdatedMessage => 'Profil mis à jour.';

  @override
  String get adminProfileUploadError => 'Impossible de téléverser la photo.';

  @override
  String get adminBookEditorAddPageError => 'Impossible d\'ajouter la page.';

  @override
  String get adminBookEditorAddPageLabel => 'Ajouter une page';

  @override
  String get adminBookEditorAudioOptionalLabel => 'Audio (optionnel)';

  @override
  String get adminBookEditorAuthorFieldLabel => 'Auteur (optionnel)';

  @override
  String get adminBookEditorAuthoredPagesSegmentLabel => 'Pages rédigées';

  @override
  String get adminBookEditorBookSavedMessage => 'Livre enregistré.';

  @override
  String get adminBookEditorCategoryLabel => 'Catégorie';

  @override
  String get adminBookEditorChangeCoverLabel => 'Changer la couverture';

  @override
  String get adminBookEditorContainsIllustrationsLabel =>
      'Contient des illustrations';

  @override
  String get adminBookEditorContentTitle => 'Contenu';

  @override
  String get adminBookEditorCoverImageLabel => 'Image de couverture';

  @override
  String adminBookEditorCurrentFileLabel(String fileType, String fileUrl) {
    return 'Fichier actuel : $fileType — $fileUrl';
  }

  @override
  String get adminBookEditorDeletePageError =>
      'Impossible de supprimer la page.';

  @override
  String get adminBookEditorDescriptionFieldLabel => 'Description (optionnel)';

  @override
  String get adminBookEditorDetailsTitle => 'Détails';

  @override
  String get adminBookEditorEnglishTranslationLabel =>
      'Traduction anglaise (optionnel)';

  @override
  String get adminBookEditorEwondoTextLabel => 'Texte en ewondo';

  @override
  String get adminBookEditorFrenchDescriptionLabel =>
      'Description en français (optionnel)';

  @override
  String get adminBookEditorFrenchTranslationLabel =>
      'Traduction française (optionnel)';

  @override
  String get adminBookEditorIllustrationLabel => 'Illustration';

  @override
  String get adminBookEditorLevelLabel => 'Niveau';

  @override
  String get adminBookEditorNoFileUploadedMessage =>
      'Aucun fichier téléversé pour le moment.';

  @override
  String get adminBookEditorNoPagesMessage =>
      'Aucune page pour le moment. Ajoutez la première ci-dessous.';

  @override
  String adminBookEditorPageNumberLabel(int number) {
    return 'Page $number';
  }

  @override
  String get adminBookEditorReadingTimeLabel => 'Temps de lecture (min)';

  @override
  String get adminBookEditorRecommendedAgeLabel =>
      'Âge recommandé (années min.)';

  @override
  String get adminBookEditorReorderPagesError =>
      'Impossible de réorganiser les pages.';

  @override
  String get adminBookEditorReplaceAudioLabel => 'Remplacer l\'audio';

  @override
  String get adminBookEditorReplaceFileLabel => 'Remplacer le fichier';

  @override
  String get adminBookEditorSaveBookError =>
      'Impossible d\'enregistrer le livre.';

  @override
  String get adminBookEditorSavePageError =>
      'Impossible d\'enregistrer la page.';

  @override
  String get adminBookEditorSavePageLabel => 'Enregistrer la page';

  @override
  String get adminBookEditorSavingEllipsisLabel => 'Enregistrement…';

  @override
  String get adminBookEditorTitle => 'Modifier le livre';

  @override
  String get adminBookEditorTitleFieldLabel => 'Titre';

  @override
  String get adminBookEditorUploadAudioError =>
      'Impossible de téléverser l\'audio.';

  @override
  String get adminBookEditorUploadCoverError =>
      'Impossible de téléverser l\'image de couverture.';

  @override
  String get adminBookEditorUploadFileError =>
      'Impossible de téléverser le fichier.';

  @override
  String get adminBookEditorUploadFileLabel => 'Téléverser un PDF ou EPUB';

  @override
  String get adminBookEditorUploadIllustrationError =>
      'Impossible de téléverser l\'illustration.';

  @override
  String get adminBookEditorUploadedFileSegmentLabel => 'Fichier téléversé';

  @override
  String get adminSyllabaryMgmtAnalyzeError =>
      'Impossible d\'analyser ce contenu.';

  @override
  String get adminSyllabaryMgmtAnalyzeWithAiLabel => 'Analyser avec l\'IA';

  @override
  String get adminSyllabaryMgmtAnalyzingMessage =>
      'Analyse de la photo du tableau…';

  @override
  String get adminSyllabaryMgmtApproveImportLabel => 'Approuver et importer';

  @override
  String get adminSyllabaryMgmtChooseFileLabel => 'Choisir un fichier';

  @override
  String get adminSyllabaryMgmtClearLabel => 'Effacer';

  @override
  String get adminSyllabaryMgmtClipboardEmptyMessage =>
      'Rien d\'utilisable trouvé dans le presse-papiers.';

  @override
  String get adminSyllabaryMgmtContentPreviewTitle => 'Aperçu du contenu';

  @override
  String get adminSyllabaryMgmtDeleteEntryError =>
      'Impossible de supprimer l\'entrée.';

  @override
  String adminSyllabaryMgmtDeleteLetterDialogContent(int count, String letter) {
    return 'Supprimer les $count ligne(s) pour « $letter » ?';
  }

  @override
  String adminSyllabaryMgmtDeleteLetterDialogTitle(String letter) {
    return 'Supprimer « $letter »';
  }

  @override
  String get adminSyllabaryMgmtDeleteLetterError =>
      'Impossible de supprimer la lettre.';

  @override
  String adminSyllabaryMgmtDeleteLetterTooltip(String letter) {
    return 'Supprimer toutes les lignes pour « $letter »';
  }

  @override
  String adminSyllabaryMgmtDimensionsLabel(int width, int height) {
    return 'Dimensions : $width × $height';
  }

  @override
  String get adminSyllabaryMgmtDropZoneText =>
      'Collez une image, un tableau ou du texte ici\nou déposez un fichier';

  @override
  String get adminSyllabaryMgmtEmptyStateMessage =>
      'Aucun contenu du syllabaire pour le moment. Appuyez sur « Importer un tableau » ci-dessous — collez, déposez ou choisissez une photo, un PDF, un fichier Word, Excel ou texte d\'un tableau, et l\'IA l\'extraira pour que vous le vérifiiez avant l\'enregistrement.';

  @override
  String get adminSyllabaryMgmtEnglishTranslationLabel =>
      'Traduction anglaise (optionnel)';

  @override
  String get adminSyllabaryMgmtExampleSentenceLabel => 'Phrase d\'exemple';

  @override
  String get adminSyllabaryMgmtExampleWordLabel => 'Mot d\'exemple';

  @override
  String get adminSyllabaryMgmtExtractionNotesLabel =>
      'Notes d\'extraction de l\'IA';

  @override
  String get adminSyllabaryMgmtFrenchTranslationLabel => 'Traduction française';

  @override
  String adminSyllabaryMgmtImportedMessage(int count) {
    return '$count ligne(s) importée(s).';
  }

  @override
  String adminSyllabaryMgmtImportedWithFailuresMessage(
    int succeeded,
    int failed,
    String errorSuffix,
  ) {
    return '$succeeded ligne(s) importée(s), $failed échouée(s)$errorSuffix.';
  }

  @override
  String adminSyllabaryMgmtLetterDeletedMessage(String letter) {
    return '« $letter » supprimée.';
  }

  @override
  String get adminSyllabaryMgmtLetterFieldHint =>
      'ex. L (vide = voyelle seule)';

  @override
  String get adminSyllabaryMgmtLetterFieldLabel => 'Lettre';

  @override
  String adminSyllabaryMgmtLettersDetectedMessage(int count) {
    return '$count lettres détectées — vérifiez chacune ci-dessous.';
  }

  @override
  String adminSyllabaryMgmtLettersSummary(int letterCount, int rowCount) {
    return '$letterCount lettre(s), $rowCount ligne(s) au total';
  }

  @override
  String get adminSyllabaryMgmtLettersTitle => 'Lettres';

  @override
  String get adminSyllabaryMgmtListTitle => 'Gestion du syllabaire';

  @override
  String get adminSyllabaryMgmtNoChartsDetectedMessage =>
      'Aucun tableau du syllabaire n\'a été détecté. Essayez de relancer l\'analyse avec une photo ou un document plus net, ou revenez en arrière pour en importer un autre.';

  @override
  String get adminSyllabaryMgmtNoRowsDetectedMessage =>
      'Aucune ligne détectée — consultez les notes sur l\'écran de vérification.';

  @override
  String get adminSyllabaryMgmtNoRowsForLetterMessage =>
      'Aucune ligne détectée pour cette lettre.';

  @override
  String get adminSyllabaryMgmtNoneDetectedLabel => 'Aucune détectée';

  @override
  String get adminSyllabaryMgmtPasteFromClipboardLabel =>
      'Coller depuis le presse-papiers';

  @override
  String get adminSyllabaryMgmtPastedTextLabel => 'Texte collé';

  @override
  String get adminSyllabaryMgmtReanalyzeAction => 'Réanalyser';

  @override
  String get adminSyllabaryMgmtReanalyzeDialogContent =>
      'Cela remplace le brouillon actuel, y compris toutes les modifications que vous avez apportées.';

  @override
  String get adminSyllabaryMgmtReanalyzeDialogTitle => 'Réanalyser ?';

  @override
  String get adminSyllabaryMgmtRemoveLetterTooltip =>
      'Supprimer cette lettre et ses lignes';

  @override
  String get adminSyllabaryMgmtRemoveRowTooltip => 'Supprimer cette ligne';

  @override
  String get adminSyllabaryMgmtReviewTitle => 'Vérifier le tableau';

  @override
  String adminSyllabaryMgmtRowCountLabel(int count) {
    return '$count ligne(s)';
  }

  @override
  String adminSyllabaryMgmtRowNumberLabel(int number) {
    return 'Ligne $number';
  }

  @override
  String adminSyllabaryMgmtSizeLabel(String size) {
    return 'Taille : $size';
  }

  @override
  String get adminSyllabaryMgmtStep1Subtitle =>
      'Une photo, un tableau ou du texte — choisissez ce qui est le plus simple.';

  @override
  String get adminSyllabaryMgmtStep1Title => '1. Coller ou importer du contenu';

  @override
  String get adminSyllabaryMgmtSupportedFormatsText =>
      'Formats pris en charge : PNG, JPG, PDF, Word, Excel, TXT';

  @override
  String adminSyllabaryMgmtSyllableCountLabel(int count) {
    return '$count syllabe(s)';
  }

  @override
  String get adminSyllabaryMgmtSyllableLabel => 'Syllabe';

  @override
  String adminSyllabaryMgmtTypeLabel(String type) {
    return 'Type : $type';
  }

  @override
  String get adminSyllabaryMgmtUnknownServerError => 'Erreur serveur inconnue.';

  @override
  String get adminSyllabaryMgmtUploadChartLabel => 'Importer un tableau';

  @override
  String get adminSyllabaryMgmtVowelLabel => 'Voyelle';

  @override
  String get appTitle => 'NdaMinkoaba';

  @override
  String get appTagline => 'Apprendre • Préserver • Transmettre';

  @override
  String get poweredByNnanga => 'Propulsé par l\'IA Nnanga';

  @override
  String get commonSomethingWrong =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonContinueWithGoogle => 'Continuer avec Google';

  @override
  String get commonOrContinueWith => 'ou continuer avec';

  @override
  String commonOAuthNotConfigured(String provider) {
    return 'La connexion $provider n\'est pas encore configurée.';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonNone => 'Aucun';

  @override
  String get commonUnassigned => 'Non assigné';

  @override
  String get commonOptional => 'optionnel';

  @override
  String get languageSelectTitle => 'Choisissez votre langue';

  @override
  String get languageSelectSubtitle =>
      'Sélectionnez la langue que vous souhaitez utiliser dans l\'application.';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get languageFrenchLabel => 'Français';

  @override
  String get loginWelcomeTitle => 'Content de vous revoir 👋';

  @override
  String get loginSubtitle =>
      'Poursuivez votre apprentissage des langues africaines.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'Entrez votre e-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get forgotPasswordLabel => 'Mot de passe oublié ?';

  @override
  String get rememberMeLabel => 'Se souvenir de moi';

  @override
  String get comingSoonMessage => 'Bientôt disponible';

  @override
  String get loginButtonLabel => 'Connexion';

  @override
  String get noAccountPrompt => 'Vous n\'avez pas de compte ?';

  @override
  String get registerLinkLabel => 'S\'inscrire';

  @override
  String get loginEmptyFieldsError =>
      'Veuillez saisir votre e-mail et votre mot de passe.';

  @override
  String get loginFailedError =>
      'Échec de connexion. Vérifiez vos identifiants.';

  @override
  String get createAccountTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Commencez votre apprentissage des langues africaines.';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get fullNameHint => 'Entrez votre nom complet';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Ressaisissez votre mot de passe';

  @override
  String get registerButtonLabel => 'S\'inscrire';

  @override
  String get alreadyHaveAccountPrompt => 'Vous avez déjà un compte ?';

  @override
  String get loginLinkLabel => 'Connexion';

  @override
  String get registerFillAllFieldsError => 'Veuillez remplir tous les champs.';

  @override
  String get passwordsDoNotMatchError =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get passwordTooWeakError =>
      'Le mot de passe doit contenir au moins 8 caractères, une lettre et un chiffre.';

  @override
  String get registerSuccessMessage =>
      'Compte créé avec succès. Veuillez vous connecter.';

  @override
  String get registerFailedError =>
      'Échec de l\'inscription. Veuillez réessayer.';

  @override
  String get oauthSignInFailedError =>
      'Échec de la connexion. Veuillez réessayer.';

  @override
  String welcomeGreeting(String name) {
    return 'Bienvenue, $name ! 👋';
  }

  @override
  String get welcomeMessage =>
      'Bienvenue sur NdaMinkoaba. Votre parcours pour parler, préserver et transmettre votre langue commence maintenant.';

  @override
  String get welcomeTagline => 'Nos langues, notre héritage, notre identité';

  @override
  String get levelBeginner => 'Débutant';

  @override
  String get levelIntermediate => 'Intermédiaire';

  @override
  String get levelAdvanced => 'Avancé';

  @override
  String get startLearningButton => 'Commencer';

  @override
  String welcomeBackMessage(String name) {
    return 'Content de vous revoir, $name';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navCourses => 'Cours';

  @override
  String get navMyLearning => 'Progrès';

  @override
  String get navLearn => 'Apprendre';

  @override
  String get navPractice => 'Pratique';

  @override
  String get navAI => 'Tuteur IA';

  @override
  String get navProfile => 'Profil';

  @override
  String get learnerNavHome => 'Accueil';

  @override
  String get learnerNavMyCourses => 'Mes Cours';

  @override
  String get learnerNavLibrary => 'Bibliothèque';

  @override
  String get learnerNavLessons => 'Leçons';

  @override
  String get learnerNavVocabulary => 'Vocabulaire';

  @override
  String get learnerNavAiTutor => 'Assistant IA';

  @override
  String get learnerNavFavorites => 'Favoris';

  @override
  String get learnerNavHistory => 'Historique';

  @override
  String get learnerNavSettings => 'Paramètres';

  @override
  String get learnerShellTagline => 'Mbolo! Apprenons ensemble';

  @override
  String get learnerHistoryEmptyMessage =>
      'Aucune leçon consultée pour le moment. Ouvrez une leçon pour la voir ici.';

  @override
  String learnerHistoryViewedOn(String date) {
    return 'Consulté le $date';
  }

  @override
  String get learnerFavoritesEmptyMessage =>
      'Aucun favori pour le moment. Ajoutez une leçon à vos favoris pour la voir ici.';

  @override
  String get learnerFavoritesLessonsSection => 'Leçons';

  @override
  String get learnerFavoritesBooksSection => 'Livres';

  @override
  String get lessonsHubTitle => 'Leçons';

  @override
  String get lessonsHubSubtitle => 'Parcourez toutes les leçons d\'un cours';

  @override
  String get lessonsHubSelectLessonMessage =>
      'Sélectionnez une leçon pour voir ses détails.';

  @override
  String get lessonsHubEmptyMessage => 'Ce cours n\'a pas encore de leçons.';

  @override
  String get lessonsHubStartLessonButton => 'Commencer la leçon';

  @override
  String get lessonsHubLearningObjectivesTitle => 'Objectifs d\'apprentissage';

  @override
  String get lessonsHubWhatYouWillLearnTitle => 'Ce que vous allez apprendre';

  @override
  String lessonsHubMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboardSubtitle => 'Poursuivez votre apprentissage de l\'Ewondo';

  @override
  String get dashboardFallbackName => 'Apprenant';

  @override
  String get statLessons => 'Leçons';

  @override
  String get statCertificates => 'Certificats';

  @override
  String get statAvgScore => 'Score moyen';

  @override
  String get quickActionsTitle => 'Actions rapides';

  @override
  String get quickActionsSubtitle =>
      'Choisissez ce que vous voulez faire ensuite';

  @override
  String get actionCourses => 'Cours';

  @override
  String get actionVocabulary => 'Vocabulaire';

  @override
  String get actionNnanga => 'Nnanga IA';

  @override
  String get actionCertificates => 'Certificats';

  @override
  String get actionBible => 'Bible';

  @override
  String get actionBooks => 'Livres';

  @override
  String get dailyWordTitle => 'Mot du jour';

  @override
  String get dailyWordSubtitle => 'Apprenez un mot Ewondo chaque jour';

  @override
  String get dailyWordMeaning => 'Paix / Calme';

  @override
  String get dailyWordUsageHint =>
      'Utilisez-le aujourd\'hui dans une salutation ou une conversation simple.';

  @override
  String get dailyVerseTitle => 'Verset du jour';

  @override
  String get dailyVerseSubtitle => 'Un verset biblique en Ewondo, chaque jour';

  @override
  String get dailyContentEmpty =>
      'Rien n\'a encore été ajouté — revenez bientôt.';

  @override
  String get continueLearningTitle => 'Continuer l\'apprentissage';

  @override
  String get resumeButton => 'Reprendre';

  @override
  String progressPercentLabel(int percent) {
    return '$percent % terminé';
  }

  @override
  String get myLearningTitle => 'Mon apprentissage';

  @override
  String get myLearningSubtitle => 'Reprenez là où vous vous êtes arrêté';

  @override
  String get myLearningEmptyTitle => 'Rien en cours pour le moment';

  @override
  String get myLearningEmptyMessage =>
      'Commencez un cours et il apparaîtra ici.';

  @override
  String get coursesTitle => 'Cours';

  @override
  String get coursesSubtitle =>
      'Choisissez votre parcours d\'apprentissage de l\'Ewondo.';

  @override
  String get searchCoursesHint => 'Rechercher des cours...';

  @override
  String get levelAllLabel => 'Tous les niveaux';

  @override
  String get availableCoursesTitle => 'Cours disponibles';

  @override
  String get availableCoursesSubtitle => 'Commencez par le cours débutant';

  @override
  String get noCoursesTitle => 'Aucun cours pour le moment';

  @override
  String get noCoursesMessage =>
      'Aucun cours n\'est disponible à ce niveau pour le moment.';

  @override
  String lessonsCountLabel(int count) {
    return '$count leçons';
  }

  @override
  String levelLockedMessage(String level) {
    return 'Terminez $level pour déverrouiller ce niveau.';
  }

  @override
  String get lessonLockedMessage =>
      'Terminez la leçon précédente pour déverrouiller celle-ci.';

  @override
  String get courseNotFoundTitle => 'Cours introuvable';

  @override
  String get courseNotFoundMessage =>
      'Ce cours n\'a pas pu être chargé. Veuillez revenir en arrière et réessayer.';

  @override
  String get yourProgressLabel => 'Votre progression';

  @override
  String progressCompletedSummary(int percent, int done, int total) {
    return '$percent % terminé ($done/$total leçons)';
  }

  @override
  String get viewCertificateButton => 'Voir le certificat';

  @override
  String get claimCertificateButton => 'Réclamer votre certificat';

  @override
  String get notEligibleCertificateError =>
      'Pas encore éligible — terminez chaque leçon et réussissez chaque quiz d\'abord.';

  @override
  String get certificateEarnedTitle => 'Certificat obtenu !';

  @override
  String get certificateEarnedMessage =>
      'Vous avez terminé toutes les leçons et tous les quiz. Bravo !';

  @override
  String get certificateEarnedButton => 'Voir mon certificat';

  @override
  String get modulesTitle => 'Modules';

  @override
  String get modulesSubtitle => 'Apprenez étape par étape';

  @override
  String get downloadForOfflineButton => 'Télécharger pour un usage hors ligne';

  @override
  String downloadingOfflineLabel(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get downloadedOfflineLabel => 'Téléchargé pour un usage hors ligne';

  @override
  String get removeDownloadButton => 'Supprimer le téléchargement';

  @override
  String get removeDownloadConfirmTitle => 'Supprimer le cours téléchargé ?';

  @override
  String get removeDownloadConfirmMessage =>
      'Vous devrez le retélécharger pour l\'utiliser hors ligne.';

  @override
  String get downloadFailedMessage =>
      'Impossible de télécharger le cours. Vérifiez votre connexion et réessayez.';

  @override
  String get downloadCompleteMessage =>
      'Cours téléchargé — disponible hors ligne.';

  @override
  String get quizRequiresConnectivityMessage =>
      'Vous êtes hors ligne — connectez-vous à Internet pour passer ce quiz.';

  @override
  String lessonNumberLabel(int number) {
    return 'Leçon $number';
  }

  @override
  String get lessonNoContent =>
      'Aucun contenu disponible pour cette leçon pour le moment.';

  @override
  String get illustratedWordsTitle => 'Mots illustrés';

  @override
  String get summaryTitle => 'Résumé';

  @override
  String get noSummary => 'Aucun résumé disponible.';

  @override
  String get takeQuizButton => 'Passer le quiz';

  @override
  String get nextLessonButton => 'Leçon suivante';

  @override
  String get finishLessonButton => 'Terminer la leçon';

  @override
  String get previousLessonButton => 'Précédent';

  @override
  String get lessonCompletedMessage => 'Leçon terminée';

  @override
  String get lessonNotFoundTitle => 'Leçon introuvable';

  @override
  String get lessonNotFoundMessage =>
      'Cette leçon n\'a pas pu être chargée. Veuillez revenir en arrière et réessayer.';

  @override
  String get pleaseAnswerAllError =>
      'Veuillez répondre à toutes les questions.';

  @override
  String get quizSubmitError => 'Impossible de soumettre le quiz. Réessayez.';

  @override
  String get noQuizTitle => 'Pas encore de quiz';

  @override
  String get noQuizMessage =>
      'Aucun quiz n\'est disponible pour cette leçon pour le moment.';

  @override
  String passMarkLabel(int percent) {
    return 'Note de passage : $percent %';
  }

  @override
  String questionLabel(int number) {
    return 'Question $number';
  }

  @override
  String get submitQuizButton => 'Soumettre le quiz';

  @override
  String get youPassedTitle => 'Réussi !';

  @override
  String get notQuiteThereTitle => 'Pas tout à fait';

  @override
  String scoreSummary(int score, int passMark) {
    return 'Score : $score % (note de passage $passMark %)';
  }

  @override
  String get reviewTitle => 'Révision';

  @override
  String get tryAgainButton => 'Réessayer';

  @override
  String get continueButton => 'Continuer';

  @override
  String get vocabularyTitle => 'Vocabulaire';

  @override
  String get vocabularyHeroText => 'Apprenez un nouveau mot Ewondo à la fois';

  @override
  String get searchWordsHint => 'Rechercher des mots Ewondo...';

  @override
  String get levelAllShort => 'Tous';

  @override
  String get noWordsFoundTitle => 'Aucun mot trouvé';

  @override
  String get noWordsFoundMessage =>
      'Essayez une autre recherche ou un autre filtre de niveau.';

  @override
  String get nnangaTitle => 'Nnanga, tuteur IA';

  @override
  String get nnangaGreeting =>
      'Mbolo ! Je suis **Nnanga**, votre tuteur IA en Ewondo. Posez-moi des questions sur les mots, la grammaire ou la culture des leçons NdaMinkoaba.';

  @override
  String get nnangaErrorFallback =>
      'Nnanga n\'a pas pu répondre pour le moment. Veuillez réessayer.';

  @override
  String get nnangaInputHint => 'Posez une question à Nnanga...';

  @override
  String get nnangaGroundedBadge => 'Depuis les leçons officielles';

  @override
  String get nnangaGeneralBadge => 'Connaissance générale';

  @override
  String get myCertificatesTitle => 'Mes certificats';

  @override
  String get myCertificatesSubtitle =>
      'Terminez un cours et réussissez ses quiz pour obtenir un certificat.';

  @override
  String get noCertificatesTitle => 'Aucun certificat pour le moment';

  @override
  String get noCertificatesMessage =>
      'Terminez toutes les leçons et tous les quiz d\'un cours pour obtenir votre premier certificat.';

  @override
  String get booksTitle => 'Bibliothèque de Livres';

  @override
  String get booksSubtitle => 'Découvrez et lisez des livres en Ewondo.';

  @override
  String get noBooksTitle => 'Aucun livre pour le moment';

  @override
  String get noBooksMessage =>
      'Revenez bientôt — de nouveaux livres apparaîtront ici.';

  @override
  String get bookLoadError =>
      'Impossible de charger ce livre. Veuillez réessayer.';

  @override
  String get booksHubCategoryAll => 'Tous';

  @override
  String get booksHubSearchHint => 'Rechercher un livre...';

  @override
  String get booksHubSelectBookMessage =>
      'Sélectionnez un livre pour voir ses détails.';

  @override
  String get booksHubReadButton => 'Lire le livre';

  @override
  String get booksHubAddToFavoritesButton => 'Ajouter aux favoris';

  @override
  String get booksHubRemoveFromFavoritesButton => 'Retirer des favoris';

  @override
  String get booksHubNewBadge => 'Nouveau';

  @override
  String get booksHubCategoryLabel => 'Catégorie';

  @override
  String get booksHubLevelLabel => 'Niveau';

  @override
  String get booksHubLanguageLabel => 'Langue';

  @override
  String get booksHubPagesLabel => 'Pages';

  @override
  String get booksHubPublishedLabel => 'Publié le';

  @override
  String booksHubMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String booksHubRecommendedAgeShort(int age) {
    return '$age+ ans';
  }

  @override
  String get certificateNotFoundTitle => 'Certificat introuvable';

  @override
  String get certificateNotFoundMessage =>
      'Ce certificat n\'a pas pu être chargé. Veuillez revenir en arrière et réessayer.';

  @override
  String get certificateOfCompletion => 'Certificat de réussite';

  @override
  String get certificateCodeLabel => 'Code du certificat';

  @override
  String get issuedOnLabel => 'Délivré le';

  @override
  String get generatePdfButton => 'Générer le PDF';

  @override
  String get viewDownloadPdfButton => 'Voir / Télécharger le PDF';

  @override
  String get generatePdfError => 'Impossible de générer le PDF. Réessayez.';

  @override
  String get bibleTitle => 'Sainte Bible';

  @override
  String get bibleSubtitle =>
      'Lisez les Écritures en Ewondo, à côté de votre langue';

  @override
  String get bibleFourGospelsTitle => 'Les Quatre Évangiles';

  @override
  String get bibleFourGospelsSubtitle => 'La vie et les enseignements de Jésus';

  @override
  String get bibleOtherBooksTitle => 'Autres livres';

  @override
  String get bibleComingSoonLabel => 'Bientôt disponible';

  @override
  String bibleChaptersCountLabel(int count) {
    return '$count chapitres';
  }

  @override
  String get bibleNoContentTitle => 'Aucun contenu biblique pour le moment';

  @override
  String get bibleNoContentMessage =>
      'Revenez bientôt — de nouveaux chapitres sont ajoutés.';

  @override
  String get bibleSelectChapterTitle => 'Choisir un chapitre';

  @override
  String bibleChapterLabel(int number) {
    return 'Chapitre $number';
  }

  @override
  String bibleVerseCountLabel(int count) {
    return '$count versets';
  }

  @override
  String get biblePreviousChapter => 'Précédent';

  @override
  String get bibleNextChapter => 'Suivant';

  @override
  String get bibleTranslationPending => 'Traduction pas encore disponible';

  @override
  String get bibleChapterNotFoundTitle => 'Chapitre introuvable';

  @override
  String get bibleChapterNotFoundMessage =>
      'Ce chapitre n\'a pas pu être chargé. Veuillez revenir en arrière et réessayer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get statCoursesEnrolled => 'Cours inscrits';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe (facultatif)';

  @override
  String get newPasswordHint =>
      'Laissez vide pour conserver le mot de passe actuel';

  @override
  String get saveChangesButton => 'Enregistrer les modifications';

  @override
  String get profileUpdatedMessage => 'Profil mis à jour';

  @override
  String get profileUpdateError => 'Impossible de mettre à jour le profil.';

  @override
  String get logOutButton => 'Déconnexion';

  @override
  String get switchLanguageTitle => 'Langue d\'apprentissage';

  @override
  String get appLanguageTitle => 'Langue de l\'application';

  @override
  String get bookReaderTextSizeTooltip => 'Taille du texte';

  @override
  String get uploadPhotoTooltip => 'Téléverser une photo';

  @override
  String get couldNotUploadPhotoError => 'Impossible de téléverser la photo.';

  @override
  String get chooseLanguageTitle => 'Choisir une langue';

  @override
  String get chooseLanguageQuestion =>
      'Quelle langue souhaitez-vous apprendre ?';

  @override
  String get chooseLanguageHint =>
      'Vous pouvez changer de langue à tout moment depuis votre profil.';

  @override
  String get chooseLanguageEmptyTitle =>
      'Aucune langue n\'est disponible pour le moment.';

  @override
  String get chooseLanguageOnlyCurrentMessage =>
      'Vous apprenez déjà la seule langue publiée pour le moment.';

  @override
  String get chooseLanguageLoadError =>
      'Impossible de charger les langues. Vérifiez votre connexion au serveur et réessayez.';

  @override
  String continueLearningWelcomeBack(String name) {
    return 'Bon retour, $name !';
  }

  @override
  String get continueLearningWelcomeBackNoName => 'Bon retour !';

  @override
  String get continueLearningSubtitle =>
      'Que souhaitez-vous faire aujourd\'hui ?';

  @override
  String continueLearningContinueTitle(String language) {
    return 'Continuer avec $language ?';
  }

  @override
  String get continueLearningContinueFallback =>
      'Reprendre là où vous vous êtes arrêté ?';

  @override
  String get continueLearningContinueSubtitle =>
      'Reprenez votre parcours d\'apprentissage là où vous l\'avez laissé.';

  @override
  String get continueLearningNewLanguageTitle =>
      'Commencer une nouvelle langue ?';

  @override
  String get continueLearningNewLanguageSubtitle =>
      'Découvrez une autre langue camerounaise depuis le début.';

  @override
  String get adminNeedsWiderScreen =>
      'Le tableau de bord administrateur nécessite un écran plus large.';

  @override
  String get adminResizeBrowserMessage =>
      'Veuillez redimensionner votre fenêtre ou utiliser un ordinateur de bureau.';

  @override
  String get adminNavOverview => 'Vue d\'ensemble';

  @override
  String get adminNavLanguages => 'Langues';

  @override
  String get adminNavUsers => 'Utilisateurs';

  @override
  String get adminNavCertificates => 'Certificats';

  @override
  String get adminNavReportsActivity => 'Rapports et activité';

  @override
  String get adminNavDashboard => 'Tableau de bord';

  @override
  String get adminNavLearners => 'Apprenants';

  @override
  String get adminNavCourses => 'Cours';

  @override
  String get adminNavLessonsContent => 'Leçons et contenu';

  @override
  String get adminNavVocabulary => 'Vocabulaire';

  @override
  String get adminNavAssessments => 'Évaluations';

  @override
  String get adminNavAiTutor => 'Tuteur IA';

  @override
  String get adminNavBible => 'Bible';

  @override
  String get adminNavBooks => 'Livres';

  @override
  String get adminNavDaily => 'Phrase et verset du jour';

  @override
  String get adminNavReports => 'Rapports';

  @override
  String get adminNavSettings => 'Paramètres';

  @override
  String adminLanguageActiveSuffix(String name) {
    return '$name · Actif';
  }

  @override
  String get adminBackToAllLanguages => 'Retour à toutes les langues';

  @override
  String get adminRoleFallback => 'Administrateur';

  @override
  String get adminSuperAdminFallback => 'Super administrateur';

  @override
  String get adminLanguageFallback => 'Langue';

  @override
  String get adminDashboardOverviewTitle => 'Vue d\'ensemble';

  @override
  String get adminDashboardOverviewSubtitle =>
      'Voici ce qui se passe sur la plateforme aujourd\'hui.';

  @override
  String get adminStatActiveLanguages => 'Langues actives';

  @override
  String get adminStatTotalLearners => 'Total des apprenants';

  @override
  String get adminStatPublishedCourses => 'Cours publiés';

  @override
  String get adminStatLessonsCompleted => 'Leçons terminées';

  @override
  String get adminLanguageManagementTitle => 'Gestion des langues';

  @override
  String get adminAddLanguageButton => 'Ajouter une langue';

  @override
  String get adminViewAllLanguages => 'Voir toutes les langues';

  @override
  String get adminColLanguage => 'Langue';

  @override
  String get adminColCode => 'Code';

  @override
  String get adminColLearners => 'Apprenants';

  @override
  String get adminColCourses => 'Cours';

  @override
  String get adminColProgress => 'Progression';

  @override
  String get adminColStatus => 'Statut';

  @override
  String get adminColActions => 'Actions';

  @override
  String get adminOpenDashboard => 'Ouvrir le tableau de bord';

  @override
  String get adminStatusActive => 'Actif';

  @override
  String get adminStatusDraft => 'Brouillon';

  @override
  String get adminAddLanguageNameHint => 'Nom (ex. Bassa)';

  @override
  String get adminAddLanguageCodeHint => 'Code (ex. bas)';

  @override
  String get adminAddLanguageCountryHint => 'Pays (optionnel)';

  @override
  String get adminLanguageAddedMessage =>
      'Langue ajoutée. Elle démarre inactive — publiez-la une fois son contenu prêt.';

  @override
  String get adminCouldNotAddLanguage => 'Impossible d\'ajouter la langue.';

  @override
  String get adminCourseCompletionTitle => 'Achèvement des cours';

  @override
  String get adminLevelBeginner => 'Débutant';

  @override
  String get adminLevelIntermediate => 'Intermédiaire';

  @override
  String get adminLevelAdvanced => 'Avancé';

  @override
  String get adminQuickActionsTitle => 'Actions rapides';

  @override
  String get adminQuickActionCreateCourse => 'Créer un cours';

  @override
  String get adminQuickActionAddUser => 'Ajouter un utilisateur';

  @override
  String get adminQuickActionUploadContent => 'Téléverser du contenu';

  @override
  String get adminRecentActivityTitle => 'Activité récente';

  @override
  String get adminNoRecentActivity => 'Aucune activité récente.';

  @override
  String get adminViewAllActivity => 'Voir toute l\'activité';

  @override
  String get adminLearnerActivityTitle => 'Activité des apprenants';

  @override
  String get adminLegendNewLearners => 'Nouveaux apprenants';

  @override
  String get adminLegendActiveLearners => 'Apprenants actifs';

  @override
  String get adminNoActivityData => 'Aucune donnée d\'activité pour le moment.';

  @override
  String get adminAiContentReviewTitle => 'Révision de contenu IA';

  @override
  String adminAiReviewCountMessage(int count) {
    return '$count brouillons de leçon générés par IA sont en attente de révision';
  }

  @override
  String get adminReviewContentButton => 'Réviser le contenu';

  @override
  String get adminSystemNoticeTitle => 'Avis système';

  @override
  String get adminAllSystemsOperational =>
      'Tous les systèmes sont opérationnels';

  @override
  String adminLastUpdatedLabel(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get adminAuditVerbCreated => 'a créé';

  @override
  String get adminAuditVerbUpdated => 'a modifié';

  @override
  String get adminAuditVerbDeleted => 'a supprimé';

  @override
  String adminAuditActivityLine(String actor, String verb, String entity) {
    return '$actor $verb $entity';
  }

  @override
  String adminLanguageDashboardTitle(String language) {
    return 'Tableau de bord $language';
  }

  @override
  String adminLanguageDashboardSubtitle(String language) {
    return 'Contenu et activité des apprenants pour $language.';
  }

  @override
  String get adminNewCourseButton => 'Nouveau cours';

  @override
  String get adminStatLessons => 'Leçons';

  @override
  String get adminCourseManagementTitle => 'Gestion des cours';

  @override
  String get adminViewAllCourses => 'Voir tous les cours';

  @override
  String get adminColCourseSingle => 'Cours';

  @override
  String get adminColLevel => 'Niveau';

  @override
  String get adminContentWorkflowTitle => 'Flux de contenu';

  @override
  String get adminWorkflowDraft => 'Brouillon';

  @override
  String get adminWorkflowInReview => 'En révision';

  @override
  String get adminWorkflowApproved => 'Approuvé';

  @override
  String get adminWorkflowPublished => 'Publié';

  @override
  String get adminContentQualityTitle => 'Qualité du contenu';

  @override
  String get adminQuickActionNewLesson => 'Nouvelle leçon';

  @override
  String get adminQuickActionNewQuiz => 'Nouveau quiz';

  @override
  String get adminQuickActionTrainAi => 'Entraîner l\'IA';

  @override
  String get adminRecentCertificatesTitle => 'Certificats récents';

  @override
  String get adminNoCertificatesYet =>
      'Aucun certificat délivré pour le moment.';

  @override
  String adminCertificateCompletedLine(String learner, String course) {
    return '$learner a terminé $course';
  }

  @override
  String get adminNnangaAiReviewTitle => 'Révision IA Nnanga';

  @override
  String adminNnangaReviewCountMessage(int count, String language) {
    return '$count brouillons de leçon $language générés par IA sont en attente de révision';
  }

  @override
  String get adminTabAll => 'Tous';

  @override
  String adminUpdatedCountMessage(int count) {
    return '$count cours mis à jour.';
  }

  @override
  String get adminCouldNotUpdateCourses =>
      'Impossible de mettre à jour les cours.';

  @override
  String get adminAssignReviewerTitle => 'Assigner un réviseur';

  @override
  String adminAssignReviewerPrompt(int count) {
    return 'Assigner un réviseur à $count cours sélectionné(s).';
  }

  @override
  String get adminNoReviewersAvailable =>
      'Aucun enseignant ou administrateur disponible.';

  @override
  String get adminReviewerAssignedMessage => 'Réviseur assigné.';

  @override
  String get adminCouldNotAssignReviewer =>
      'Impossible d\'assigner le réviseur.';

  @override
  String adminCourseManagementSubtitle(String language) {
    return 'Gérez tous les cours de $language.';
  }

  @override
  String get adminStatTotalCourses => 'Total des cours';

  @override
  String get adminStatDrafts => 'Brouillons';

  @override
  String get adminSearchCoursesHint => 'Rechercher des cours...';

  @override
  String get adminAllLevelsLabel => 'Tous les niveaux';

  @override
  String get adminBulkPublish => 'Publier';

  @override
  String get adminBulkMoveToDraft => 'Mettre en brouillon';

  @override
  String get adminBulkArchive => 'Archiver';

  @override
  String get adminColLessons => 'Leçons';

  @override
  String get adminColReviewer => 'Réviseur';

  @override
  String get adminPublishingPipelineTitle => 'Pipeline de publication';

  @override
  String get adminContentHealthTitle => 'Santé du contenu';

  @override
  String get adminRecentCourseActivityTitle => 'Activité récente des cours';

  @override
  String get adminWorkflowArchived => 'Archivé';

  @override
  String get adminHealthLessonsPublished => 'Leçons publiées';

  @override
  String get adminHealthLessonsApproved => 'Leçons approuvées';

  @override
  String get adminHealthLessonsInReview => 'Leçons en révision';

  @override
  String get adminHealthLessonsInDraft => 'Leçons en brouillon';

  @override
  String get adminWizardStepDetails => 'Détails du cours';

  @override
  String get adminWizardStepCurriculum => 'Programme';

  @override
  String get adminWizardStepResources => 'Ressources pédagogiques';

  @override
  String get adminWizardStepAssessment => 'Évaluation';

  @override
  String get adminWizardStepReview => 'Révision et publication';

  @override
  String get adminTitleMinLengthError =>
      'Le titre doit comporter au moins 3 caractères.';

  @override
  String get adminCourseCreatedMessage =>
      'Cours créé. Continuez à le développer ci-dessous.';

  @override
  String get adminCouldNotSaveCourse => 'Impossible d\'enregistrer le cours.';

  @override
  String get adminLearningResourcesSavedMessage =>
      'Ressources pédagogiques enregistrées.';

  @override
  String get adminCouldNotSaveGeneric => 'Impossible d\'enregistrer.';

  @override
  String get adminCoverUpdatedMessage => 'Couverture mise à jour.';

  @override
  String get adminCouldNotUploadCover =>
      'Impossible de téléverser la couverture.';

  @override
  String get adminArchiveCourseTitle => 'Archiver le cours';

  @override
  String get adminArchiveCourseConfirm =>
      'Les cours archivés sont masqués aux apprenants mais pas supprimés. Continuer ?';

  @override
  String get adminCourseArchivedMessage => 'Cours archivé.';

  @override
  String get adminCouldNotArchiveCourse => 'Impossible d\'archiver le cours.';

  @override
  String get adminCoursePublishedMessage => 'Cours publié.';

  @override
  String get adminCouldNotPublishCourse => 'Impossible de publier le cours.';

  @override
  String get adminModuleLessonsFirstError =>
      'Supprimez d\'abord les leçons de ce module.';

  @override
  String get adminCouldNotAddModule => 'Impossible d\'ajouter le module.';

  @override
  String get adminCouldNotUpdateModule =>
      'Impossible de mettre à jour le module.';

  @override
  String get adminCouldNotDeleteModule => 'Impossible de supprimer le module.';

  @override
  String get adminLessonContentMinLengthError =>
      'Le contenu de la leçon doit comporter au moins 10 caractères.';

  @override
  String get adminCouldNotAddLesson => 'Impossible d\'ajouter la leçon.';

  @override
  String get adminCouldNotUpdateLesson =>
      'Impossible de mettre à jour la leçon.';

  @override
  String get adminCouldNotDeleteLesson => 'Impossible de supprimer la leçon.';

  @override
  String get adminCouldNotMoveLesson => 'Impossible de déplacer la leçon.';

  @override
  String get adminCouldNotReorderLesson =>
      'Impossible de réorganiser la leçon.';

  @override
  String get adminAddModuleTitle => 'Ajouter un module';

  @override
  String get adminRenameModuleTitle => 'Renommer le module';

  @override
  String adminAddLessonToTitle(String module) {
    return 'Ajouter une leçon à « $module »';
  }

  @override
  String adminEditLessonTitle(String lesson) {
    return 'Modifier « $lesson »';
  }

  @override
  String get adminFieldTitle => 'Titre';

  @override
  String get adminFieldDescription => 'Description';

  @override
  String get adminFieldFrenchTitle => 'Titre français';

  @override
  String get adminFieldFrenchDescription => 'Description française';

  @override
  String get adminFieldSummary => 'Résumé';

  @override
  String get adminFieldContent => 'Contenu';

  @override
  String get adminFieldFrenchSummary => 'Résumé français';

  @override
  String get adminFieldFrenchContent => 'Contenu français';

  @override
  String get adminCreateCourseTitle => 'Créer un cours';

  @override
  String get adminEditCourseTitle => 'Modifier le cours';

  @override
  String adminBuildNewCourseSubtitle(String language) {
    return 'Créez un nouveau cours pour $language.';
  }

  @override
  String get adminThisLanguageFallback => 'Cette langue';

  @override
  String get adminBackButton => 'Retour';

  @override
  String get adminSavingLabel => 'Enregistrement...';

  @override
  String get adminCreateAndContinueButton => 'Créer et continuer';

  @override
  String get adminNextButton => 'Suivant';

  @override
  String get adminCourseCoverTitle => 'Couverture du cours';

  @override
  String get adminUploadCoverButton => 'Téléverser la couverture';

  @override
  String get adminUploadingLabel => 'Téléversement...';

  @override
  String get adminGenerateWithAiTooltip =>
      'La génération de couverture par IA n\'est pas encore disponible.';

  @override
  String get adminGenerateWithAiButton => 'Générer avec l\'IA';

  @override
  String get adminPublishingSettingsTitle => 'Paramètres de publication';

  @override
  String get adminVisibilityLabel => 'Visibilité';

  @override
  String get adminVisibilityPublic => 'Public';

  @override
  String get adminVisibilityPrivate => 'Privé';

  @override
  String get adminEnrollmentLabel => 'Inscription';

  @override
  String get adminEnrollmentOpen => 'Ouverte';

  @override
  String get adminEnrollmentInviteOnly => 'Sur invitation';

  @override
  String get adminIssueCertificateLabel => 'Délivrer un certificat';

  @override
  String get adminCourseTeamTitle => 'Équipe du cours';

  @override
  String get adminInstructorLabel => 'Instructeur';

  @override
  String get adminContentReadinessTitle => 'Préparation du contenu';

  @override
  String get adminReadyLabel => 'Prêt';

  @override
  String get adminDangerZoneTitle => 'Zone de danger';

  @override
  String get adminArchiveCourseButton => 'Archiver le cours';

  @override
  String get adminSubtitleOptionalLabel => 'Sous-titre (optionnel)';

  @override
  String get adminFrenchTitleOptionalLabel => 'Titre français (optionnel)';

  @override
  String get adminCategoryOptionalLabel => 'Catégorie (optionnelle)';

  @override
  String get adminFrenchDescriptionOptionalLabel =>
      'Description française (optionnelle)';

  @override
  String get adminEstimatedHoursLabel => 'Heures estimées';

  @override
  String get adminTagsLabel => 'Étiquettes';

  @override
  String get adminAddTagHint => 'Ajoutez une étiquette et appuyez sur Entrée';

  @override
  String get adminLearningObjectivesLabel => 'Objectifs pédagogiques';

  @override
  String get adminAddObjectiveHint =>
      'Ajoutez un objectif et appuyez sur Entrée';

  @override
  String get adminModulesLessonsTitle => 'Modules et leçons';

  @override
  String get adminNoModulesYetMessage =>
      'Aucun module pour le moment. Ajoutez-en un pour commencer à ajouter des leçons.';

  @override
  String adminLessonsCountLabel(int count) {
    return '$count leçons';
  }

  @override
  String get adminRenameModuleTooltip => 'Renommer le module';

  @override
  String get adminDeleteModuleTooltip => 'Supprimer le module';

  @override
  String get adminMenuBlockEditor => 'Éditeur de blocs';

  @override
  String get adminMenuMoveToAnotherModule => 'Déplacer vers un autre module';

  @override
  String get adminMenuChangePosition => 'Changer la position';

  @override
  String get adminMenuManageImages => 'Gérer les images';

  @override
  String get adminMenuManageQuiz => 'Gérer le quiz';

  @override
  String get adminAddLessonButton => 'Ajouter une leçon';

  @override
  String get adminSupportLanguageCodesLabel => 'Codes de langue de support';

  @override
  String get adminSupportLanguageHint => 'ex. fr, en — appuyez sur Entrée';

  @override
  String get adminPrerequisiteCourseLabel => 'Cours prérequis';

  @override
  String get adminManageQuizFromBuilderMessage =>
      'Gérez le quiz de chaque leçon depuis l\'éditeur de quiz existant.';

  @override
  String get adminAddLessonsFirstMessage =>
      'Ajoutez d\'abord des leçons dans l\'étape Programme.';

  @override
  String get adminManageQuizButton => 'Gérer le quiz';

  @override
  String adminModulesCountLabel(int count) {
    return '$count modules';
  }

  @override
  String adminHoursSuffixLabel(int hours) {
    return '$hours h';
  }

  @override
  String get adminReadinessChecklistTitle => 'Liste de préparation';

  @override
  String get adminChecklistCourseDetailsComplete => 'Détails du cours complets';

  @override
  String adminChecklistLessonsReady(int ready, int total) {
    return 'Leçons prêtes ($ready/$total)';
  }

  @override
  String get adminChecklistAssessmentPresent => 'Évaluation présente';

  @override
  String adminChecklistAudioMissing(int count) {
    return 'Audio manquant sur $count leçon(s)';
  }

  @override
  String get adminSetPublicationDateButton => 'Définir la date de publication';

  @override
  String get adminPublishCourseButton => 'Publier le cours';

  @override
  String get adminBlockTypeText => 'Texte';

  @override
  String get adminBlockTypeDialogue => 'Dialogue';

  @override
  String get adminBlockTypeAudio => 'Audio';

  @override
  String get adminBlockTypeImage => 'Image';

  @override
  String get adminBlockTypeVocabulary => 'Vocabulaire';

  @override
  String get adminBlockTypeQuiz => 'Quiz';

  @override
  String get adminBlockTypePronunciation => 'Prononciation';

  @override
  String get adminBlockTypeExercise => 'Exercice';

  @override
  String get adminBlockTypeVideo => 'Vidéo';

  @override
  String get adminAiActionGenerateExamples => 'Générer des exemples';

  @override
  String get adminAiActionCreateQuiz => 'Créer un quiz';

  @override
  String get adminAiActionSimplifyContent => 'Simplifier le contenu';

  @override
  String get adminAiActionCheckTranslations => 'Vérifier les traductions';

  @override
  String get adminCouldNotAddBlock => 'Impossible d\'ajouter le bloc.';

  @override
  String get adminRemoveBlockTitle => 'Supprimer le bloc';

  @override
  String get adminRemoveBlockConfirm => 'Supprimer ce bloc de la leçon ?';

  @override
  String get adminRemoveButton => 'Supprimer';

  @override
  String get adminCouldNotRemoveBlock => 'Impossible de supprimer le bloc.';

  @override
  String get adminCouldNotReorderBlocks =>
      'Impossible de réorganiser les blocs.';

  @override
  String get adminSubmittedForReviewMessage => 'Soumis pour révision.';

  @override
  String get adminCouldNotSubmitForReview =>
      'Impossible de soumettre pour révision.';

  @override
  String get adminCouldNotPostComment =>
      'Impossible de publier le commentaire.';

  @override
  String get adminNnangaNoRespondError => 'Nnanga n\'a pas pu répondre.';

  @override
  String get adminNnangaSuggestionLabel => 'Suggestion de Nnanga';

  @override
  String get adminAddedAsTextBlockMessage =>
      'Ajouté comme nouveau bloc de texte.';

  @override
  String get adminCouldNotApplySuggestion =>
      'Impossible d\'appliquer la suggestion.';

  @override
  String get adminDraftQuestionsAddedMessage =>
      'Questions provisoires ajoutées au quiz.';

  @override
  String get adminCouldNotApplyQuizDraft =>
      'Impossible d\'appliquer le brouillon de quiz.';

  @override
  String get adminLessonEditorTitle => 'Éditeur de leçon';

  @override
  String get adminSubmitForReviewButton => 'Soumettre pour révision';

  @override
  String get adminAddBlockTitle => 'Ajouter un bloc';

  @override
  String get adminNoBlocksYetMessage =>
      'Aucun bloc pour le moment. Ajoutez-en un depuis la palette à gauche pour commencer à créer cette leçon.';

  @override
  String get adminMoveUpTooltip => 'Monter';

  @override
  String get adminMoveDownTooltip => 'Descendre';

  @override
  String get adminRemoveBlockTooltip => 'Supprimer le bloc';

  @override
  String get adminSaveBlockButton => 'Enregistrer le bloc';

  @override
  String get adminEyebrowLabelOptional => 'Étiquette d\'en-tête (optionnelle)';

  @override
  String get adminFrenchContentOptionalLabel => 'Contenu français (optionnel)';

  @override
  String get adminSpeakerLabel => 'Intervenant';

  @override
  String get adminLineLabel => 'Ligne';

  @override
  String get adminFrenchLineOptionalLabel => 'Ligne française (optionnelle)';

  @override
  String get adminAddTurnButton => 'Ajouter un tour';

  @override
  String get adminAudioUrlLabel => 'URL audio';

  @override
  String get adminUploadButton => 'Téléverser';

  @override
  String get adminVideoUrlLabel => 'URL vidéo';

  @override
  String get adminVideoNotVisibleNotice =>
      'La vidéo est enregistrée mais pas encore visible par les apprenants — aucun lecteur n\'existe encore sur l\'écran de leçon.';

  @override
  String get adminWordLabelField => 'Mot / étiquette';

  @override
  String get adminImageUrlLabel => 'URL de l\'image';

  @override
  String get adminCaptionOptionalLabel => 'Légende (optionnelle)';

  @override
  String get adminSelectWordHint => 'Sélectionnez un mot';

  @override
  String get adminInstructionsOptionalLabel => 'Instructions (optionnelles)';

  @override
  String get adminNoQuizYetNotice =>
      'Aucun quiz n\'existe encore pour cette leçon. Créez-en un depuis l\'étape Évaluation, puis enregistrez à nouveau ce bloc.';

  @override
  String get adminLinkedToQuizMessage => 'Lié au quiz de cette leçon.';

  @override
  String get adminExerciseNotVisibleNotice =>
      'Les blocs d\'exercice sont enregistrés mais pas encore affichés aux apprenants — aucun widget d\'exercice interactif n\'existe encore.';

  @override
  String get adminExerciseDataJsonLabel => 'Données de l\'exercice (JSON)';

  @override
  String get adminExerciseInvalidJsonError =>
      'Le contenu de l\'exercice doit être un JSON valide.';

  @override
  String get adminCouldNotSaveBlock => 'Impossible d\'enregistrer le bloc.';

  @override
  String get adminCouldNotUploadImage => 'Impossible de téléverser l\'image.';

  @override
  String get adminCouldNotUploadAudio => 'Impossible de téléverser l\'audio.';

  @override
  String get adminNnangaAssistantTitle => 'Assistant IA Nnanga';

  @override
  String get adminNnangaInstructionHint =>
      'Instruction facultative pour Nnanga...';

  @override
  String get adminThinkingLabel => 'Réflexion en cours...';

  @override
  String get adminAskNnangaButton => 'Demander à Nnanga';

  @override
  String get adminAddDraftQuestionsButton =>
      'Ajouter les questions provisoires au quiz';

  @override
  String get adminApplyAsTextBlockButton =>
      'Appliquer comme nouveau bloc de texte';

  @override
  String get adminContentChecklistTitle => 'Liste de contrôle du contenu';

  @override
  String get adminChecklistTextContent => 'Contenu texte';

  @override
  String get adminChecklistFrenchTranslation => 'Traduction française';

  @override
  String get adminChecklistQuizLinked => 'Quiz lié';

  @override
  String get adminReviewCollaborationTitle => 'Révision et collaboration';

  @override
  String get adminCommentsLabel => 'Commentaires';

  @override
  String get adminNoCommentsYetMessage => 'Aucun commentaire pour le moment.';

  @override
  String get adminAddCommentHint => 'Ajouter un commentaire...';

  @override
  String get commonNoResults => 'Aucun résultat.';

  @override
  String get adminOverallLabel => 'Global';

  @override
  String get adminNavNotifications => 'Notifications';

  @override
  String get adminNotificationsTitle => 'Notifications';

  @override
  String get adminNotificationsSubtitle =>
      'Envoyez un message à tous les apprenants ou notifiez une personne directement.';

  @override
  String get adminBroadcastCardTitle => 'Diffuser à tous les apprenants';

  @override
  String get adminBroadcastCardDescription =>
      'Ce message est envoyé immédiatement à tous les comptes apprenants actifs.';

  @override
  String get adminNotifyUserCardTitle => 'Notifier un utilisateur';

  @override
  String get adminNotifyUserCardDescription =>
      'Recherchez un utilisateur ci-dessous, puis envoyez-lui une notification directe.';

  @override
  String get adminSearchUserHint => 'Rechercher par nom ou e-mail...';

  @override
  String get adminNoUserSelectedHint =>
      'Aucun utilisateur sélectionné pour le moment.';

  @override
  String adminNotifyRecipientLine(String name, String email) {
    return 'À : $name ($email)';
  }

  @override
  String get adminNotificationTitleHint => 'Titre';

  @override
  String get adminNotificationMessageHint => 'Message';

  @override
  String get adminSendBroadcastButton => 'Envoyer la diffusion';

  @override
  String get adminSendNotificationButton => 'Envoyer la notification';

  @override
  String get adminBroadcastSentMessage =>
      'Diffusion envoyée à tous les apprenants.';

  @override
  String get adminCouldNotSendBroadcast =>
      'Impossible d\'envoyer la diffusion.';

  @override
  String get adminNotificationSentMessage => 'Notification envoyée.';

  @override
  String get adminCouldNotSendNotification =>
      'Impossible d\'envoyer la notification.';

  @override
  String get dashboardProgressTitle => 'Votre progression';

  @override
  String lessonsCompletedCount(int count) {
    return '$count leçons terminées';
  }

  @override
  String get exploreSectionTitle => 'Explorer';

  @override
  String get nnangaPromoSubtitle =>
      'Pratiquez l\'ewondo avec votre tuteur IA personnel';

  @override
  String get startPracticeButton => 'COMMENCER';

  @override
  String get phraseOfDayTitle => 'Phrase du jour';

  @override
  String get learnHubTitle => 'Apprendre l\'ewondo';

  @override
  String get learnHubSubtitle =>
      'Choisissez un niveau et continuez votre parcours.';

  @override
  String get dailyGoalTitle => 'Objectif du jour';

  @override
  String get dailyGoalSubtitle => 'Terminez 1 leçon aujourd\'hui';

  @override
  String get todaysLessonLabel => 'LEÇON DU JOUR';

  @override
  String get listenAndRepeatTitle => 'Écoutez et répétez';

  @override
  String get tapSpeakerRepeatCaption =>
      'Appuyez sur le haut-parleur, puis répétez la phrase.';

  @override
  String get inConversationTitle => 'En conversation';

  @override
  String get quickCheckTitle => 'Vérification rapide';

  @override
  String get voiceMessageSendError =>
      'Impossible d\'envoyer ce message vocal — veuillez réessayer.';

  @override
  String get practiceModeLabel => 'Mode pratique';

  @override
  String get freeConversationLabel => 'Conversation libre';

  @override
  String explainPromptPrefix(String text) {
    return 'Expliquer : $text';
  }

  @override
  String translatePromptPrefix(String text) {
    return 'Traduire : $text';
  }

  @override
  String get explainActionLabel => 'Expliquer';

  @override
  String get translateActionLabel => 'Traduire';

  @override
  String get correctionLabel => 'Correction';

  @override
  String get translationLabel => 'Traduction';

  @override
  String get practiceTitle => 'Pratique';

  @override
  String get practiceSubtitle => 'Renforcez vos compétences en ewondo';

  @override
  String get practiceLoadError =>
      'Un problème est survenu lors du chargement de la pratique.';

  @override
  String get dailyPracticeTitle => 'Pratique quotidienne';

  @override
  String get dailyGoalReachedMessage => 'Objectif du jour atteint !';

  @override
  String minutesToGoalMessage(int minutes) {
    return '$minutes minutes pour atteindre l\'objectif du jour';
  }

  @override
  String get minutesUnitLabel => 'min';

  @override
  String get continuePracticeButton => 'CONTINUER LA PRATIQUE';

  @override
  String get smartReviewTitle => 'Révision intelligente';

  @override
  String wordsReadyForReview(int count) {
    return '$count mots sont prêts à être révisés';
  }

  @override
  String get noWordsDueMessage => 'Aucun mot à réviser pour le moment';

  @override
  String get reviewNowButton => 'RÉVISER';

  @override
  String get thisWeekTitle => 'Cette semaine';

  @override
  String practiceDaysCount(int count) {
    return '$count jours de pratique';
  }

  @override
  String get almostThereTitle => 'Presque là !';

  @override
  String completeSessionsForBadge(int count, String badgeName) {
    return 'Terminez $count séances supplémentaires pour obtenir le badge $badgeName.';
  }

  @override
  String get badgesTitle => 'Badges';

  @override
  String get noBadgesYetMessage => 'Aucun badge pour l\'instant.';

  @override
  String completeMoreForBadge(int remaining) {
    return 'Encore $remaining pour obtenir ce badge';
  }

  @override
  String get tapToRevealHint => 'Appuyez pour révéler';

  @override
  String get gradeAgainLabel => 'À revoir';

  @override
  String get gradeHardLabel => 'Difficile';

  @override
  String get gradeGoodLabel => 'Bien';

  @override
  String get gradeEasyLabel => 'Facile';

  @override
  String get smartReviewCompleteTitle => 'Révision terminée !';

  @override
  String smartReviewCompleteSummary(int count) {
    return 'Vous avez révisé $count mots aujourd\'hui.';
  }

  @override
  String get backToPracticeButton => 'Retour à la pratique';

  @override
  String get bestStreakLabel => 'Meilleure série';

  @override
  String get yourPronunciationTitle => 'Votre prononciation';

  @override
  String get micPermissionRequiredError =>
      'La permission du microphone est requise pour pratiquer la prononciation.';

  @override
  String get recordingSubmitError =>
      'Impossible d\'envoyer votre enregistrement — veuillez réessayer.';

  @override
  String get recordingStatusLabel => 'Enregistrement…';

  @override
  String get scoringStatusLabel => 'Évaluation…';

  @override
  String get scoredStatusLabel => 'Évalué';

  @override
  String get notScoredStatusLabel => 'Non évalué';

  @override
  String get readyToRecordStatusLabel => 'Prêt à enregistrer';

  @override
  String get stopRecordingButton => 'ARRÊTER L\'ENREGISTREMENT';

  @override
  String get startRecordingButton => 'ENREGISTRER';

  @override
  String get scoringFailedFallback => 'Impossible d\'évaluer cet essai.';
}
