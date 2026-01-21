import 'package:aspa/src/pages/jardineiro_game.dart';
import 'package:aspa/src/pages/landing_page.dart';
import 'package:aspa/src/pages/reminders_page.dart';
import 'package:flutter/material.dart';
import 'package:aspa/src/pages/profile_page.dart';
import '/api_service.dart';

class Homepage extends StatefulWidget {
  final int userId;

  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ApiService _api = ApiService();
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosPaciente();
  }

  // busca dados do banco (por enquanto so o streak, posteriormente buscar todas as infos.)
  void _carregarDadosPaciente() async {
    final dados = await _api.getPaciente(widget.userId);
    if (dados != null) {
      setState(() {
        _streak = dados['sequencia_dias'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // final textTheme = theme.textTheme;

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage()),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(userId: widget.userId)),
                          );
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
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : _buildSummaryCard(
                          context,
                          color: colorScheme.primary,
                          icon: Icons.celebration,
                          text: 'Você completou $_streak dias seguidos!',
                          height: 150,
                        ),
                ),
                _buildSectionHeader(context, 'Exercícios'),
                _buildSubText(context, 'Você tem 0 exercícios para hoje!'),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildActionCard(
                    context,
                    label: 'Ver Exercícios',
                    icon: Icons.directions_run,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JardineiroGame()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RemindersPage()),
                      );
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
