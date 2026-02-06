// controller/game_controller.dart
import 'package:flutter/material.dart';
import '../models/classification_game_model.dart';

class GameController {
  final GameModel model = GameModel();

  void resetGame() {
    model.resetGame();
  }

  void changeDifficulty(DifficultyLevel newDifficulty) {
    model.changeDifficulty(newDifficulty);
  }

  void onItemDropped(GameItem item, String basketType) {
    model.onItemDropped(item, basketType);
  }

  // Métodos para obter dados da view
  int get score => model.score;
  List<GameItem> get items => model.items;
  DifficultyLevel get currentDifficulty => model.currentDifficulty;
  int get totalItems => model.totalItems;
  double get progress => model.progress;

  List<Map<String, dynamic>> getBasketConfigs() {
    final List<Map<String, dynamic>> basketConfigs = [
      {
        'color': Colors.red,
        'type': 'red',
        'label': 'Vermelho',
        'icon': Icons.apple
      },
      {
        'color': Colors.yellow[700]!,
        'type': 'yellow',
        'label': 'Amarelo',
        'icon': Icons.emoji_food_beverage
      },
    ];

    if (model.currentDifficulty == DifficultyLevel.hard) {
      basketConfigs.add({
        'color': Colors.green,
        'type': 'green',
        'label': 'Verde',
        'icon': Icons.emoji_nature
      });
    }

    return basketConfigs;
  }
}
