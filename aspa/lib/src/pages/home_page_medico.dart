import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_medico_controller.dart';
import '../models/home_medico_model.dart';

class HomePageMedico extends StatefulWidget {
  final int userId;
  final String userName;

  const HomePageMedico({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<HomePageMedico> createState() => _HomePageMedicoState();
}

class _HomePageMedicoState extends State<HomePageMedico> {
  final HomeMedicoController controller = Modular.get<HomeMedicoController>();

  @override
  void initState() {
    super.initState();
    controller.carregarDadosMedico(widget.userId);
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
                    const SizedBox(height: 30),
                    _buildWelcomeSection(context, colorScheme),
                    const SizedBox(height: 30),
                    _buildPacientesSection(context),
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
          ),
          _buildIconButton(
            context,
            icon: Icons.person,
            onTap: () => Modular.to.pushNamed('/profile', arguments: {
              'id': widget.userId,
              'isMedico': true,
            }),
            colorScheme: colorScheme,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: colorScheme.onSecondary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ColorScheme colorScheme) {
    return Padding(
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
          const SizedBox(height: 8),
          controller.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'CRM: ${controller.crm}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.secondary,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPacientesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              _buildAddPacienteButton(context, colorScheme),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildPacientesList(context),
      ],
    );
  }

  Widget _buildAddPacienteButton(
      BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _mostrarDialogoAdicionarPaciente(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPacientesList(BuildContext context) {
    if (controller.isLoading && controller.pacientes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.pacientes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Nenhum paciente cadastrado ainda.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: controller.pacientes
          .map((paciente) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPacienteCard(context, paciente),
              ))
          .toList(),
    );
  }

  Widget _buildPacienteCard(
      BuildContext context, PacienteListadoModel paciente) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.navegarParaPerfilPaciente(paciente, context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildPacienteAvatar(paciente, theme),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paciente.nome,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Última consulta: ${paciente.ultimaConsultaFormatada}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildPacienteStatusIndicator(paciente),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacienteAvatar(PacienteListadoModel paciente, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildPacienteStatusIndicator(PacienteListadoModel paciente) {
    if (paciente.temExerciciosPendentes) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox(width: 12);
  }

  Future<void> _mostrarDialogoAdicionarPaciente(BuildContext context) async {
    final nomeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Paciente'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do Paciente',
              hintText: 'Digite o nome completo',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.trim().isNotEmpty) {
                  controller.adicionarPaciente(nomeController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}
