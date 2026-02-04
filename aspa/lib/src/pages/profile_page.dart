import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final bool isMedico;

  const ProfilePage({
    super.key,
    required this.userId,
    this.isMedico = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = ProfileController();

  @override
  void initState() {
    super.initState();
    controller.carregarDados(widget.userId, widget.isMedico);
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
    final textTheme = theme.textTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildAppBar(context, colorScheme, textTheme),
                  _buildProfileHeader(context, colorScheme, textTheme),
                  const SizedBox(height: 20),
                  _buildMenuList(context, colorScheme, textTheme),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
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
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 50, 0),
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
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        _buildProfileImage(context, colorScheme),
        const SizedBox(height: 20),
        _buildProfileInfo(context, colorScheme, textTheme),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 106,
          height: 106,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(
            'assets/images/icon.png',
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) =>
                _buildProfilePlaceholder(colorScheme),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.surface,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.mode_edit_outlined,
              color: colorScheme.onSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 50,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProfileInfo(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Text(
          controller.nome,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontSize: 24,
          ),
        ),
        if (controller.userProfile != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.userProfile!.email,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          if (controller.isMedico && controller.crm != null)
            Text(
              'CRM: ${controller.crm}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
          if (!controller.isMedico &&
              controller.userProfile!.dataDiagnosticoFormatada != null)
            Text(
              'Diagnóstico: ${controller.userProfile!.dataDiagnosticoFormatada}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMenuList(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: controller.menuItems
          .map((item) => _buildMenuItem(context, item, colorScheme, textTheme))
          .toList(),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ProfileMenuItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
      child: InkWell(
        onTap: () => _navigateToMenuItem(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: colorScheme.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMenuItem(ProfileMenuItem item) {
    if (item.route == '/login') {
      // fazendo logout antes de navegar
      controller.fazerLogout();
      Modular.to.navigate(item.route);
    } else {
      Modular.to.pushNamed(item.route, arguments: item.arguments);
    }
  }
}
