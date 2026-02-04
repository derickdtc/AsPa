import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../controllers/signup_controller.dart';
import '../models/signup_model.dart';

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  final SignUpController controller = Modular.get<SignUpController>();
  final _dataDisplayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    _updateDateDisplay();
  }

  void _onControllerChange() {
    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      controller.clearError();
    }

    _updateDateDisplay();
  }

  void _updateDateDisplay() {
    if (controller.selectedDate != null) {
      final d = controller.selectedDate!;
      _dataDisplayController.text =
          "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    } else {
      _dataDisplayController.clear();
    }
  }

  Future<void> _abrirCalendario() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (dataEscolhida != null) {
      controller.setSelectedDate(dataEscolhida);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    _dataDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Modular.to.pop(),
          ),
          title: const Text(
            'Cadastrar',
            style: TextStyle(fontSize: 22),
          ),
          elevation: 2,
        ),
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icon.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 100),
                    ),
                    const SizedBox(height: 32),
                    _buildUserTypeSelector(),
                    const SizedBox(height: 16),
                    _buildFormFields(),
                    const SizedBox(height: 16),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return SizedBox(
      width: 316,
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Eu sou: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RadioGroup<UserType>(
            groupValue: controller.userType,
            onChanged: (value) => controller.setUserType(value!),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<UserType>(
                    title: const Text('Paciente'),
                    value: UserType.paciente,
                  ),
                ),
                Expanded(
                  child: RadioListTile<UserType>(
                    title: const Text('Médico'),
                    value: UserType.medico,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInput(
          label: 'Nome',
          hint: 'Digite seu nome',
          icon: Icons.person_outline,
          onChanged: (value) => controller.setNome(value),
        ),
        const SizedBox(height: 16),
        _buildInput(
          label: 'E-mail',
          hint: 'Digite seu e-mail',
          icon: Icons.mail,
          onChanged: (value) => controller.setEmail(value),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildInput(
          label: 'Senha',
          hint: 'Digite sua senha',
          icon: Icons.lock_outline,
          onChanged: (value) => controller.setSenha(value),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildInput(
          label: 'Confirmar senha',
          hint: 'Digite sua senha novamente',
          icon: Icons.lock_outline,
          onChanged: (value) => controller.setConfirmarSenha(value),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        if (controller.userType == UserType.medico)
          _buildInput(
            label: 'CRM',
            hint: 'Digite seu CRM',
            icon: Icons.badge,
            onChanged: (value) => controller.setCrm(value),
          ),
        if (controller.userType == UserType.paciente)
          _buildInput(
            controller: _dataDisplayController,
            label: 'Data de Diagnóstico',
            hint: 'Toque para selecionar',
            icon: Icons.calendar_today,
            readOnly: true,
            onTap: _abrirCalendario,
          ),
      ],
    );
  }

  Widget _buildInput({
    TextEditingController? controller,
    required String label,
    required String hint,
    required IconData icon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 316,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: controller.isLoading ? null : () => controller.cadastrar(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: const Size(316, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: controller.isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'Cadastrar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
    );
  }
}
