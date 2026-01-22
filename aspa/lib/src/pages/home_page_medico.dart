import 'package:aspa/src/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:aspa/src/pages/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '/api_service.dart';

class HomePageMedico extends StatefulWidget {
  final int userId;
  final String userName;

  const HomePageMedico(
      {super.key, required this.userId, required this.userName});

  @override
  State<HomePageMedico> createState() => _HomePageMedicoState();
}

class _HomePageMedicoState extends State<HomePageMedico> {
  final ApiService _api = ApiService();
  String _crm = "Carregando..."; // só p não ficar nada
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosMedico();
  }

  void _carregarDadosMedico() async {
    final dados = await _api.getMedico(widget.userId);
    if (dados != null) {
      setState(() {
        // _nome = dados['nome'];
        _crm = dados['crm'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                          Navigator.pushReplacement(
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
                            size: 28,
                          ),
                        ),
                      ),
                      // Ícone de Perfil
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                      userId: widget.userId,
                                      isMedico: true,
                                    )),
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
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Dr(a). ${widget.userName}',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'CRM: $_crm',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pacientes',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // logica p/ adicionar paciente futuramente
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Calm Down Pepperoni, isso vai ser implementado ainda")));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.add,
                            color: colorScheme.primary,
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
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // alterar para pacientes reais posteriormente
                            _buildActionCard(
                              context,
                              label: 'Pablo do Arrocha',
                              icon: Icons.person,
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),
                            _buildActionCard(
                              context,
                              label: 'Maria Luiza Costa Andrade',
                              icon: Icons.person,
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),
                            _buildActionCard(
                              context,
                              label: 'Japonês da Federal',
                              icon: Icons.person,
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),

                            _buildActionCard(
                              context,
                              label: 'Gustavo Assunção do Amaral',
                              icon: Icons.person,
                              onTap: () {},
                            ),
                          ],
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
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16)
          ],
        ),
      ),
    );
  }
}
