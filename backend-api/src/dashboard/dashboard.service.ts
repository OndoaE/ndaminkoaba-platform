import { Injectable } from '@nestjs/common';
import { LessonStatus, UserRole } from '@prisma/client';
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
      coursesByStatus,
      vocabularyWithAudioCount,
      completedLessonsCount,
      avgEnrollmentProgress,
      recentCertificates,
      learnerActivity,
      aiReviewCount,
      enrollmentsForLevelBreakdown,
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
      this.prisma.course.groupBy({ by: ['status'], _count: true, where: courseWhere }),
      this.prisma.vocabulary.count({
        where: { ...vocabularyWhere, audioUrl: { not: null } },
      }),
      this.prisma.progress.count({
        where: { lesson: lessonWhere, completed: true },
      }),
      this.prisma.enrollment.aggregate({
        _avg: { progress: true },
        where: languageId ? { course: { languageId } } : {},
      }),
      this.prisma.certificate.findMany({
        where: certificateWhere,
        take: 5,
        orderBy: { issuedAt: 'desc' },
        include: {
          user: { select: { fullName: true } },
          course: { select: { title: true } },
        },
      }),
      this.getLearnerActivitySeries(),
      this.prisma.lesson.count({
        where: { ...lessonWhere, generatedByAi: true, status: LessonStatus.IN_REVIEW },
      }),
      // Prisma's groupBy can't group by a joined field (course.level), so
      // this fetches the raw rows and reduces per-level averages in JS —
      // fine at this scale (admin dashboard, not a hot path).
      this.prisma.enrollment.findMany({
        where: languageId ? { course: { languageId } } : {},
        select: { progress: true, course: { select: { level: true } } },
      }),
    ]);

    const levelTotals = new Map<string, { sum: number; count: number }>();
    for (const enrollment of enrollmentsForLevelBreakdown) {
      const level = enrollment.course.level;
      const entry = levelTotals.get(level) ?? { sum: 0, count: 0 };
      entry.sum += enrollment.progress;
      entry.count += 1;
      levelTotals.set(level, entry);
    }
    const courseCompletionByLevel = Object.fromEntries(
      Array.from(levelTotals.entries()).map(([level, { sum, count }]) => [
        level,
        Math.round(sum / count),
      ]),
    );

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
      lessonsCompleted: completedLessonsCount,
      avgCourseCompletion: Math.round(avgEnrollmentProgress._avg.progress ?? 0),
      vocabularyWithAudioPercent:
        totalVocabulary > 0
          ? Math.round((vocabularyWithAudioCount / totalVocabulary) * 100)
          : 0,
      usersByRole: Object.fromEntries(
        usersByRole.map((row) => [row.role, row._count]),
      ),
      coursesByLevel: Object.fromEntries(
        coursesByLevel.map((row) => [row.level, row._count]),
      ),
      coursesByStatus: Object.fromEntries(
        coursesByStatus.map((row) => [row.status, row._count]),
      ),
      recentCertificates: recentCertificates.map((cert) => ({
        learnerName: cert.user.fullName,
        courseTitle: cert.course.title,
        issuedAt: cert.issuedAt,
      })),
      // Platform-wide regardless of languageId, same rationale as the users
      // count above — a learner's daily activity isn't owned by one language.
      learnerActivity,
      aiReviewCount,
      courseCompletionByLevel,
    };
  }

  // Last 7 days of {date, newLearners, activeLearners} for the admin
  // dashboards' "Learner Activity" chart. Small, sequential per-day queries
  // rather than a single grouped query — this endpoint isn't a hot path, and
  // the straightforward version is easier to read/verify than a raw SQL
  // date-bucketing query.
  private async getLearnerActivitySeries() {
    const days = 7;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const series: {
      date: string;
      newLearners: number;
      activeLearners: number;
    }[] = [];

    for (let i = days - 1; i >= 0; i--) {
      const dayStart = new Date(today);
      dayStart.setDate(dayStart.getDate() - i);
      const dayEnd = new Date(dayStart);
      dayEnd.setDate(dayEnd.getDate() + 1);

      const [newLearners, activeSessions] = await Promise.all([
        this.prisma.user.count({
          where: {
            role: UserRole.LEARNER,
            createdAt: { gte: dayStart, lt: dayEnd },
          },
        }),
        this.prisma.practiceSession.findMany({
          where: { createdAt: { gte: dayStart, lt: dayEnd } },
          select: { userId: true },
          distinct: ['userId'],
        }),
      ]);

      series.push({
        date: dayStart.toISOString().slice(0, 10),
        newLearners,
        activeLearners: activeSessions.length,
      });
    }

    return series;
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