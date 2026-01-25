import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '/api_service.dart';

class LoginController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String email, String senha) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Avisa a tela para mostrar o loading

    final resultado = await _api.login(email, senha);

    isLoading = false;
    notifyListeners();

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
      errorMessage = 'Email ou senha inválidos';
      notifyListeners();
    }
  }
}
