import 'package:flutter/material.dart';
import '../controllers/jardineiro_game_controller.dart';
import '../models/jardineiro_game_model.dart';

class JardineiroGamePage extends StatefulWidget {
  const JardineiroGamePage({super.key});

  @override
  State<JardineiroGamePage> createState() => _JardineiroGamePageState();
}

class _JardineiroGamePageState extends State<JardineiroGamePage>
    with SingleTickerProviderStateMixin {
  late JardineiroGameController _controller;
  late AnimationController _tapAnimationController;

  bool _showTapEffect = false;
  Offset _tapPosition = Offset.zero;
  final GlobalKey _gameContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _controller = JardineiroGameController();
    _controller.initAudio();

    _controller.onGameStateChanged = () => setState(() {});
    _controller.onScoreChanged = (_) => setState(() {});
    _controller.onFlowerMoved = _handleFlowerMovement;
    _controller.onGameFinished = () => _showGameOverDialog(context);

    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        if (!_tapAnimationController.isAnimating) {
          setState(() => _showTapEffect = false);
        }
      });
  }

  void _handleFlowerMovement(double left, double top) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderBox? gameContainerBox =
          _gameContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (gameContainerBox == null) return;

      final containerWidth = gameContainerBox.size.width;
      final containerHeight = gameContainerBox.size.height;

      if (containerWidth <= 0 || containerHeight <= 0) return;

      final flowerSize = _controller.config.getFlowerSize();
      final maxLeft = containerWidth - flowerSize;
      final maxTop = containerHeight - flowerSize;

      if (maxLeft <= 0 || maxTop <= 0) return;

      setState(() {
        _controller.flowerLeft = _controller.random.nextDouble() * maxLeft;
        _controller.flowerTop = _controller.random.nextDouble() * maxTop;
      });
    });
  }

  void _onFlowerTap() {
    setState(() {
      _showTapEffect = true;
      _tapPosition = Offset(
        _controller.flowerLeft + _controller.config.getFlowerSize() / 2,
        _controller.flowerTop + _controller.config.getFlowerSize() / 2,
      );
    });

    _tapAnimationController.forward(from: 0);
    _controller.handleFlowerTap();
  }

  void _onBackgroundTapDown(TapDownDetails details) {
    if (!_controller.isGameActive) return;

    final RenderBox? gameBox =
        _gameContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (gameBox == null) return;

    final localPos = gameBox.globalToLocal(details.globalPosition);
    final flowerSize = _controller.config.getFlowerSize();
    final flowerCenter = Offset(
      _controller.flowerLeft + flowerSize / 2,
      _controller.flowerTop + flowerSize / 2,
    );

    setState(() {
      _tapPosition = localPos;
      _showTapEffect = true;
    });

    _tapAnimationController.forward(from: 0);

    _controller.handleBackgroundTap(
      localPos.dx,
      localPos.dy,
      flowerCenter.dx,
      flowerCenter.dy,
      flowerSize / 2,
    );
  }

  void _showGameOverDialog(BuildContext context) {
    final gameDuration =
        DateTime.now().difference(_controller.stats.gameStartTime!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGameOverDialog(context, gameDuration),
      );
    });
  }

  Widget _buildGameOverDialog(BuildContext context, Duration gameDuration) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      title: Text(
        '🎉 Parabéns!',
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded,
                size: 60, color: colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              'Você completou o exercício!',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Dificuldade',
                      _controller.config.difficulty.name.toUpperCase()),
                  _buildStatRow('Tempo total', '${gameDuration.inSeconds}s'),
                  _buildStatRow('Precisão',
                      '${(_controller.stats.accuracy * 100).toStringAsFixed(1)}%'),
                  if (_controller.stats.reactionTimes.isNotEmpty)
                    _buildStatRow('Tempo médio de reação',
                        '${_controller.stats.averageReactionTime.toStringAsFixed(0)}ms'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _startGame();
          },
          child: Text('Jogar Novamente',
              style:
                  textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
          child: Text('Sair',
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary)),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(value,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _startGame() {
    _controller.startGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFlowerMovement(_controller.flowerLeft, _controller.flowerTop);
    });
  }

  Color _colorWithOpacity(Color color, double opacity) {
    final int r = (color.r * 255.0).round().clamp(0, 255);
    final int g = (color.g * 255.0).round().clamp(0, 255);
    final int b = (color.b * 255.0).round().clamp(0, 255);
    final double a = opacity.clamp(0.0, 1.0);

    return Color.fromRGBO(r, g, b, a);
  }

  Color _getDifficultyColor() {
    switch (_controller.config.difficulty) {
      case GameDifficulty.easy:
        return Theme.of(context).colorScheme.primary;
      case GameDifficulty.medium:
        return Theme.of(context).colorScheme.secondary;
      case GameDifficulty.hard:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  Widget _buildFlowerIcon(double size, Color color) {
    return Image.asset(
      'assets/images/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.local_florist_rounded,
          color: color,
          size: size,
        );
      },
    );
  }

  Widget _buildDifficultySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = !_controller.isGameActive;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDifficultyButton(
            'Fácil',
            GameDifficulty.easy,
            isActive && _controller.config.difficulty == GameDifficulty.easy,
            colorScheme.primary,
          ),
          _buildDifficultyButton(
            'Médio',
            GameDifficulty.medium,
            isActive && _controller.config.difficulty == GameDifficulty.medium,
            colorScheme.secondary,
          ),
          _buildDifficultyButton(
            'Difícil',
            GameDifficulty.hard,
            isActive && _controller.config.difficulty == GameDifficulty.hard,
            colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    String label,
    GameDifficulty difficulty,
    bool isSelected,
    Color selectedColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _controller.changeDifficulty(difficulty),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? selectedColor
                : colorScheme.surfaceContainerHighest,
            foregroundColor: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Jardineiro',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.secondary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Seletor de Dificuldade
              _buildDifficultySelector(),
              const SizedBox(height: 20),

              // Instruções e Placar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Semantics(
                      label: _controller.isGameActive
                          ? 'Toque na flor para regá-la. ${_controller.currentScore} de ${_controller.config.targetGoal} completos'
                          : 'Prepare-se para o exercício de coordenação. Pressione o botão começar',
                      child: Text(
                        _controller.isGameActive
                            ? 'Toque na flor para regá-la'
                            : 'Prepare-se para o exercício',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // barra de progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _controller.currentScore /
                            _controller.config.targetGoal,
                        minHeight: 20,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Flores: ${_controller.currentScore} / ${_controller.config.targetGoal}',
                      style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // area de jogo
              Expanded(
                child: Container(
                  key: _gameContainerKey,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: _onBackgroundTapDown,
                      child: Stack(
                        children: [
                          // background decorativo
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.surfaceContainerLow,
                                  _colorWithOpacity(
                                      colorScheme.surfaceContainerLow, 0.8),
                                ],
                              ),
                            ),
                          ),

                          // button p/ começar
                          if (!_controller.isGameActive)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildFlowerIcon(
                                      100,
                                      _colorWithOpacity(
                                          colorScheme.primary, 0.3)),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: size.width < 400
                                        ? size.width * 0.6
                                        : 200,
                                    height: 60,
                                    child: ElevatedButton.icon(
                                      onPressed: _startGame,
                                      icon:
                                          const Icon(Icons.play_arrow_rounded),
                                      label: Text('Começar',
                                          style: textTheme.headlineSmall
                                              ?.copyWith(
                                                  fontSize: 22,
                                                  color:
                                                      colorScheme.onPrimary)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        shadowColor: _colorWithOpacity(
                                            colorScheme.primary, 0.3),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Flor
                          if (_controller.isGameActive)
                            Positioned(
                              left: _controller.flowerLeft,
                              top: _controller.flowerTop,
                              child: GestureDetector(
                                onTap: _onFlowerTap,
                                child: Semantics(
                                  label:
                                      'Flor para regar. Toque para continuar',
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    width: _controller.config.getFlowerSize(),
                                    height: _controller.config.getFlowerSize(),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primaryContainer,
                                          _colorWithOpacity(
                                              colorScheme.primaryContainer,
                                              0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _colorWithOpacity(
                                              colorScheme.primary, 0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: _buildFlowerIcon(
                                      _controller.config.getFlowerSize() * 0.6,
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Efeito de Toque
                          if (_showTapEffect && _controller.isGameActive)
                            Positioned(
                              left: _tapPosition.dx - 40,
                              top: _tapPosition.dy - 40,
                              child: ScaleTransition(
                                scale: _tapAnimationController.drive(
                                  CurveTween(curve: Curves.easeOut),
                                ),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _colorWithOpacity(
                                          colorScheme.primary, 0.5),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Informações adicionais
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dificuldade:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _controller.config.difficulty.name.toUpperCase(),
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Precisão:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _controller.stats.totalTaps > 0
                              ? '${(_controller.stats.accuracy * 100).toStringAsFixed(1)}%'
                              : '100%',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
