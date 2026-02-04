// Modelo para dados do formulário de cadastro
class SignUpFormData {
  String nome;
  String email;
  String senha;
  String confirmarSenha;
  UserType userType;
  String? crm;
  DateTime? dataDiagnostico;
  DateTime? dataNascimento;
  String? foto;

  SignUpFormData({
    required this.nome,
    required this.email,
    required this.senha,
    required this.confirmarSenha,
    required this.userType,
    this.crm,
    this.dataDiagnostico,
    this.dataNascimento,
    this.foto,
  });

  // Builder (Cópia dos valores)
  SignUpFormData copyWith({
    String? nome,
    String? email,
    String? senha,
    String? confirmarSenha,
    UserType? userType,
    String? crm,
    DateTime? dataDiagnostico,
    DateTime? dataNascimento,
    String? foto,
  }) {
    return SignUpFormData(
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      confirmarSenha: confirmarSenha ?? this.confirmarSenha,
      userType: userType ?? this.userType,
      crm: crm ?? this.crm,
      dataDiagnostico: dataDiagnostico ?? this.dataDiagnostico,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      foto: foto ?? this.foto,
    );
  }

  ValidationResult validate() {
    final errors = <String>[];

    if (nome.isEmpty) {
      errors.add('Nome é obrigatório');
    }

    if (email.isEmpty) {
      errors.add('E-mail é obrigatório');
    } else if (!_isValidEmail(email)) {
      errors.add('E-mail inválido');
    }

    if (senha.isEmpty) {
      errors.add('Senha é obrigatória');
    } else if (senha.length < 6) {
      errors.add('Senha deve ter pelo menos 6 caracteres');
    }

    if (confirmarSenha.isEmpty) {
      errors.add('Confirmação de senha é obrigatória');
    } else if (senha != confirmarSenha) {
      errors.add('As senhas não conferem');
    }

    if (userType == UserType.medico) {
      if (crm == null || crm!.isEmpty) {
        errors.add('CRM é obrigatório para médicos');
      }
    }

    if (userType == UserType.paciente) {
      if (dataDiagnostico == null) {
        errors.add('Data de diagnóstico é obrigatória para pacientes');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // convertendo para map para API
  Map<String, dynamic> toApiMap() {
    final baseData = {
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo': userType == UserType.paciente ? 'paciente' : 'medico',
      if (foto != null) 'foto': foto,
    };

    if (dataNascimento != null) {
      baseData['data_nascimento'] =
          '${dataNascimento!.year}-${dataNascimento!.month.toString().padLeft(2, '0')}-${dataNascimento!.day.toString().padLeft(2, '0')}';
    }

    if (userType == UserType.paciente && dataDiagnostico != null) {
      baseData['data_diagnostico'] =
          '${dataDiagnostico!.year}-${dataDiagnostico!.month.toString().padLeft(2, '0')}-${dataDiagnostico!.day.toString().padLeft(2, '0')}';
    }

    if (userType == UserType.medico && crm != null) {
      baseData['crm'] = crm!;
    }

    return baseData;
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get firstError => errors.isNotEmpty ? errors.first : '';
}

enum UserType { paciente, medico }

// model para resposta da API de cadastro
class SignUpResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  SignUpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

// model para usuário cadastrado
class RegisteredUser {
  final int id;
  final String nome;
  final String email;
  final UserType tipo;
  final String? crm;
  final DateTime? dataDiagnostico;

  RegisteredUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.crm,
    this.dataDiagnostico,
  });

  factory RegisteredUser.fromApiResponse(Map<String, dynamic> data) {
    return RegisteredUser(
      id: data['id_usuario'] as int,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      tipo: (data['tipo'] == 'medico' || data['tipo'] == 'médico')
          ? UserType.medico
          : UserType.paciente,
      crm: data['crm'],
      dataDiagnostico: data['data_diagnostico'] != null
          ? DateTime.tryParse(data['data_diagnostico'])
          : null,
    );
  }

  bool get isMedico => tipo == UserType.medico;
  bool get isPaciente => tipo == UserType.paciente;
}
