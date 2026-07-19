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
  String get commonContinueWithFacebook => 'Continuer avec Facebook';

  @override
  String get commonOrContinueWith => 'ou continuer avec';

  @override
  String commonOAuthNotConfigured(String provider) {
    return 'La connexion $provider n\'est pas encore configurée.';
  }

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
  String get navAI => 'IA';

  @override
  String get navProfile => 'Profil';

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
  String get modulesTitle => 'Modules';

  @override
  String get modulesSubtitle => 'Apprenez étape par étape';

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
  String get booksTitle => 'Livres';

  @override
  String get booksSubtitle =>
      'Lisez des livres en Ewondo au format PDF ou EPUB, directement dans l\'application.';

  @override
  String get noBooksTitle => 'Aucun livre pour le moment';

  @override
  String get noBooksMessage =>
      'Revenez bientôt — de nouveaux livres apparaîtront ici.';

  @override
  String get bookLoadError =>
      'Impossible de charger ce livre. Veuillez réessayer.';

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
}
