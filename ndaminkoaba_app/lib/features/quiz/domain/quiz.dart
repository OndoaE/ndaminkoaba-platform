class QuizChoice {
  final String id;
  final String choiceText;
  final String? frenchChoiceText;

  const QuizChoice({
    required this.id,
    required this.choiceText,
    this.frenchChoiceText,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: json['id'] ?? '',
      choiceText: json['choiceText'] ?? '',
      frenchChoiceText: json['frenchChoiceText'],
    );
  }
}

class QuizQuestion {
  final String id;
  final String questionText;
  final String? explanation;
  final String? frenchQuestionText;
  final String? frenchExplanation;
  final List<QuizChoice> choices;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    this.explanation,
    this.frenchQuestionText,
    this.frenchExplanation,
    required this.choices,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      explanation: json['explanation'],
      frenchQuestionText: json['frenchQuestionText'],
      frenchExplanation: json['frenchExplanation'],
      choices: ((json['choices'] ?? []) as List)
          .map((item) => QuizChoice.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String? description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int passingScore;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.id,
    required this.title,
    this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.passingScore,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      passingScore: json['passingScore'] ?? 80,
      questions: ((json['questions'] ?? []) as List)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionResult {
  final String questionId;
  final String? choiceId;
  final bool isCorrect;

  const QuestionResult({
    required this.questionId,
    this.choiceId,
    required this.isCorrect,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] ?? '',
      choiceId: json['choiceId'],
      isCorrect: json['isCorrect'] == true,
    );
  }
}

class QuizAttemptResult {
  final int score;
  final bool passed;
  final List<QuestionResult> results;

  const QuizAttemptResult({
    required this.score,
    required this.passed,
    required this.results,
  });

  factory QuizAttemptResult.fromJson(Map<String, dynamic> json) {
    return QuizAttemptResult(
      score: json['score'] ?? 0,
      passed: json['passed'] == true,
      results: ((json['results'] ?? []) as List)
          .map((item) => QuestionResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
