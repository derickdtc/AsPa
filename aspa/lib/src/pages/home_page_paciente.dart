import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../controllers/home_controller.dart';

class Homepage extends StatefulWidget {
  final int userId;

  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeController controller = Modular.get<HomeController>();

  @override
  void initState() {
    super.initState();
    controller.carregarDadosPaciente(widget.userId);
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
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Modular.to.navigate('/landing');
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.logout_outlined,
                                  color: colorScheme.onSecondary,
                                  size: 28, // Ajuste visual
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Modular.to.pushNamed('/profile', arguments: {
                                  'id': widget.userId,
                                  'isMedico': false
                                });
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: colorScheme.onSecondary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: controller.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildSummaryCard(
                                context,
                                color: colorScheme.primary,
                                icon: Icons.celebration,
                                text:
                                    'Você completou ${controller.streak} dias seguidos!',
                                height: 150,
                              ),
                      ),
                      _buildSectionHeader(context, 'Exercícios'),
                      _buildSubText(
                          context, 'Você tem 0 exercícios para hoje!'),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildActionCard(
                          context,
                          label: 'Ver Exercícios',
                          icon: Icons.directions_run,
                          onTap: () {
                            Modular.to.pushNamed('/game_jardineiro');
                          },
                        ),
                      ),
                      _buildSectionHeader(context, 'Lembretes'),
                      _buildSubText(context, 'Você tem 0 lembretes para hoje!'),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildActionCard(
                          context,
                          label: 'Ver Lembretes',
                          icon: Icons.alarm_on_rounded,
                          onTap: () {
                            Modular.to.pushNamed('/reminders');
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 30,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildSubText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String text,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 15),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
