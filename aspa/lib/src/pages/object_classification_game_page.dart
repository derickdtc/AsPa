import 'package:flutter/material.dart';
import '../controllers/classification_game_controller.dart';
import '../models/classification_game_model.dart';

class ObjectClassificationGame extends StatefulWidget {
  final int userId;
  const ObjectClassificationGame({super.key, required this.userId});

  @override
  State<ObjectClassificationGame> createState() =>
      _ObjectClassificationGameState();
}

class _ObjectClassificationGameState extends State<ObjectClassificationGame> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      controller.resetGame();
    });
  }

  void _changeDifficulty(DifficultyLevel newDifficulty) {
    setState(() {
      controller.changeDifficulty(newDifficulty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final basketConfigs = controller.getBasketConfigs();
    final basketWidgets = basketConfigs
        .map((config) => _buildBasket(
              color: config['color'] as Color,
              type: config['type'] as String,
              label: config['label'] as String,
              icon: config['icon'] as IconData,
            ))
        .toList();

    final basketRow = basketWidgets.length <= 2
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basketWidgets,
          )
        : Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: basketWidgets,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificação de Alimentos'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          PopupMenuButton<DifficultyLevel>(
            onSelected: _changeDifficulty,
            icon: Icon(Icons.settings, color: colorScheme.onPrimary),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DifficultyLevel.easy,
                child: Text('Fácil'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.medium,
                child: Text('Médio'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.hard,
                child: Text('Difícil'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _resetGame,
            tooltip: 'Reiniciar Jogo',
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Arraste as frutas para a cesta correta',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildScoreCard(theme, colorScheme),
                              _buildProgressCard(theme, colorScheme),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: basketRow,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app,
                              color: colorScheme.onSecondaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Segure e arraste',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Alimentos para classificar',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (controller.items.isEmpty)
                            _buildCompletionScreen(theme, colorScheme)
                          else
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: controller.items
                                  .map((item) => _buildDraggableItem(item))
                                  .toList(),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScoreCard(ThemeData theme, ColorScheme colorScheme) {
    return _buildInfoCard(
      title: 'Pontos',
      value: '${controller.score}',
      color: colorScheme.primary,
      bgColor: colorScheme.primaryContainer,
      theme: theme,
    );
  }

  Widget _buildProgressCard(ThemeData theme, ColorScheme colorScheme) {
    final progress = controller.progress;
    return _buildInfoCard(
      title: 'Progresso',
      value: '${progress.toInt()}%',
      color: colorScheme.secondary,
      bgColor: colorScheme.secondaryContainer,
      theme: theme,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasket({
    required Color color,
    required String type,
    required String label,
    required IconData icon,
  }) {
    return DragTarget<GameItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final isCorrect = data.type == type;

        setState(() {
          controller.onItemDropped(data, type);
        });

        // Feedback Visual
        if (isCorrect) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Muito bem! ${data.name} guardado.'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 600),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cesta errada. -5 pontos!'),
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        // se houver algo sendo arrastado sobre a cesta destaca
        final bool isHovering = candidateData.isNotEmpty;

        return Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovering ? color.withValues(alpha: 1.0) : color,
              width: isHovering ? 4 : 3,
            ),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.4), blurRadius: 10)
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(GameItem item) {
    return Draggable<GameItem>(
      key: ValueKey(item.name),
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Text(
          item.emoji,
          style: const TextStyle(fontSize: 70),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Text(
          item.emoji,
          style: const TextStyle(fontSize: 50),
        ),
      ),
      child: _buildItemContent(item),
    );
  }

  Widget _buildItemContent(GameItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.emoji,
            style: const TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 16),
          Text(
            'Parabéns!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você completou o exercício.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Jogar Novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _changeDifficulty(controller.currentDifficulty),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: colorScheme.primary),
              ),
              child: Text('Reiniciar Nível Atual',
                  style: TextStyle(color: colorScheme.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
