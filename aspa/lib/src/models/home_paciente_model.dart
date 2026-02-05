class PacienteModel {
  final int id;
  final String nome;
  final String email;
  final int sequenciaDias;
  final DateTime? dataDiagnostico;
  final DateTime? dataCadastro;
  final int? idade;

  PacienteModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.sequenciaDias,
    this.dataDiagnostico,
    this.dataCadastro,
    this.idade,
  });

  factory PacienteModel.fromJson(Map<String, dynamic> json) {
    return PacienteModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      sequenciaDias: json['sequencia_dias'] ?? 0,
      dataDiagnostico: json['data_diagnostico'] != null
          ? DateTime.tryParse(json['data_diagnostico'])
          : null,
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.tryParse(json['data_cadastro'])
          : null,
      idade: json['idade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'sequencia_dias': sequenciaDias,
      'data_diagnostico': dataDiagnostico?.toIso8601String(),
      'data_cadastro': dataCadastro?.toIso8601String(),
      'idade': idade,
    };
  }

  String get streakMessage {
    if (sequenciaDias == 0) {
      return 'Comece sua jornada hoje!';
    } else if (sequenciaDias == 1) {
      return 'Você completou 1 dia seguido!';
    } else {
      return 'Você completou $sequenciaDias dias seguidos!';
    }
  }
}

class ExercicioPaciente {
  final int id;
  final String nome;
  final String descricao;
  final DateTime dataAtribuicao;
  final bool concluido;
  final DateTime? dataConclusao;
  final int dificuldade;

  ExercicioPaciente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dataAtribuicao,
    this.concluido = false,
    this.dataConclusao,
    this.dificuldade = 1,
  });

  factory ExercicioPaciente.fromJson(Map<String, dynamic> json) {
    return ExercicioPaciente(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      dataAtribuicao: json['data_atribuicao'] != null
          ? DateTime.tryParse(json['data_atribuicao']) ?? DateTime.now()
          : DateTime.now(),
      concluido: json['concluido'] ?? false,
      dataConclusao: json['data_conclusao'] != null
          ? DateTime.tryParse(json['data_conclusao'])
          : null,
      dificuldade: json['dificuldade'] ?? 1,
    );
  }
}

class LembretePaciente {
  final int id;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final bool ativo;
  final bool recorrente;

  LembretePaciente({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    this.ativo = true,
    this.recorrente = false,
  });

  factory LembretePaciente.fromJson(Map<String, dynamic> json) {
    return LembretePaciente(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      dataHora: json['data_hora'] != null
          ? DateTime.tryParse(json['data_hora']) ?? DateTime.now()
          : DateTime.now(),
      ativo: json['ativo'] ?? true,
      recorrente: json['recorrente'] ?? false,
    );
  }
}

class PacienteHomeState {
  PacienteModel? paciente;
  List<ExercicioPaciente> exercicios = [];
  List<LembretePaciente> lembretes = [];
  bool isLoading = true;
  String? errorMessage;

  PacienteHomeState({
    this.paciente,
    this.exercicios = const [],
    this.lembretes = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  PacienteHomeState copyWith({
    PacienteModel? paciente,
    List<ExercicioPaciente>? exercicios,
    List<LembretePaciente>? lembretes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PacienteHomeState(
      paciente: paciente ?? this.paciente,
      exercicios: exercicios ?? this.exercicios,
      lembretes: lembretes ?? this.lembretes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  int get exerciciosParaHoje {
    final hoje = DateTime.now();
    return exercicios.where((e) {
      final dataEx = e.dataAtribuicao;
      return !e.concluido &&
          dataEx.year == hoje.year &&
          dataEx.month == hoje.month &&
          dataEx.day == hoje.day;
    }).length;
  }

  int get lembretesParaHoje {
    final hoje = DateTime.now();
    return lembretes.where((l) {
      final dataLembrete = l.dataHora;
      return l.ativo &&
          dataLembrete.year == hoje.year &&
          dataLembrete.month == hoje.month &&
          dataLembrete.day == hoje.day;
    }).length;
  }
}
