class MedicoModel {
  final int id;
  final String nome;
  final String crm;
  final String email;

  MedicoModel({
    required this.id,
    required this.nome,
    required this.crm,
    required this.email,
  });

  factory MedicoModel.fromJson(Map<String, dynamic> json) {
    return MedicoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      crm: json['crm'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'crm': crm,
      'email': email,
    };
  }
}

class PacienteListadoModel {
  final int id;
  final String nome;
  final DateTime? ultimaConsulta;
  final bool temExerciciosPendentes;

  PacienteListadoModel({
    required this.id,
    required this.nome,
    this.ultimaConsulta,
    this.temExerciciosPendentes = false,
  });

  factory PacienteListadoModel.fromJson(Map<String, dynamic> json) {
    return PacienteListadoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem Nome',
      ultimaConsulta: json['data_diagnostico'] != null
          ? DateTime.tryParse(json['data_diagnostico'])
          : null,
      temExerciciosPendentes: json['tem_exercicios_pendentes'] ?? false,
    );
  }

  String get ultimaConsultaFormatada {
    if (ultimaConsulta == null) return 'Nunca';
    final now = DateTime.now();
    final difference = now.difference(ultimaConsulta!);

    if (difference.inDays == 0) return 'Hoje';
    if (difference.inDays == 1) return 'Ontem';
    if (difference.inDays < 7) return '${difference.inDays} dias atrás';
    if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} semanas atrás';
    }
    return '${difference.inDays ~/ 30} meses atrás';
  }
}

class MedicoHomeState {
  MedicoModel? medico;
  List<PacienteListadoModel> pacientes = [];
  bool isLoading = true;
  String? errorMessage;

  MedicoHomeState({
    this.medico,
    this.pacientes = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  MedicoHomeState copyWith({
    MedicoModel? medico,
    List<PacienteListadoModel>? pacientes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MedicoHomeState(
      medico: medico ?? this.medico,
      pacientes: pacientes ?? this.pacientes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
