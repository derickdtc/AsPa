import 'package:aspa/src/pages/edit_profile_page.dart';
import 'package:aspa/src/pages/favorites_page.dart';
import 'package:aspa/src/pages/help_page.dart';
import 'package:aspa/src/pages/login_page.dart';
import 'package:aspa/src/pages/privacy_policy_page.dart';
import 'package:aspa/src/pages/settings_page.dart';
import 'package:flutter/material.dart';
import '/api_service.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _api = ApiService();
  String _nome = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosPaciente();
  }

  // buscando dados do banco
  void _carregarDadosPaciente() async {
    final dados = await _api.getPaciente(widget.userId);
    if (dados != null) {
      setState(() {
        _nome = dados['nome'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colorScheme.secondary,
                          size: 28,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 50, 0),
                        child: Text(
                          'Meu Perfil',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Stack(
                  children: [
                    Container(
                      width: 106,
                      height: 106,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/images/icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.person,
                              size: 50, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(75, 75, 0, 0),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mode_edit_outlined,
                            color: colorScheme.onSecondary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 10),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        _nome,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontSize: 24,
                        ),
                      ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.person,
                label: 'Editar Dados',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.favorite_border,
                label: 'Favoritos',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritesPage()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings_sharp,
                label: 'Configurações',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock,
                label: 'Políticas de Privacidade',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline_sharp,
                label: 'Ajuda',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpPage()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPageWidget()));
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.onSecondary, size: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 29, 0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
