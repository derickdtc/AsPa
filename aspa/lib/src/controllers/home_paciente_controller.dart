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
  int get streak => paciente?.sequenciaDias ?? 0;
  List<ExercicioPaciente> get exerciciosPendentes =>
      exercicios.where((e) => !e.concluido).toList();
  List<ExercicioPaciente> get exerciciosFeitos =>
      exercicios.where((e) => e.concluido).toList();
  String get mensagemExercicios {
    if (exercicios.isEmpty) {
      return 'Nenhum exercício para hoje';
    }
    final exerciciosHoje = exercicios.where((e) => !e.concluido).length;
    return '$exerciciosHoje exercício${exerciciosHoje != 1 ? 's' : ''} para hoje';
  }

  String get mensagemLembretes {
    if (lembretes.isEmpty) {
      return 'Nenhum lembrete para hoje';
    }
    final lembretesHoje = lembretes.where((l) => l.ativo).length;
    return '$lembretesHoje lembrete${lembretesHoje != 1 ? 's' : ''} ativo${lembretesHoje != 1 ? 's' : ''}';
  }

  Future<void> carregarDadosPaciente(int userId) async {
    _updateState(isLoading: true);

    try {
      final dadosPaciente = await _api.getPaciente(userId);

      if (dadosPaciente != null) {
        final paciente = PacienteModel.fromJson(dadosPaciente);

        final exerciciosData = await _api.getExerciciosPaciente(userId);
        final exercicios =
            exerciciosData.map((e) => ExercicioPaciente.fromJson(e)).toList();

        final lembretesData = await _api.getLembretesPaciente(userId);
        final lembretes =
            lembretesData.map((l) => LembretePaciente.fromJson(l)).toList();

        _updateState(
          paciente: paciente,
          exercicios: exercicios,
          lembretes: lembretes,
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
        errorMessage: 'Erro de conexão.',
        isLoading: false,
      );
    }
  }

  Future<void> excluirLembrete(int idLembrete) async {
    final sucesso = await _api.deleteLembrete(idLembrete);

    if (sucesso) {
      final novaLista = lembretes.where((l) => l.id != idLembrete).toList();
      _updateState(lembretes: novaLista);
    } else {
      _updateState(errorMessage: "Erro ao excluir lembrete.");
    }
  }

  Future<void> marcarExercicioConcluido(
      int idPrescricao, int idExercicio) async {
    
    final exercicioFeitoHoje = exerciciosFeitos.isNotEmpty;
    
    final sucesso =
        await _api.marcarExercicioComoFeito(idPrescricao, idExercicio);

    if (sucesso) {
      final index = exercicios.indexWhere((e) =>
          e.idPrescricao == idPrescricao && e.idExercicio == idExercicio);

      if (index != -1) {
        final exAntigo = exercicios[index];
        final exAtualizado = ExercicioPaciente(
            idPrescricao: exAntigo.idPrescricao,
            idExercicio: exAntigo.idExercicio,
            nome: exAntigo.nome,
            descricao: exAntigo.descricao,
            dataAtribuicao: exAntigo.dataAtribuicao,
            concluido: true,
            dificuldade: exAntigo.dificuldade);

        final novaLista = List<ExercicioPaciente>.from(exercicios);
        novaLista[index] = exAtualizado;

        _updateState(exercicios: novaLista);

        if(!exercicioFeitoHoje){
          await aumentarStreak();
        }
      }
    } else {
      _updateState(errorMessage: "Erro ao concluir exercício");
    }
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

  Future<void> aumentarStreak() async {
    final pacienteAtual = paciente;
    if (pacienteAtual == null) return;

    final novaStreak = pacienteAtual.sequenciaDias + 1;

    final response = await _api.updatePaciente(
      pacienteAtual.id,
      sequenciaDias: novaStreak,
    );

    if (response != null) {
      final pacienteAtualizado = PacienteModel.fromJson(response);
      _updateState(paciente: pacienteAtualizado);
    } else {
      _updateState(errorMessage: "Erro ao salvar streak");
    }
  }
}
