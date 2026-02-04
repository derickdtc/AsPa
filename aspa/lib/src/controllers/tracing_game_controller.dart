import 'package:flutter/material.dart';
import '../models/tracing_game_model.dart';

class TracingController extends ChangeNotifier {
  // estados
  LevelModel _currentLevel = LevelModel.empty();
  final SessionModel _session = SessionModel();
  int _currentLevelIndex = 0;

  // getters
  bool get isLastLevel =>
      _currentLevelIndex == 3; // 0, 1, 2, 3 (Total de 4 fases)
  List<Offset> get userPath => _session.userTrace;
  GameStatus get status => _session.status;
  LevelModel get level => _currentLevel;
  GameDifficulty get difficulty => _session.difficulty;
  bool get isGameFinished => _session.status != GameStatus.playing;

  void setDifficulty(GameDifficulty newDifficulty) {
    _session.difficulty = newDifficulty;
  }

  double _getWidthForDifficulty(GameDifficulty diff) {
    switch (diff) {
      case GameDifficulty.easy:
        return 90.0;
      case GameDifficulty.medium:
        return 60.0;
      case GameDifficulty.hard:
        return 40.0;
    }
  }

  void initLevel(Size size) {
    if (size.isEmpty) return;
    _loadLevel(size, _currentLevelIndex);
  }

  void nextLevel(Size size) {
    _currentLevelIndex = (_currentLevelIndex + 1) % 4;
    _loadLevel(size, _currentLevelIndex);
  }

  void restartGame() {
    _session.reset();
    notifyListeners();
  }

  void _loadLevel(Size size, int index) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    Offset start = Offset.zero;
    Offset end = Offset.zero;
    String name = "";

    // garantindo q o desenho caiba na tela
    switch (index) {
      case 0:
        name = "Linha";
        start = Offset(w * 0.5, h * 0.15);
        end = Offset(w * 0.5, h * 0.85);
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        break;
      case 1:
        name = "Curva";
        start = Offset(w * 0.2, h * 0.2);
        end = Offset(w * 0.2, h * 0.8);
        path.moveTo(start.dx, start.dy);
        path.quadraticBezierTo(w * 0.9, h * 0.5, end.dx, end.dy);
        break;
      case 2:
        name = "Serpente";
        start = Offset(w * 0.15, h * 0.2);
        end = Offset(w * 0.85, h * 0.9);
        path.moveTo(start.dx, start.dy);
        path.quadraticBezierTo(w * 0.8, h * 0.2, w * 0.8, h * 0.5);
        path.quadraticBezierTo(w * 0.2, h * 0.8, end.dx, end.dy);
        break;
      case 3:
        name = "M";
        start = Offset(w * 0.1, h * 0.5);
        end = Offset(w * 0.9, h * 0.5);
        path.moveTo(start.dx, start.dy);
        path.lineTo(w * 0.3, h * 0.2);
        path.lineTo(w * 0.5, h * 0.8);
        path.lineTo(w * 0.7, h * 0.2);
        path.lineTo(end.dx, end.dy);
        break;
    }

    _currentLevel = LevelModel(
      id: index + 1,
      name: name,
      pathShape: path,
      pathWidth: _getWidthForDifficulty(_session.difficulty),
      startPoint: start,
      endPoint: end,
    );

    _session.reset();
    notifyListeners();
  }

  void onPointerDown(Offset position) {
    if (isGameFinished) return;

    if ((position - _currentLevel.startPoint).distance > 50.0) {
      return;
    }

    _session.reset();
    _validateMovement(position);
  }

  void onPointerMove(Offset position) {
    if (_session.userTrace.isEmpty) return;

    if (isGameFinished) return;
    _validateMovement(position);
  }

  void _validateMovement(Offset userFingerPosition) {
    bool isSafe = _isPointNearPath(userFingerPosition, _currentLevel.pathShape,
        _currentLevel.pathWidth / 2);

    if (isSafe) {
      _session.userTrace.add(userFingerPosition);
      if ((userFingerPosition - _currentLevel.endPoint).distance < 40) {
        _session.status = GameStatus.won;
      }
      notifyListeners();
    } else {
      _session.status = GameStatus.lost;
      notifyListeners();
    }
  }

  bool _isPointNearPath(Offset point, Path path, double threshold) {
    final metrics = path.computeMetrics();
    double minDistance = double.infinity;

    for (final metric in metrics) {
      const double step = 5.0;
      for (double d = 0; d < metric.length; d += step) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        final dist = (point - tangent.position).distance;
        if (dist < minDistance) minDistance = dist;
      }
    }
    return minDistance <= threshold;
  }
}
