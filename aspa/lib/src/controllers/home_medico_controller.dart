import 'package:flutter/material.dart';
import '/api_service.dart';
import '../models/home_medico_model.dart';

class HomeMedicoController extends ChangeNotifier {
  final ApiService _api = ApiService();

  MedicoHomeState _state = MedicoHomeState();

  // Getters
  MedicoHomeState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  MedicoModel? get medico => _state.medico;
  List<PacienteListadoModel> get pacientes => _state.pacientes;
  String get crm => _state.medico?.crm ?? 'Carregando...';

  Future<void> carregarDadosMedico(int userId) async {
    _updateState(isLoading: true);

    try {
      final dados = await _api.getMedico(userId);

      if (dados != null) {
        final medico = MedicoModel.fromJson(dados);
        _updateState(
          medico: medico,
          isLoading: false,
        );

        await carregarPacientes(userId);
      } else {
        _updateState(
          errorMessage: 'Erro ao carregar dados do médico',
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

  Future<void> carregarPacientes(int medicoId) async {
    try {
      // CHAMA A API
      final listaDePacientes = await _api.getPacientesDoMedico(medicoId);

      // converte a lista para o model
      final listaReal = listaDePacientes.map((item) {
        return PacienteListadoModel.fromJson(item);
      }).toList();

      // atualiza a tela com os dados reais agr
      _updateState(pacientes: listaReal);
    } catch (e) {
      // se der erro, deixa a lista vazia em vez de crashar
      _updateState(pacientes: []);
    }
  }

  Future<void> adicionarPaciente(String nomePaciente) async {
    final novoPaciente = PacienteListadoModel(
      id: pacientes.length + 1,
      nome: nomePaciente,
      ultimaConsulta: DateTime.now(),
      temExerciciosPendentes: false,
    );

    _updateState(
      pacientes: [...pacientes, novoPaciente],
    );
  }

  void navegarParaPerfilPaciente(
      PacienteListadoModel paciente, BuildContext context) {
    // TODO: Implementar navegação para tela do paciente corretamente
    // Modular.to.pushNamed('/paciente/${paciente.id}');
  }

  void _updateState({
    MedicoModel? medico,
    List<PacienteListadoModel>? pacientes,
    bool? isLoading,
    String? errorMessage,
  }) {
    _state = _state.copyWith(
      medico: medico,
      pacientes: pacientes,
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

  void atualizarNomeMedico(String novoNome) {
    if (_state.medico != null) {
      final medicoAtualizado = MedicoModel(
        id: _state.medico!.id,
        nome: novoNome,
        crm: _state.medico!.crm,
        email: _state.medico!.email,
      );
      _updateState(medico: medicoAtualizado);
    }
  }
}
