import 'dart:ui';

enum GameDifficulty { easy, medium, hard }

enum GameStatus { playing, won, lost }

class LevelModel {
  final int id;
  final String name;
  final Path pathShape;
  final double pathWidth;
  final Offset startPoint;
  final Offset endPoint;

  LevelModel({
    required this.id,
    required this.name,
    required this.pathShape,
    required this.pathWidth,
    required this.startPoint,
    required this.endPoint,
  });

  // Cria um nível vazio para inicialização
  factory LevelModel.empty() {
    return LevelModel(
      id: 0,
      name: "",
      pathShape: Path(),
      pathWidth: 0,
      startPoint: Offset.zero,
      endPoint: Offset.zero,
    );
  }
}

class SessionModel {
  List<Offset> userTrace;
  GameStatus status;
  GameDifficulty difficulty;

  SessionModel({
    List<Offset>? userTrace,
    this.status = GameStatus.playing,
    this.difficulty = GameDifficulty.easy,
  }) : userTrace = userTrace ?? [];

  void reset() {
    userTrace.clear();
    status = GameStatus.playing;
  }
}
