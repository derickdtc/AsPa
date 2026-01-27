import 'package:flutter/material.dart';
import '/api_service.dart';

class HomeController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = true;
  int streak = 0;
  String errorMessage = '';

  Future<void> carregarDadosPaciente(int userId) async {
    isLoading = true;
    notifyListeners(); // Avisa a tela para mostrar loading

    final dados = await _api.getPaciente(userId);

    if (dados != null) {
      streak = dados['sequencia_dias'] ?? 0;
    } else {
      errorMessage = 'Não foi possível carregar os dados.';
    }

    isLoading = false;
    notifyListeners(); // att a tela com os dados
  }
}
