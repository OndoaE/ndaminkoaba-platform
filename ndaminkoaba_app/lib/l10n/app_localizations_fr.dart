// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get switchLanguageTitle => 'Changer de langue';

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
