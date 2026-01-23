import 'package:aspa/src/pages/home_page_medico.dart';
import 'package:aspa/src/pages/home_page_paciente.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart';
import '/api_service.dart';

enum UserType { paciente, medico }

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  static const String routeName = '/SignUpPage';

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaConfirmarController = TextEditingController();
  final _dataDiagnosticoController = TextEditingController();
  final _crmController = TextEditingController();
  final ApiService _api = ApiService();
  UserType userType = UserType.paciente;
  // ignore: unused_field
  bool _isLoading = false;
  DateTime? _dataSelecionada;

  void _fazerCadastro() async {
    setState(() => _isLoading = true);
    final Map<String, dynamic>? resultado;

    if (userType == UserType.paciente) {
      // verifica se a pessoa selecionou a data
      if (_dataSelecionada == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selecione a data do diagnóstico!'),
              backgroundColor: Colors.red),
        );
        return;
      }

      String dataParaAPI = _dataSelecionada!.toIso8601String().substring(0, 10);

      resultado = await _api.cadastrarPaciente(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
        dataParaAPI,
      );
    } else {
      resultado = await _api.cadastrarMedico(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
        _crmController.text,
      );
    }

    setState(() => _isLoading = false);

    if (resultado != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );

        if (userType == UserType.paciente) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => Homepage(
                        userId: resultado?['id_usuario'],
                      )));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomePageMedico(
                        userId: resultado?['id_usuario'],
                        userName: _nomeController.text,
                      )));
        }
      }
    } else {
      // ERRO
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Há dados inválidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirCalendario() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // começa selecionado no dia presente
      firstDate: DateTime(1940), // data mínima permitida p cadastro
      lastDate:
          DateTime.now(), // data maxima sempre será o dia atual do cadastro
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
        // mostra pro usuário no formato DD/MM/AAAA
        _dataDiagnosticoController.text =
            "${dataEscolhida.day.toString().padLeft(2, '0')}/${dataEscolhida.month.toString().padLeft(2, '0')}/${dataEscolhida.year}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _crmController.dispose();
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
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Cadastrar',
            style: TextStyle(fontSize: 22),
          ),
          elevation: 2,
        ),
        body: Center(
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
                        groupValue: userType,
                        onChanged: (value) {
                          setState(() {
                            userType = value!;
                          });
                        },
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
                if (userType == UserType.medico)
                  _buildInput(
                    controller: _crmController,
                    label: 'CRM',
                    hint: 'Digite seu CRM',
                    icon: Icons.badge,
                  ),
                if (userType == UserType.paciente)
                  _buildInput(
                    controller: _dataDiagnosticoController,
                    label: 'Data de Diagnóstico',
                    hint: 'Toque para selecionar',
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _abrirCalendario,
                    isDate: true,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_senhaController.text ==
                        _senhaConfirmarController.text) {
                      _fazerCadastro();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('As senhas não conferem.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // Cor do Contexto
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(316, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    bool isDate = false,
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
