import 'package:aspa/src/pages/home_page.dart';
import 'package:flutter/material.dart';

enum UserType { paciente, medico }

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  static const String routeName = '/SignUpPage';

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  final TextEditingController _signUpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserType userType = UserType.paciente;

  final TextEditingController _crmController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _signUpController.dispose();
    _passwordController.dispose();
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
          backgroundColor:
              Theme.of(context).colorScheme.primary, 
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

                _buildInput(
                  controller: _signUpController,
                  label: 'Login',
                  hint: 'Digite seu usuário',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  icon: Icons.mail,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  label: 'Confirmar senha',
                  hint: 'Digite sua senha novamente',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(
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
                
                
                const SizedBox(height: 16),
                if(userType == UserType.medico)
                  _buildInput(
                    controller: _passwordController,
                    label: 'CRM',
                    hint: 'Digite seu CRM',
                    icon: Icons.badge,
                    isPassword: true,
                  ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Homepage()),
                    );
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

  // Widget de Input que permite escrever e usa cores do contexto
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return SizedBox(
      width: 316,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
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
