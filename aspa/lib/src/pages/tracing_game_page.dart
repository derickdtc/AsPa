import 'package:flutter/material.dart';
import '../controllers/tracing_game_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../models/tracing_game_model.dart';

class TracingGamePage extends StatefulWidget {
  final int userId;

  const TracingGamePage({super.key, required this.userId});

  @override
  State<TracingGamePage> createState() => _TracingGamePageState();
}

class _TracingGamePageState extends State<TracingGamePage> {
  final TracingController _controller = TracingController();

  // controla se estamos no menu de seleção ou no jogo
  bool _isSetupDone = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameUpdate);
  }

  void _onGameUpdate() {
    if (mounted) setState(() {});
    if (_controller.status == GameStatus.won) {
      _controller.removeListener(_onGameUpdate);
      _showVictoryDialog();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame(GameDifficulty difficulty) {
    _controller.setDifficulty(difficulty);
    setState(() {
      _isSetupDone = true;
    });
  }

  void _showVictoryDialog() {
    final isFinalLevel = _controller.isLastLevel;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(isFinalLevel ? Icons.emoji_events : Icons.check_circle,
            size: 48, color: Theme.of(context).colorScheme.primary),
        title: Text(
            isFinalLevel
                ? "Desafio Completo!"
                : "Fase ${_controller.level.id} Concluída",
            textAlign: TextAlign.center),
        content: Text(
          isFinalLevel
              ? "Parabéns! Você finalizou o exercício."
              : "Muito bem! Prepare-se para a próxima fase.",
          textAlign: TextAlign.center,
        ),
        actions: [
          if (!isFinalLevel)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _controller.restartGame();
                _controller.addListener(_onGameUpdate);
              },
              child: const Text("Repetir Fase"),
            ),
          SizedBox(
            width: isFinalLevel ? double.infinity : null,
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();

                if (isFinalLevel) {
                  Modular.to.pop();
                } else {
                  final size = MediaQuery.of(context).size;
                  final safeHeight = size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top;

                  _controller.nextLevel(Size(size.width, safeHeight));
                  _controller.addListener(_onGameUpdate);
                  setState(() {});
                }
              },
              child: Text(isFinalLevel ? "Voltar ao Início" : "Próxima Fase"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Se dificuldade não escolhida, mostrar menu
    if (!_isSetupDone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Nova Sessão"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Modular.to.pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Escolha a dificuldade:",
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 32),
              _buildDifficultyButton(
                  "Fácil", GameDifficulty.easy, Colors.green),
              const SizedBox(height: 16),
              _buildDifficultyButton(
                  "Médio", GameDifficulty.medium, Colors.orange),
              const SizedBox(height: 16),
              _buildDifficultyButton(
                  "Difícil", GameDifficulty.hard, Colors.red),
            ],
          ),
        ),
      );
    }

    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Fase ${_controller.level.id}: ${_controller.level.name}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSetupDone = false;
            });
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_controller.level.name.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.initLevel(constraints.biggest);
            });
          }

          if (_controller.level.name.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GestureDetector(
                onPanStart: (details) =>
                    _controller.onPointerDown(details.localPosition),
                onPanUpdate: (details) =>
                    _controller.onPointerMove(details.localPosition),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: GamePainter(
                    level: _controller.level,
                    userTrace: _controller.userPath,
                    status: _controller.status,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
              if (_controller.status == GameStatus.lost)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Ops! Saiu da linha.",
                          style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => _controller.restartGame(),
                          icon: Icon(Icons.refresh,
                              color: colorScheme.onErrorContainer),
                          label: Text("Tentar Novamente",
                              style: TextStyle(
                                  color: colorScheme.onErrorContainer)),
                        )
                      ],
                    ),
                  ),
                ),
              if (_controller.userPath.isEmpty &&
                  _controller.status == GameStatus.playing)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Toque no círculo verde para começar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDifficultyButton(
      String label, GameDifficulty difficulty, Color color) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color, // Cor do texto
        ),
        onPressed: () => _startGame(difficulty),
        child: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final LevelModel level;
  final List<Offset> userTrace;
  final GameStatus status;
  final ColorScheme colorScheme;

  GamePainter({
    required this.level,
    required this.userTrace,
    required this.status,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // road
    final pathPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = level.pathWidth;

    canvas.drawPath(level.pathShape, pathPaint);

    // guia
    final guidePaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(level.pathShape, guidePaint);

    // inicio e fim
    canvas.drawCircle(
        level.startPoint, level.pathWidth / 2.5, Paint()..color = Colors.green);
    canvas.drawCircle(level.endPoint, level.pathWidth / 2.5,
        Paint()..color = Colors.redAccent);

    // rastro
    if (userTrace.isNotEmpty) {
      final tracePath = Path();
      tracePath.moveTo(userTrace.first.dx, userTrace.first.dy);
      for (var p in userTrace) {
        tracePath.lineTo(p.dx, p.dy);
      }

      final userPaint = Paint()
        ..color =
            status == GameStatus.lost ? colorScheme.error : colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = level.pathWidth * 0.4;

      canvas.drawPath(tracePath, userPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
