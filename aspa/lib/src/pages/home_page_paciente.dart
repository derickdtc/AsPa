import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../controllers/home_paciente_controller.dart';

class Homepage extends StatefulWidget {
  final int userId;

  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.carregarDadosPaciente(widget.userId);
    controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        controller.limparErro();
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(context, colorScheme),
                    const SizedBox(height: 20),
                    _buildStreakCard(context, colorScheme),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        context, 'Exercícios', controller.mensagemExercicios),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context,
                      label: 'Ver Exercícios',
                      icon: Icons.directions_run,
                      color: colorScheme.tertiary,
                      onTap: () {
                        Modular.to
                            .pushNamed('/exercicios_list',
                                arguments: widget.userId)
                            .then((_) => controller
                                .carregarDadosPaciente(widget.userId));
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        context, 'Lembretes', controller.mensagemLembretes),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context,
                      label: 'Ver Lembretes',
                      icon: Icons.alarm_on_rounded,
                      color: colorScheme.secondary,
                      onTap: () {
                        Modular.to
                            .pushNamed('/lembretes_list',
                                arguments: widget.userId)
                            .then((_) => controller
                                .carregarDadosPaciente(widget.userId));
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        context, 'Jogos', "Treinamento Cognitivo"),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context,
                      label: 'Ver Jogos',
                      icon: Icons.gamepad,
                      color: colorScheme.tertiary,
                      onTap: () {
                        Modular.to
                            .pushNamed('/game', arguments: widget.userId)
                            .then((_) => controller
                                .carregarDadosPaciente(widget.userId));
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            context,
            icon: Icons.logout_outlined,
            onTap: () => Modular.to.navigate('/landing'),
            colorScheme: colorScheme,
            tooltip: 'Sair',
          ),
          _buildIconButton(
            context,
            icon: Icons.person,
            onTap: () => Modular.to.pushNamed('/profile',
                arguments: {'id': widget.userId, 'isMedico': false}),
            colorScheme: colorScheme,
            tooltip: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: colorScheme.onSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: controller.isLoading
          ? _buildLoadingCard(context, colorScheme)
          : _buildStreakContent(context, colorScheme),
    );
  }

  Widget _buildLoadingCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildStreakContent(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              Icons.celebration,
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              size: 120,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    7,
                    (index) =>
                        _buildStreakDay(index, controller.streak, colorScheme),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.paciente?.streakMessage ?? 'Carregando...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDay(int index, int streak, ColorScheme colorScheme) {
    bool completed = index < streak;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: completed
            ? colorScheme.onPrimary
            : colorScheme.onPrimary.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: completed
          ? Icon(
              Icons.check,
              color: colorScheme.primary,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
