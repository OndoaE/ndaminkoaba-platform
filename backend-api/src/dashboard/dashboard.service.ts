import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getAdminDashboard(languageId?: string) {
    const courseWhere = languageId ? { languageId } : {};
    const moduleWhere = languageId ? { course: { languageId } } : {};
    const lessonWhere = languageId ? { module: { course: { languageId } } } : {};
    const vocabularyWhere = languageId ? { languageId } : {};
    const quizWhere = languageId
      ? { lesson: { module: { course: { languageId } } } }
      : {};
    const questionWhere = languageId
      ? { quiz: { lesson: { module: { course: { languageId } } } } }
      : {};
    const certificateWhere = languageId ? { course: { languageId } } : {};

    const [
      totalUsers,
      totalLanguages,
      totalCourses,
      totalModules,
      totalLessons,
      totalVocabulary,
      totalQuizzes,
      totalQuestions,
      totalCertificates,
      totalBookmarks,
      totalProgress,
      totalQuizAttempts,
      usersByRole,
      coursesByLevel,
      recentCertificates,
    ] = await Promise.all([
      // Users is a platform-wide count regardless of language scope — an
      // account isn't owned by any one language.
      this.prisma.user.count(),
      this.prisma.language.count(),
      this.prisma.course.count({ where: courseWhere }),
      this.prisma.courseModule.count({ where: moduleWhere }),
      this.prisma.lesson.count({ where: lessonWhere }),
      this.prisma.vocabulary.count({ where: vocabularyWhere }),
      this.prisma.quiz.count({ where: quizWhere }),
      this.prisma.question.count({ where: questionWhere }),
      this.prisma.certificate.count({ where: certificateWhere }),
      this.prisma.bookmark.count(),
      this.prisma.progress.count(),
      this.prisma.quizAttempt.count(),
      this.prisma.user.groupBy({ by: ['role'], _count: true }),
      this.prisma.course.groupBy({ by: ['level'], _count: true, where: courseWhere }),
      this.prisma.certificate.findMany({
        where: certificateWhere,
        take: 5,
        orderBy: { issuedAt: 'desc' },
        include: {
          user: { select: { fullName: true } },
          course: { select: { title: true } },
        },
      }),
    ]);

    return {
      users: totalUsers,
      languages: totalLanguages,
      courses: totalCourses,
      modules: totalModules,
      lessons: totalLessons,
      vocabulary: totalVocabulary,
      quizzes: totalQuizzes,
      questions: totalQuestions,
      certificates: totalCertificates,
      bookmarks: totalBookmarks,
      lessonProgress: totalProgress,
      quizAttempts: totalQuizAttempts,
      usersByRole: Object.fromEntries(
        usersByRole.map((row) => [row.role, row._count]),
      ),
      coursesByLevel: Object.fromEntries(
        coursesByLevel.map((row) => [row.level, row._count]),
      ),
      recentCertificates: recentCertificates.map((cert) => ({
        learnerName: cert.user.fullName,
        courseTitle: cert.course.title,
        issuedAt: cert.issuedAt,
      })),
    };
  }

  async getLearnerDashboard(userId: string) {
    const [
      bookmarks,
      progress,
      certificates,
      quizAttempts,
    ] = await Promise.all([
      this.prisma.bookmark.count({
        where: { userId },
      }),
      this.prisma.progress.count({
        where: {
          userId,
          completed: true,
        },
      }),
      this.prisma.certificate.count({
        where: { userId },
      }),
      this.prisma.quizAttempt.findMany({
        where: { userId },
      }),
    ]);

    const averageScore =
      quizAttempts.length === 0
        ? 0
        : Math.round(
            quizAttempts.reduce((a, b) => a + b.score, 0) /
              quizAttempts.length,
          );

    return {
      completedLessons: progress,
      bookmarks,
      certificates,
      totalQuizAttempts: quizAttempts.length,
      averageQuizScore: averageScore,
    };
  }

  async getTeacherDashboard() {
    const [
      totalCourses,
      totalLessons,
      totalVocabulary,
      totalQuizzes,
    ] = await Promise.all([
      this.prisma.course.count(),
      this.prisma.lesson.count(),
      this.prisma.vocabulary.count(),
      this.prisma.quiz.count(),
    ]);

    return {
      courses: totalCourses,
      lessons: totalLessons,
      vocabulary: totalVocabulary,
      quizzes: totalQuizzes,
    };
  }
}