import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '/api_service.dart';

// Enum para tipar a seleção
enum UserType { paciente, medico }

class SignUpController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? errorMessage;

  UserType _userType = UserType.paciente;
  UserType get userType => _userType;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  void setUserType(UserType? type) {
    if (type != null) {
      _userType = type;
      notifyListeners(); // att a tela para mostrar/esconder campos
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners(); // att o texto do input de data
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
    required String crm,
  }) async {
    // validações
    if (senha != confirmarSenha) {
      errorMessage = 'As senhas não conferem.';
      notifyListeners();
      return;
    }

    if (_userType == UserType.paciente && _selectedDate == null) {
      errorMessage = 'Selecione a data do diagnóstico!';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    Map<String, dynamic>? resultado;

    // chamada da API baseada no tipo
    if (_userType == UserType.paciente) {
      // formatando a data para YYYY-MM-DD
      String dataParaAPI = _selectedDate!.toIso8601String().substring(0, 10);

      resultado = await _api.cadastrarPaciente(nome, email, senha, dataParaAPI);
    } else {
      resultado = await _api.cadastrarMedico(nome, email, senha, crm);
    }

    isLoading = false;
    notifyListeners();

    if (resultado != null) {
      if (_userType == UserType.paciente) {
        Modular.to
            .navigate('/home_paciente', arguments: resultado['id_usuario']);
      } else {
        Modular.to.navigate('/home_medico',
            arguments: {'id': resultado['id_usuario'], 'name': nome});
      }
    } else {
      errorMessage = 'Erro ao realizar cadastro. Verifique os dados.';
      notifyListeners();
    }
  }
}
