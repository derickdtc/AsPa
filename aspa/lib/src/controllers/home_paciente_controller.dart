import 'package:flutter/material.dart';
import '/api_service.dart';
import '../models/home_paciente_model.dart';

class HomeController extends ChangeNotifier {
  final ApiService _api = ApiService();

  PacienteHomeState _state = PacienteHomeState();

  // Getters
  PacienteHomeState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  PacienteModel? get paciente => _state.paciente;
  List<ExercicioPaciente> get exercicios => _state.exercicios;
  List<LembretePaciente> get lembretes => _state.lembretes;
  int get streak => _state.paciente?.sequenciaDias ?? 0;
  int get exerciciosParaHoje => _state.exerciciosParaHoje;
  int get lembretesParaHoje => _state.lembretesParaHoje;

  Future<void> carregarDadosPaciente(int userId) async {
    _updateState(isLoading: true);

    try {
      final dadosPaciente = await _api.getPaciente(userId);

      if (dadosPaciente != null) {
        final paciente = PacienteModel.fromJson(dadosPaciente);

        // TODO: Carregar exercícios e lembretes do paciente
        // final exerciciosData = await _api.getExerciciosPaciente(userId);
        // final exercicios = exerciciosData.map((e) => ExercicioPaciente.fromJson(e)).toList();
        //
        // final lembretesData = await _api.getLembretesPaciente(userId);
        // final lembretes = lembretesData.map((l) => LembretePaciente.fromJson(l)).toList();

        // Mock data para desenvolvimento
        final exerciciosMock = [
          ExercicioPaciente(
            id: 1,
            nome: 'Jardineiro',
            descricao: 'Exercício de coordenação motora',
            dataAtribuicao: DateTime.now(),
            concluido: false,
            dificuldade: 2,
          ),
        ];

        final lembretesMock = [
          LembretePaciente(
            id: 1,
            titulo: 'Tomar medicamento',
            descricao: 'Tomar remédio após o almoço',
            dataHora: DateTime.now().add(const Duration(hours: 1)),
            ativo: true,
          ),
        ];

        _updateState(
          paciente: paciente,
          exercicios: exerciciosMock,
          lembretes: lembretesMock,
          isLoading: false,
        );
      } else {
        _updateState(
          errorMessage: 'Não foi possível carregar os dados.',
          isLoading: false,
        );
      }
    } catch (e) {
      _updateState(
        errorMessage: 'Erro de conexão. Tente novamente.',
        isLoading: false,
      );
    }
  }

  Future<void> atualizarStreak(int novoStreak) async {
    if (_state.paciente != null) {
      final pacienteAtualizado = PacienteModel(
        id: _state.paciente!.id,
        nome: _state.paciente!.nome,
        email: _state.paciente!.email,
        sequenciaDias: novoStreak,
        dataDiagnostico: _state.paciente!.dataDiagnostico,
        dataCadastro: _state.paciente!.dataCadastro,
        idade: _state.paciente!.idade,
      );

      _updateState(paciente: pacienteAtualizado);

      // TODO: Atualizar streak na API
      // await _api.atualizarStreak(_state.paciente!.id, novoStreak);
    }
  }

  Future<void> marcarExercicioConcluido(int exercicioId) async {
    final exerciciosAtualizados = _state.exercicios.map((exercicio) {
      if (exercicio.id == exercicioId) {
        return ExercicioPaciente(
          id: exercicio.id,
          nome: exercicio.nome,
          descricao: exercicio.descricao,
          dataAtribuicao: exercicio.dataAtribuicao,
          concluido: true,
          dataConclusao: DateTime.now(),
          dificuldade: exercicio.dificuldade,
        );
      }
      return exercicio;
    }).toList();

    _updateState(exercicios: exerciciosAtualizados);

    // TODO: Atualizar exercício na API
    // await _api.marcarExercicioConcluido(exercicioId);
  }

  Future<void> adicionarLembrete(
      String titulo, String descricao, DateTime dataHora) async {
    final novoLembrete = LembretePaciente(
      id: _state.lembretes.length + 1,
      titulo: titulo,
      descricao: descricao,
      dataHora: dataHora,
      ativo: true,
    );

    _updateState(
      lembretes: [..._state.lembretes, novoLembrete],
    );

    // TODO: Adicionar lembrete na API
    // await _api.adicionarLembrete(_state.paciente!.id, titulo, descricao, dataHora);
  }

  void _updateState({
    PacienteModel? paciente,
    List<ExercicioPaciente>? exercicios,
    List<LembretePaciente>? lembretes,
    bool? isLoading,
    String? errorMessage,
  }) {
    _state = _state.copyWith(
      paciente: paciente,
      exercicios: exercicios,
      lembretes: lembretes,
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
    notifyListeners();
  }

  void limparErro() {
    if (_state.errorMessage != null) {
      _updateState(errorMessage: null);
    }
  }

  String get mensagemExercicios {
    final count = exerciciosParaHoje;
    if (count == 0) {
      return 'Você não tem exercícios para hoje!';
    } else if (count == 1) {
      return 'Você tem 1 exercício para hoje!';
    } else {
      return 'Você tem $count exercícios para hoje!';
    }
  }

  String get mensagemLembretes {
    final count = lembretesParaHoje;
    if (count == 0) {
      return 'Você não tem lembretes para hoje!';
    } else if (count == 1) {
      return 'Você tem 1 lembrete para hoje!';
    } else {
      return 'Você tem $count lembretes para hoje!';
    }
  }
}
