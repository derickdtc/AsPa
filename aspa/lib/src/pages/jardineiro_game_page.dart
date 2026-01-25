import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

enum GameDifficulty { easy, medium, hard }

class JardineiroGame extends StatefulWidget {
  const JardineiroGame({super.key});

  @override
  State<JardineiroGame> createState() => _JardineiroGameState();
}

class _JardineiroGameState extends State<JardineiroGame>
    with SingleTickerProviderStateMixin {
  // config do jogo
  final int _targetGoal = 10;
  int _currentScore = 0;
  bool _isGameActive = false;
  GameDifficulty _currentDifficulty = GameDifficulty.easy;
  int _moveTimeLimit = 3000;
  // som
  late AudioPlayer _audioPlayer;
  bool _audioInitialized = false;
  // controle de pos(x,y)
  double _top = 0;
  double _left = 0;
  double _flowerSize = 80.0;

  // animações
  late AnimationController _tapAnimationController;
  bool _showTapEffect = false;
  Offset _tapPosition = Offset.zero;

  // stats
  int _totalTaps = 0;
  int _successfulTaps = 0;
  final List<double> _reactionTimes = [];
  final Stopwatch _reactionTimer = Stopwatch();
  Timer? _autoMoveTimer;
  DateTime? _gameStartTime;

  final Random _random = Random();

  // Key p/ acessar as dimensões do container do jogo
  final GlobalKey _gameContainerKey = GlobalKey();

  Color _colorWithOpacity(Color color, double opacity) {
    final int r = (color.r * 255.0).round().clamp(0, 255);
    final int g = (color.g * 255.0).round().clamp(0, 255);
    final int b = (color.b * 255.0).round().clamp(0, 255);
    final double a = opacity.clamp(0.0, 1.0);

    return Color.fromRGBO(r, g, b, a);
  }

  @override
  void initState() {
    super.initState();
    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        if (!_tapAnimationController.isAnimating) {
          setState(() => _showTapEffect = false);
        }
      });
    // inicializar áudio
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setSource(AssetSource('audios/tap.mp3'));
      setState(() {
        _audioInitialized = true;
      });
    } catch (e) {
      // print('Erro: $e');
    }
  }

  void _startGame() {
    // resetar estatísticas
    _reactionTimes.clear();
    _reactionTimer.reset();
    _totalTaps = 0;
    _successfulTaps = 0;
    _gameStartTime = DateTime.now();

    // config baseando na dificuldade
    switch (_currentDifficulty) {
      case GameDifficulty.easy:
        _flowerSize = 80.0;
        _moveTimeLimit = 3000;
        break;
      case GameDifficulty.medium:
        _flowerSize = 60.0;
        _moveTimeLimit = 2000;
        break;
      case GameDifficulty.hard:
        _flowerSize = 40.0;
        _moveTimeLimit = 1500;
        break;
    }

    setState(() {
      _currentScore = 0;
      _isGameActive = true;
      // definindo pos inicial p/ centro
      _top = 0;
      _left = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveFlower();
    });

    // iniciar timer para mover automaticamente (exceto no fácil)
    if (_currentDifficulty != GameDifficulty.easy) {
      _startAutoMoveTimer();
    }
  }

  void _startAutoMoveTimer() {
    _autoMoveTimer?.cancel();
    _autoMoveTimer = Timer.periodic(
      Duration(milliseconds: _moveTimeLimit),
      (timer) {
        if (_isGameActive && mounted) {
          // Qnd o timer move a flor sem interação do usuário,
          // contar como um "miss" (aumentando _totalTaps, mas não _successfulTaps)
          _moveFlower(missed: true);
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _moveFlower({bool missed = false}) {
    if (!mounted || !_isGameActive) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // obtem as dimensões do container do jogo
      final RenderBox? gameContainerBox =
          _gameContainerKey.currentContext?.findRenderObject() as RenderBox?;

      if (gameContainerBox == null) return;

      final double containerWidth = gameContainerBox.size.width;
      final double containerHeight = gameContainerBox.size.height;

      // verifica se o container tem dimensões válidas
      if (containerWidth <= 0 || containerHeight <= 0) return;

      // calc limites max considerando o tamanho da flor
      final double maxLeft = containerWidth - _flowerSize;
      final double maxTop = containerHeight - _flowerSize;

      // garantindo que os valores sejam válidos
      if (maxLeft <= 0 || maxTop <= 0) return;

      setState(() {
        _left = _random.nextDouble() * maxLeft;
        _top = _random.nextDouble() * maxTop;
      });
      // se este movimento foi disparado automaticamente (miss),
      // contabilizar como tentativa não sucedida para afetar a precisão
      if (missed) {
        setState(() {
          _totalTaps++;
        });
      }
    });
  }

  void _onFlowerTap() {
    _playSound('tap.mp3');

    _totalTaps++;
    _successfulTaps++;

    // feedback tátil
    HapticFeedback.lightImpact();

    // visual effect
    setState(() {
      _showTapEffect = true;
      _currentScore++;
      _tapPosition = Offset(_left + _flowerSize / 2, _top + _flowerSize / 2);
    });

    _tapAnimationController.forward(from: 0);

    // registrar tempo de reação
    if (_reactionTimer.isRunning) {
      _reactionTimes.add(_reactionTimer.elapsedMilliseconds.toDouble());
      _reactionTimer.reset();
    }

    if (_currentScore >= _targetGoal) {
      _finishGame();
    } else {
      _moveFlower();
      // reiniciar timer
      if (_currentDifficulty != GameDifficulty.easy) {
        _autoMoveTimer?.cancel();
        _startAutoMoveTimer();
      }
    }
  }

  void _onBackgroundTapDown(TapDownDetails details) {
    if (!_isGameActive) return;

    final RenderBox? gameBox =
        _gameContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (gameBox == null) return;

    final localPos = gameBox.globalToLocal(details.globalPosition);

    final flowerCenter =
        Offset(_left + _flowerSize / 2, _top + _flowerSize / 2);
    final dx = localPos.dx - flowerCenter.dx;
    final dy = localPos.dy - flowerCenter.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = _flowerSize / 2;

    // se o toque estiver fora do raio da flor, aplica penalidade
    if (distance > radius) {
      setState(() {
        _totalTaps++;
        // mostra um feedback visual no ponto tocado
        _tapPosition = localPos;
        _showTapEffect = true;
      });

      // efeito tátil e sonoro (se disponível)
      HapticFeedback.mediumImpact();
      try {
        _playSound('miss.wav');
      } catch (_) {
        // silencia erros se o asset não existir
      }

      _tapAnimationController.forward(from: 0);
    }
  }

  double _calculateAverageReactionTime() {
    if (_reactionTimes.isEmpty) return 0.0;
    final sum = _reactionTimes.reduce((a, b) => a + b);
    return (sum / _reactionTimes.length);
  }

  Future<void> _playSound(String soundFileName) async {
    if (!_audioInitialized) {
      await _initAudio();
      if (!_audioInitialized) {
        return;
      }
    }

    try {
      await _audioPlayer.play(AssetSource('audios/$soundFileName'));
    } catch (e) {
      // print('Erro "$soundFileName": $e'); // acho q n vai dar mais ent tanto faz
    }
  }

  void _finishGame() {
    _autoMoveTimer?.cancel();
    _reactionTimer.stop();

    final gameDuration = DateTime.now().difference(_gameStartTime!);
    _playSound('win.mp3');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

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
                // Estatísticas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                          'Dificuldade', _currentDifficulty.name.toUpperCase()),
                      _buildStatRow(
                          'Tempo total', '${gameDuration.inSeconds}s'),
                      _buildStatRow('Precisão',
                          '${(_successfulTaps / _totalTaps * 100).toStringAsFixed(1)}%'),
                      if (_reactionTimes.isNotEmpty)
                        _buildStatRow('Tempo médio de reação',
                            '${_calculateAverageReactionTime().toStringAsFixed(0)}ms'),
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
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style:
                  FilledButton.styleFrom(backgroundColor: colorScheme.primary),
              child: Text('Sair',
                  style: textTheme.bodyLarge
                      ?.copyWith(color: colorScheme.onPrimary)),
            ),
          ],
        );
      },
    );

    setState(() {
      _isGameActive = false;
    });
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

  void _changeDifficulty(GameDifficulty difficulty) {
    if (_isGameActive) return;
    setState(() {
      _currentDifficulty = difficulty;
    });
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    _autoMoveTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildDifficultySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = !_isGameActive;

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
            isActive && _currentDifficulty == GameDifficulty.easy,
            colorScheme.primary,
          ),
          _buildDifficultyButton(
            'Médio',
            GameDifficulty.medium,
            isActive && _currentDifficulty == GameDifficulty.medium,
            colorScheme.secondary,
          ),
          _buildDifficultyButton(
            'Difícil',
            GameDifficulty.hard,
            isActive && _currentDifficulty == GameDifficulty.hard,
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
          onPressed: () => _changeDifficulty(difficulty),
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
                      label: _isGameActive
                          ? 'Toque na flor para regá-la. $_currentScore de $_targetGoal completos'
                          : 'Prepare-se para o exercício de coordenação. Pressione o botão começar',
                      child: Text(
                        _isGameActive
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
                        value: _currentScore / _targetGoal,
                        minHeight: 20,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Flores: $_currentScore / $_targetGoal',
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
                  key: _gameContainerKey, // Key p/ saber as dimensões
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
                          if (!_isGameActive)
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
                                    width: min(size.width * 0.6, 200),
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
                          if (_isGameActive)
                            Positioned(
                              left: _left,
                              top: _top,
                              child: GestureDetector(
                                onTap: _onFlowerTap,
                                child: Semantics(
                                  label:
                                      'Flor para regar. Toque para continuar',
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    width: _flowerSize,
                                    height: _flowerSize,
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
                                      _flowerSize * 0.6,
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Efeito de Toque
                          if (_showTapEffect && _isGameActive)
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
                          _currentDifficulty.name.toUpperCase(),
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
                          _totalTaps > 0
                              ? '${(_successfulTaps / _totalTaps * 100).toStringAsFixed(1)}%'
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

  Color _getDifficultyColor() {
    switch (_currentDifficulty) {
      case GameDifficulty.easy:
        return Theme.of(context).colorScheme.primary;
      case GameDifficulty.medium:
        return Theme.of(context).colorScheme.secondary;
      case GameDifficulty.hard:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  Widget _buildFlowerIcon(double size, Color color) {
    // img da tulipa, talvez podemos substituir no futuro
    // caso a img não exista utilizando icon de flor como fallback
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
}
