// linear mapping biasa
int calculateScore(int maxPoint, int quizDurationMs, int answerDuration) {
  // to prevent minus score
  if (answerDuration > quizDurationMs) {
    return 0;
  }

  final timeRemaining = quizDurationMs - answerDuration;

  return (maxPoint * timeRemaining / quizDurationMs).round();
}
