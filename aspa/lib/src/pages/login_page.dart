import 'package:aspa/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import '/api_service.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static const String routeName = '/loginPage';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  // Adicionado controladores para capturar o texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  void _fazerLogin() async {
    setState(() => _isLoading = true);

    final resultado =
        await _api.login(_emailController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (resultado != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso!')),
        );

        // NAVEGAÇÃO PARA A HOME
        // Passamos o ID e o Nome para a próxima tela não precisar carregar tudo de novo
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => Homepage(
                      userId: resultado['id_usuario'],
                    )));
      }
    } else {
      // ERRO
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email ou senha inválidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Removi o SchedulerBinding que redirecionava para '/register'
    // para que você possa ver e interagir com esta tela.
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Adota a cor de fundo do tema ou uma definida pelo contexto
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary, // Cor do Contexto
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Login',
            style: TextStyle(fontSize: 22),
          ),
          elevation: 2,
        ),
        // Centralização Total
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  height: 200, // Ajustado para caber melhor na tela
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 100),
                ),
                const SizedBox(height: 32),

                // Chamada dos inputs agora funcionais
                _buildInput(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Digite seu email',
                  icon: Icons.person_outline,
                  isEmail: true,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  icon: Icons.lock_outline,
                  isObscure: true,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _fazerLogin,
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
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary)
                      : Text(
                          'Entrar',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget de Input que permite escrever e usa cores do contexto
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    bool isEmail = false,
  }) {
    return SizedBox(
      width: 316,
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          suffixIcon: isEmail
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  icon: Icon(
                    isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
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
