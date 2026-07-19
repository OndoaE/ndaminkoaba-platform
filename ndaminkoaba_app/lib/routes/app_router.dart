import 'package:go_router/go_router.dart';

import '../core/navigation/navigator_key.dart';
import '../features/admin/presentation/admin_bible_chapter_screen.dart';
import '../features/admin/presentation/admin_book_management_screen.dart';
import '../features/admin/presentation/admin_certificates_screen.dart';
import '../features/admin/presentation/admin_content_hub_screen.dart';
import '../features/admin/presentation/admin_daily_management_screen.dart';
import '../features/admin/presentation/admin_course_editor_screen.dart';
import '../features/admin/presentation/admin_course_management_screen.dart';
import '../features/admin/presentation/admin_create_user_screen.dart';
import '../features/admin/presentation/admin_global_dashboard_screen.dart';
import '../features/admin/presentation/admin_history_screen.dart';
import '../features/admin/presentation/admin_knowledge_screen.dart';
import '../features/admin/presentation/admin_language_dashboard_screen.dart';
import '../features/admin/presentation/admin_language_management_screen.dart';
import '../features/admin/presentation/admin_lesson_images_screen.dart';
import '../features/admin/presentation/admin_lesson_management_screen.dart';
import '../features/admin/presentation/admin_module_management_screen.dart';
import '../features/admin/presentation/admin_new_lesson_screen.dart';
import '../features/admin/presentation/admin_new_quiz_screen.dart';
import '../features/admin/presentation/admin_quiz_builder_screen.dart';
import '../features/admin/presentation/admin_quiz_management_screen.dart';
import '../features/admin/presentation/admin_users_screen.dart';
import '../features/admin/presentation/admin_vocabulary_management_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/language/presentation/language_selection_screen.dart';
import '../features/languages/presentation/continue_learning_screen.dart';
import '../features/languages/presentation/learning_language_selection_screen.dart';
import '../features/bible/presentation/bible_books_screen.dart';
import '../features/bible/presentation/bible_chapters_screen.dart';
import '../features/bible/presentation/bible_reader_screen.dart';
import '../features/books/presentation/book_reader_screen.dart';
import '../features/books/presentation/books_screen.dart';
import '../features/certificates/presentation/certificate_detail_screen.dart';
import '../features/certificates/presentation/certificates_screen.dart';
import '../features/courses/presentation/courses_screen.dart';
import '../features/courses/presentation/course_detail_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/learning/presentation/my_learning_screen.dart';
import '../features/lessons/presentation/lesson_screen.dart';
import '../features/nnanga/presentation/nnanga_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/vocabulary/presentation/vocabulary_screen.dart';

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language-select',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/select-learning-language',
      builder: (context, state) => const LearningLanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/continue-learning',
      builder: (context, state) {
        final languageId = state.extra as String;
        return ContinueLearningScreen(languageId: languageId);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) {
        final fullName = state.extra as String? ?? 'there';
        return WelcomeScreen(fullName: fullName);
      },
    ),

    // Learner
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesScreen(),
    ),
    GoRoute(
      path: '/courses/:id',
      builder: (context, state) {
        final courseId = state.pathParameters['id']!;
        return CourseDetailScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/courses/:courseId/lessons/:lessonId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        final lessonId = state.pathParameters['lessonId']!;

        return LessonScreen(courseId: courseId, lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/courses/:courseId/lessons/:lessonId/quiz',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        final lessonId = state.pathParameters['lessonId']!;

        return QuizScreen(courseId: courseId, lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/my-learning',
      builder: (context, state) => const MyLearningScreen(),
    ),
    GoRoute(
      path: '/vocabulary',
      builder: (context, state) => const VocabularyScreen(),
    ),
    GoRoute(path: '/nnanga', builder: (context, state) => const NnangaScreen()),
    GoRoute(
      path: '/certificates',
      builder: (context, state) => const CertificatesScreen(),
    ),
    GoRoute(
      path: '/certificates/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CertificateDetailScreen(certificateId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/bible',
      builder: (context, state) => const BibleBooksScreen(),
    ),
    GoRoute(
      path: '/bible/:book',
      builder: (context, state) {
        final book = Uri.decodeComponent(state.pathParameters['book']!);
        final displayName = state.extra as String?;
        return BibleChaptersScreen(book: book, displayName: displayName);
      },
    ),
    GoRoute(
      path: '/bible/:book/:chapter',
      builder: (context, state) {
        final book = Uri.decodeComponent(state.pathParameters['book']!);
        final chapter = int.parse(state.pathParameters['chapter']!);
        final displayName = state.extra as String?;
        return BibleReaderScreen(book: book, chapter: chapter, displayName: displayName);
      },
    ),
    GoRoute(
      path: '/books',
      builder: (context, state) => const BooksScreen(),
    ),
    GoRoute(
      path: '/books/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BookReaderScreen(bookId: id);
      },
    ),

    // Administrator — global (language-agnostic)
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminGlobalDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: '/admin/users/new',
      builder: (context, state) => const AdminCreateUserScreen(),
    ),
    GoRoute(
      path: '/admin/certificates',
      builder: (context, state) => const AdminCertificatesScreen(),
    ),
    GoRoute(
      path: '/admin/history',
      builder: (context, state) => const AdminHistoryScreen(),
    ),
    GoRoute(
      path: '/admin/languages',
      builder: (context, state) => const AdminLanguageManagementScreen(),
    ),
    GoRoute(
      path: '/admin/lessons/:lessonId/images',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        final lessonTitle = state.extra as String?;
        return AdminLessonImagesScreen(
          lessonId: lessonId,
          lessonTitle: lessonTitle,
        );
      },
    ),
    GoRoute(
      path: '/admin/lessons/:lessonId/quiz',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        final lessonTitle = state.extra as String?;
        return AdminQuizBuilderScreen(
          lessonId: lessonId,
          lessonTitle: lessonTitle,
        );
      },
    ),

    // Administrator — scoped to a single language
    GoRoute(
      path: '/admin/languages/:languageId',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminLanguageDashboardScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/courses',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminContentHubScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/courses/new',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminCourseEditorScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/courses/:id',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final id = state.pathParameters['id']!;
        final languageName = state.extra as String?;
        return AdminCourseEditorScreen(courseId: id, languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/lessons/new',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminNewLessonScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/quizzes/new',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminNewQuizScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/knowledge',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminKnowledgeScreen(languageId: languageId, languageName: languageName);
      },
    ),

    // Content management (flat lists with full CRUD), scoped to a language
    GoRoute(
      path: '/admin/languages/:languageId/management/courses',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminCourseManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/modules',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminModuleManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/lessons',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminLessonManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/vocabulary',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminVocabularyManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/bible',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminBibleChapterScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/quizzes',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminQuizManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/daily',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminDailyManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
    GoRoute(
      path: '/admin/languages/:languageId/management/books',
      builder: (context, state) {
        final languageId = state.pathParameters['languageId']!;
        final languageName = state.extra as String?;
        return AdminBookManagementScreen(languageId: languageId, languageName: languageName);
      },
    ),
  ],
);
