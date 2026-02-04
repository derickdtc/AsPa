import 'package:aspa/src/models/profile_model.dart';

class EditProfileFormData {
  String nome;
  String telefone;
  String email;
  DateTime? dataNascimento;
  String? fotoUrl;
  String? crm;
  DateTime? dataDiagnostico;
  UserType userType;

  EditProfileFormData({
    required this.nome,
    required this.telefone,
    required this.email,
    this.dataNascimento,
    this.fotoUrl,
    this.crm,
    this.dataDiagnostico,
    required this.userType,
  });

  factory EditProfileFormData.fromUserProfile(UserProfile userProfile) {
    return EditProfileFormData(
      nome: userProfile.nome,
      telefone: '', // Precisa ser obtido da API
      email: userProfile.email,
      dataNascimento: null, // Precisa ser obtido da API
      fotoUrl: userProfile.fotoUrl,
      crm: userProfile.crm,
      dataDiagnostico: userProfile.dataDiagnostico,
      userType: userProfile.userType,
    );
  }

  // Cópia do objeto com valores atualizados
  EditProfileFormData copyWith({
    String? nome,
    String? telefone,
    String? email,
    DateTime? dataNascimento,
    String? fotoUrl,
    String? crm,
    DateTime? dataDiagnostico,
    UserType? userType,
  }) {
    return EditProfileFormData(
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      crm: crm ?? this.crm,
      dataDiagnostico: dataDiagnostico ?? this.dataDiagnostico,
      userType: userType ?? this.userType,
    );
  }

  // Validações
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

    if (telefone.isNotEmpty && !_isValidPhone(telefone)) {
      errors.add('Telefone inválido');
    }

    if (userType == UserType.medico && crm != null && crm!.isEmpty) {
      errors.add('CRM é obrigatório para médicos');
    }

    if (userType == UserType.paciente && dataDiagnostico != null) {
      if (dataDiagnostico!.isAfter(DateTime.now())) {
        errors.add('Data de diagnóstico não pode ser no futuro');
      }
    }

    if (dataNascimento != null) {
      if (dataNascimento!.isAfter(DateTime.now())) {
        errors.add('Data de nascimento não pode ser no futuro');
      }
      final idade = DateTime.now().difference(dataNascimento!).inDays ~/ 365;
      if (idade > 120) {
        errors.add('Data de nascimento inválida');
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

  bool _isValidPhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanedPhone.length >= 10 && cleanedPhone.length <= 11;
  }

  String? get dataNascimentoFormatada {
    if (dataNascimento == null) return null;
    return '${dataNascimento!.day.toString().padLeft(2, '0')}/'
        '${dataNascimento!.month.toString().padLeft(2, '0')}/'
        '${dataNascimento!.year}';
  }

  String? get dataDiagnosticoFormatada {
    if (dataDiagnostico == null) return null;
    return '${dataDiagnostico!.day.toString().padLeft(2, '0')}/'
        '${dataDiagnostico!.month.toString().padLeft(2, '0')}/'
        '${dataDiagnostico!.year}';
  }

  // Converte para map para API
  Map<String, dynamic> toApiMap() {
    final baseData = {
      'nome': nome,
      'email': email,
      'telefone': telefone,
    };

    if (dataNascimento != null) {
      baseData['data_nascimento'] =
          '${dataNascimento!.year}-${dataNascimento!.month.toString().padLeft(2, '0')}-${dataNascimento!.day.toString().padLeft(2, '0')}';
    }

    if (userType == UserType.medico && crm != null) {
      baseData['crm'] = crm!;
    }

    if (userType == UserType.paciente && dataDiagnostico != null) {
      baseData['data_diagnostico'] =
          '${dataDiagnostico!.year}-${dataDiagnostico!.month.toString().padLeft(2, '0')}-${dataDiagnostico!.day.toString().padLeft(2, '0')}';
    }

    if (fotoUrl != null) {
      baseData['foto_url'] = fotoUrl!;
    }

    return baseData;
  }
}

// Resultado da validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get firstError => errors.isNotEmpty ? errors.first : '';
}

// Estado da edição de perfil
class EditProfileState {
  EditProfileFormData formData;
  bool isLoading;
  bool isSaving;
  String? errorMessage;
  String? successMessage;
  String? selectedImagePath;

  EditProfileState({
    required this.formData,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.selectedImagePath,
  });

  EditProfileState copyWith({
    EditProfileFormData? formData,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    String? selectedImagePath,
  }) {
    return EditProfileState(
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
    );
  }
}
