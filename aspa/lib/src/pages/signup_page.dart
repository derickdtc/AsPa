import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../controllers/signup_controller.dart';

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  final SignUpController controller = Modular.get<SignUpController>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaConfirmarController = TextEditingController();
  final _crmController = TextEditingController();
  final _dataDisplayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red),
      );
      controller.errorMessage = null;
    }

    // att o texto da data se ela mudar no controller
    if (controller.selectedDate != null) {
      final d = controller.selectedDate!;
      _dataDisplayController.text =
          "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
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
      // passa a data para o controller guardar
      controller.setSelectedDate(dataEscolhida);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _senhaConfirmarController.dispose();
    _crmController.dispose();
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
                      SizedBox(
                        width: 316,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Eu sou: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            RadioGroup<UserType>(
                              groupValue: controller.userType,
                              onChanged: controller.setUserType,
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: RadioListTile<UserType>(
                                      title: Text('Paciente'),
                                      value: UserType.paciente,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<UserType>(
                                      title: Text('Médico'),
                                      value: UserType.medico,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildInput(
                        controller: _nomeController,
                        label: 'Nome',
                        hint: 'Digite seu nome',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _emailController,
                        label: 'E-mail',
                        hint: 'Digite seu e-mail',
                        icon: Icons.mail,
                        isEmail: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _senhaController,
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _senhaConfirmarController,
                        label: 'Confirmar senha',
                        hint: 'Digite sua senha novamente',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      if (controller.userType == UserType.medico)
                        _buildInput(
                          controller: _crmController,
                          label: 'CRM',
                          hint: 'Digite seu CRM',
                          icon: Icons.badge,
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : () {
                                // dispara o cadastro no Controller
                                controller.cadastrar(
                                  nome: _nomeController.text,
                                  email: _emailController.text,
                                  senha: _senhaController.text,
                                  confirmarSenha:
                                      _senhaConfirmarController.text,
                                  crm: _crmController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(316, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Cadastrar',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return SizedBox(
      width: 316,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 3),
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
}
