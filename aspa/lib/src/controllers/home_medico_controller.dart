import 'package:flutter/material.dart';
import '/api_service.dart';

class HomeMedicoController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String crm = '';
  // Futuramente: List<Paciente> pacientes = [];

  Future<void> carregarDadosMedico(int userId) async {
    isLoading = true;
    notifyListeners(); // Avisa a view que começou a carregar

    final dados = await _api.getMedico(userId);

    if (dados != null) {
      crm = dados['crm'] ?? 'Não informado';
    } else {
      crm = 'Erro ao carregar';
    }

    isLoading = false;
    notifyListeners(); // Avisa a view que terminou
  }
}
