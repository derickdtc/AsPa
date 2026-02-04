import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '/api_service.dart';
import '../models/login_model.dart';

class LoginController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  final LoginCredentials _credentials = LoginCredentials(email: '', senha: '');

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmail(String email) {
    _credentials.email = email;
  }

  void setSenha(String senha) {
    _credentials.senha = senha;
  }

  Future<void> login() async {
    // Validação simples
    final error = _credentials.validate();
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final resultado = await _api.login(_credentials.email, _credentials.senha);

    _isLoading = false;

    if (resultado != null) {
      final String tipo = resultado['tipo_usuario'] ?? 'paciente';
      final String nome = resultado['nome'];
      final int id = resultado['id_usuario'];

      if (tipo == 'medico') {
        Modular.to
            .navigate('/home_medico', arguments: {'id': id, 'name': nome});
      } else {
        Modular.to.navigate('/home_paciente', arguments: id);
      }
    } else {
      _errorMessage = 'Email ou senha inválidos';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
