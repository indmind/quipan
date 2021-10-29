// linear mapping biasa
int calculateScore(int maxPoint, int quizDurationMs, int answerDuration,
    [int minPoint = 100]) {
  // to prevent minus score
  if (answerDuration > quizDurationMs) {
    return 0;
  }

  final timeRemaining = quizDurationMs - answerDuration;
  
  return map(timeRemaining, 0, quizDurationMs, minPoint, maxPoint).round();
}

double map(int n, int start1, int stop1, int start2, int stop2) {
  return ((n - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
}
