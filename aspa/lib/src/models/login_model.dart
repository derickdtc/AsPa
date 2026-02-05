// Modelo para dados do login
class LoginCredentials {
  String email;
  String senha;

  LoginCredentials({
    required this.email,
    required this.senha,
  });

  bool isValid() {
    return email.isNotEmpty && senha.isNotEmpty;
  }

  String? validate() {
    if (email.isEmpty) return 'Email é obrigatório';
    if (senha.isEmpty) return 'Senha é obrigatória';
    return null;
  }
}

// Resposta
class LoginResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  LoginResponse({
    required this.success,
    this.message,
    this.data,
  });
}
