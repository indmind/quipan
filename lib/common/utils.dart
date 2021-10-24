// linear mapping biasa
int calculateScore(int maxPoint, int quizDurationMs, int answerDuration) {
  return maxPoint * answerDuration ~/ quizDurationMs;
}
