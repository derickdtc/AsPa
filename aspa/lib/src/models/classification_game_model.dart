import 'package:flutter/material.dart';

enum DifficultyLevel { easy, medium, hard }

class GameItem {
  final String name;
  final String emoji;
  final Color color;
  final String type;

  GameItem({
    required this.name,
    required this.emoji,
    required this.color,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class GameModel {
  int score = 0;
  List<GameItem> items = [];
  DifficultyLevel currentDifficulty = DifficultyLevel.easy;
  int totalItems = 0;

  List<GameItem> generateItemsForDifficulty(DifficultyLevel difficulty) {
    final List<GameItem> allItems = [
      // vermelho
      GameItem(name: 'Maçã', emoji: '🍎', color: Colors.red, type: 'red'),
      GameItem(name: 'Morango', emoji: '🍓', color: Colors.red, type: 'red'),
      GameItem(name: 'Cereja', emoji: '🍒', color: Colors.red, type: 'red'),
      GameItem(name: 'Melancia', emoji: '🍉', color: Colors.red, type: 'red'),
      GameItem(name: 'Pimenta', emoji: '🌶️', color: Colors.red, type: 'red'),
      GameItem(name: 'Tomate', emoji: '🍅', color: Colors.red, type: 'red'),
      GameItem(name: 'Carne', emoji: '🥩', color: Colors.red, type: 'red'),
      GameItem(name: 'Camarão', emoji: '🦐', color: Colors.red, type: 'red'),

      // amarelos
      GameItem(
          name: 'Banana',
          emoji: '🍌',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Croissant',
          emoji: '🥐',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Limão',
          emoji: '🍋',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Abacaxi',
          emoji: '🍍',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Milho',
          emoji: '🌽',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Biscoito',
          emoji: '🥠',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Pizza',
          emoji: '🍕',
          color: Colors.yellow[700]!,
          type: 'yellow'),
      GameItem(
          name: 'Queijo',
          emoji: '🧀',
          color: Colors.yellow[700]!,
          type: 'yellow'),

      // verdes
      GameItem(
          name: 'Maça Verde',
          emoji: '🍏',
          color: Colors.green[700]!,
          type: 'green'),
      GameItem(
          name: 'Limão-taiti',
          emoji: '🍋‍🟩',
          color: Colors.green[700]!,
          type: 'green'),
      GameItem(
          name: 'Pera', emoji: '🍐', color: Colors.green[700]!, type: 'green'),
      GameItem(
          name: 'Kiwi', emoji: '🥝', color: Colors.green[700]!, type: 'green'),
      GameItem(
          name: 'Azeitona',
          emoji: '🫒',
          color: Colors.green[700]!,
          type: 'green'),
      GameItem(
          name: 'Abacate',
          emoji: '🥑',
          color: Colors.green[700]!,
          type: 'green'),
      GameItem(
          name: 'Pepino',
          emoji: '🥒',
          color: Colors.green[700]!,
          type: 'green'),
      GameItem(
          name: 'Brócolis',
          emoji: '🥦',
          color: Colors.green[700]!,
          type: 'green'),
    ];

    List<String> allowedTypes;
    int quantityToTake;

    switch (difficulty) {
      case DifficultyLevel.easy:
        allowedTypes = ['red', 'yellow'];
        quantityToTake = 5;
        break;
      case DifficultyLevel.medium:
        allowedTypes = ['red', 'yellow'];
        quantityToTake = 8;
        break;
      case DifficultyLevel.hard:
        allowedTypes = ['red', 'yellow', 'green'];
        quantityToTake = 12;
        break;
    }

    // filtrando apenas os itens que tem a cesta correta disponível
    var possibleItems =
        allItems.where((item) => allowedTypes.contains(item.type)).toList();

    // random itens
    possibleItems.shuffle();

    // pega a qntd de itens necessarias p o nível
    return possibleItems.take(quantityToTake).toList();
  }

  void resetGame() {
    score = 0;
    items = generateItemsForDifficulty(currentDifficulty);
    totalItems = items.length;
  }

  void changeDifficulty(DifficultyLevel newDifficulty) {
    currentDifficulty = newDifficulty;
    resetGame();
  }

  void onItemDropped(GameItem item, String basketType) {
    if (item.type == basketType) {
      // se acertar ganha pontos e remove o item
      score += 10;
      items.remove(item);
    } else {
      // errou perde pontos mantém o item para tentar de novo
      score -= 5;
    }
  }

  double get progress =>
      totalItems > 0 ? ((totalItems - items.length) / totalItems) * 100 : 0;
}
