import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { LanguagesModule } from './languages/languages.module';
import { UploadsModule } from './uploads/uploads.module';
import { CoursesModule } from './courses/courses.module';
import { CourseModulesModule } from './course-modules/course-modules.module';
import { LessonsModule } from './lessons/lessons.module';
import { LessonImagesModule } from './lesson-images/lesson-images.module';
import { VocabularyModule } from './vocabulary/vocabulary.module';
import { CategoriesModule } from './categories/categories.module';
import { PronunciationsModule } from './pronunciations/pronunciations.module';
import { QuizzesModule } from './quizzes/quizzes.module';
import { QuestionsModule } from './questions/questions.module';
import { ChoicesModule } from './choices/choices.module';
import { ProgressModule } from './progress/progress.module';
import { QuizAttemptsModule } from './quiz-attempts/quiz-attempts.module';
import { CertificatesModule } from './certificates/certificates.module';
import { BookmarksModule } from './bookmarks/bookmarks.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { NnangaModule } from './nnanga/nnanga.module';
import { NotificationsModule } from './notifications/notifications.module';
import { EnrollmentsModule } from './enrollments/enrollments.module';
import { KnowledgeModule } from './knowledge/knowledge.module';
import { KnowledgeTextsModule } from './knowledge-texts/knowledge-texts.module';
import { BibleVersesModule } from './bible-verses/bible-verses.module';
import { DailyModule } from './daily/daily.module';
import { AiModule } from './ai/ai.module';
import { AuditLogModule } from './audit-log/audit-log.module';
import { BooksModule } from './books/books.module';

@Module({
  imports: [
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),

    PrismaModule,
    UsersModule,
    AuthModule,
    LanguagesModule,
    UploadsModule,
    CoursesModule,
    CourseModulesModule,
    LessonsModule,
    LessonImagesModule,
    VocabularyModule,
    CategoriesModule,
    PronunciationsModule,
    QuizzesModule,
    QuestionsModule,
    ChoicesModule,
    ProgressModule,
    QuizAttemptsModule,
    CertificatesModule,
    BookmarksModule,
    DashboardModule,
    NnangaModule,
    NotificationsModule,
    EnrollmentsModule,
    KnowledgeModule,
    KnowledgeTextsModule,
    BibleVersesModule,
    DailyModule,
    AiModule,
    AuditLogModule,
    BooksModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}