import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '/api_service.dart';
import '../models/signup_model.dart';

class SignUpController extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Estado
  bool _isLoading = false;
  String? _errorMessage;
  SignUpFormData _formData = SignUpFormData(
    nome: '',
    email: '',
    senha: '',
    confirmarSenha: '',
    userType: UserType.paciente,
  );

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SignUpFormData get formData => _formData;
  UserType get userType => _formData.userType;
  DateTime? get selectedDate => _formData.dataDiagnostico;

  // Setters
  void setUserType(UserType type) {
    _formData = _formData.copyWith(userType: type);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _formData = _formData.copyWith(dataDiagnostico: date);
    notifyListeners();
  }

  void setNome(String nome) {
    _formData = _formData.copyWith(nome: nome);
  }

  void setEmail(String email) {
    _formData = _formData.copyWith(email: email);
  }

  void setSenha(String senha) {
    _formData = _formData.copyWith(senha: senha);
  }

  void setConfirmarSenha(String confirmarSenha) {
    _formData = _formData.copyWith(confirmarSenha: confirmarSenha);
  }

  void setCrm(String crm) {
    _formData = _formData.copyWith(crm: crm);
  }

  ValidationResult validateForm() {
    return _formData.validate();
  }

  Future<void> cadastrar() async {
    final validation = validateForm();
    if (!validation.isValid) {
      _errorMessage = validation.firstError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic>? resultado;

      if (_formData.userType == UserType.paciente) {
        resultado = await _api.cadastrarPaciente(
          _formData.nome,
          _formData.email,
          _formData.senha,
          '${_formData.dataDiagnostico!.year}-${_formData.dataDiagnostico!.month.toString().padLeft(2, '0')}-${_formData.dataDiagnostico!.day.toString().padLeft(2, '0')}',
        );
      } else {
        resultado = await _api.cadastrarMedico(
          _formData.nome,
          _formData.email,
          _formData.senha,
          _formData.crm!,
        );
      }

      _isLoading = false;

      if (resultado != null) {
        final user = RegisteredUser.fromApiResponse(resultado);

        if (_formData.userType == UserType.paciente) {
          Modular.to.navigate('/home_paciente', arguments: user.id);
        } else {
          Modular.to.navigate('/home_medico', arguments: {
            'id': user.id,
            'name': user.nome,
          });
        }
      } else {
        _errorMessage = 'Erro ao realizar cadastro. Verifique os dados.';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro de conexão. Tente novamente.';
      notifyListeners();
    }
  }

  void resetForm() {
    _formData = SignUpFormData(
      nome: '',
      email: '',
      senha: '',
      confirmarSenha: '',
      userType: UserType.paciente,
    );
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
