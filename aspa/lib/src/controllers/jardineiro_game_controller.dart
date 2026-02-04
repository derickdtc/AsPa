import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/jardineiro_game_model.dart';

class JardineiroGameController {
  final GameConfig config = GameConfig();
  final GameStats stats = GameStats();

  // Game state
  int currentScore = 0;
  bool isGameActive = false;
  double flowerTop = 0;
  double flowerLeft = 0;

  // Utilities
  final Random random = Random();
  final Stopwatch reactionTimer = Stopwatch();
  Timer? autoMoveTimer;

  // Audio
  late AudioPlayer audioPlayer;
  bool audioInitialized = false;

  // Callbacks
  VoidCallback? onGameStateChanged;
  Function(int)? onScoreChanged;
  Function(double, double)? onFlowerMoved;
  Function? onGameFinished;

  Future<void> initAudio() async {
    audioPlayer = AudioPlayer();
    try {
      await audioPlayer.setSource(AssetSource('audios/tap.mp3'));
      audioInitialized = true;
    } catch (e) {
      // Handle error silently
    }
  }

  void startGame() {
    stats.reset();
    stats.gameStartTime = DateTime.now();
    currentScore = 0;
    isGameActive = true;

    if (config.difficulty != GameDifficulty.easy) {
      _startAutoMoveTimer();
    }

    reactionTimer.reset();

    _notifyGameStateChanged();
    _notifyScoreChanged();
  }

  void _startAutoMoveTimer() {
    autoMoveTimer?.cancel();
    autoMoveTimer = Timer.periodic(
      Duration(milliseconds: config.getMoveTimeLimit()),
      (timer) {
        if (isGameActive) {
          _moveFlower(missed: true);
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _moveFlower({bool missed = false}) {
    // Position calculation will be handled by the view
    // This just triggers the callback
    if (onFlowerMoved != null) {
      onFlowerMoved!(flowerLeft, flowerTop);
    }

    if (missed) {
      stats.totalTaps++;
    }
  }

  void handleFlowerTap() {
    _playSound('tap.mp3');
    HapticFeedback.lightImpact();

    stats.totalTaps++;
    stats.successfulTaps++;
    currentScore++;

    if (reactionTimer.isRunning) {
      stats.reactionTimes.add(reactionTimer.elapsedMilliseconds.toDouble());
      reactionTimer.reset();
    }

    _notifyScoreChanged();

    if (currentScore >= config.targetGoal) {
      finishGame();
    } else {
      _moveFlower();
      if (config.difficulty != GameDifficulty.easy) {
        autoMoveTimer?.cancel();
        _startAutoMoveTimer();
      }
    }
  }

  void handleBackgroundTap(double tapX, double tapY, double flowerCenterX,
      double flowerCenterY, double flowerRadius) {
    if (!isGameActive) return;

    final dx = tapX - flowerCenterX;
    final dy = tapY - flowerCenterY;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > flowerRadius) {
      stats.totalTaps++;
      HapticFeedback.mediumImpact();
      try {
        _playSound('miss.wav');
      } catch (_) {}
    }
  }

  Future<void> _playSound(String soundFileName) async {
    if (!audioInitialized) {
      await initAudio();
      if (!audioInitialized) return;
    }

    try {
      await audioPlayer.play(AssetSource('audios/$soundFileName'));
    } catch (e) {
      // Silently handle error
    }
  }

  void finishGame() {
    autoMoveTimer?.cancel();
    reactionTimer.stop();
    isGameActive = false;
    _playSound('win.mp3');
    _notifyGameStateChanged();

    if (onGameFinished != null) {
      onGameFinished!();
    }
  }

  void changeDifficulty(GameDifficulty difficulty) {
    if (isGameActive) return;
    config.difficulty = difficulty;
    _notifyGameStateChanged();
  }

  void _notifyGameStateChanged() {
    if (onGameStateChanged != null) {
      onGameStateChanged!();
    }
  }

  void _notifyScoreChanged() {
    if (onScoreChanged != null) {
      onScoreChanged!(currentScore);
    }
  }

  void dispose() {
    autoMoveTimer?.cancel();
    audioPlayer.dispose();
  }
}
