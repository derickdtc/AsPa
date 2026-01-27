import 'package:flutter/material.dart';
import '/api_service.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String nome = '';
  // talvez add mais campos aqui depois (email, foto, etc)

  Future<void> carregarDados(int userId, bool isMedico) async {
    isLoading = true;
    notifyListeners();

    Map<String, dynamic>? dados;

    if (isMedico) {
      dados = await _api.getMedico(userId);
    } else {
      dados = await _api.getPaciente(userId);
    }

    if (dados != null) {
      nome = dados['nome'] ?? 'Usuário';
    } else {
      nome = 'Erro ao carregar';
    }

    isLoading = false;
    notifyListeners();
  }
}
