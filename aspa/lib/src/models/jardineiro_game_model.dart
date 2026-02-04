enum GameDifficulty { easy, medium, hard }

class GameStats {
  int totalTaps = 0;
  int successfulTaps = 0;
  final List<double> reactionTimes = [];
  DateTime? gameStartTime;

  double get accuracy {
    if (totalTaps == 0) return 1.0;
    return successfulTaps / totalTaps;
  }

  double get averageReactionTime {
    if (reactionTimes.isEmpty) return 0.0;
    final sum = reactionTimes.reduce((a, b) => a + b);
    return sum / reactionTimes.length;
  }

  void reset() {
    totalTaps = 0;
    successfulTaps = 0;
    reactionTimes.clear();
    gameStartTime = null;
  }
}

class GameConfig {
  final int targetGoal = 10;
  GameDifficulty difficulty = GameDifficulty.easy;

  double getFlowerSize() {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 80.0;
      case GameDifficulty.medium:
        return 60.0;
      case GameDifficulty.hard:
        return 40.0;
    }
  }

  int getMoveTimeLimit() {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 3000;
      case GameDifficulty.medium:
        return 2000;
      case GameDifficulty.hard:
        return 1500;
    }
  }
}
