import 'package:flutter/material.dart';
import '/api_service.dart';
import '../models/profile_model.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _api = ApiService();

  ProfileState _state = ProfileState();

  // Getters
  ProfileState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  UserProfile? get userProfile => _state.userProfile;
  List<ProfileMenuItem> get menuItems => _state.menuItems;

  String get nome => _state.userProfile?.nome ?? 'Carregando...';
  String get email => _state.userProfile?.email ?? '';
  String? get crm => _state.userProfile?.crm;
  bool get isMedico => _state.userProfile?.isMedico ?? false;

  Future<void> carregarDados(int userId, bool isMedico) async {
    _updateState(isLoading: true);

    try {
      Map<String, dynamic>? dados;

      if (isMedico) {
        dados = await _api.getMedico(userId);
        if (dados != null) {
          final profile = UserProfile.fromMedicoJson(dados);
          _updateState(
            userProfile: profile,
            menuItems: _buildMedicoMenuItems(userId),
          );
        }
      } else {
        dados = await _api.getPaciente(userId);
        if (dados != null) {
          final profile = UserProfile.fromPacienteJson(dados);
          _updateState(
            userProfile: profile,
            menuItems: _buildPacienteMenuItems(userId),
          );
        }
      }

      if (dados == null) {
        _updateState(
          errorMessage: 'Erro ao carregar dados do perfil',
          isLoading: false,
        );
      } else {
        _updateState(isLoading: false);
      }
    } catch (e) {
      _updateState(
        errorMessage: 'Erro de conexão. Tente novamente.',
        isLoading: false,
      );
    }
  }

  List<ProfileMenuItem> _buildMedicoMenuItems(int userId) {
    return [
      ProfileMenuItem(
        id: 'edit',
        label: 'Editar Dados',
        icon: Icons.person,
        route: '/edit_profile',
        arguments: {'userId': userId, 'isMedico': true},
      ),
      ProfileMenuItem(
        id: 'favorites',
        label: 'Favoritos',
        icon: Icons.favorite_border,
        route: '/favorites',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'settings',
        label: 'Configurações',
        icon: Icons.settings_sharp,
        route: '/settings',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'privacy',
        label: 'Políticas de Privacidade',
        icon: Icons.lock,
        route: '/privacy_policy',
      ),
      ProfileMenuItem(
        id: 'help',
        label: 'Ajuda',
        icon: Icons.help_outline_sharp,
        route: '/help',
      ),
      ProfileMenuItem(
        id: 'logout',
        label: 'Logout',
        icon: Icons.logout,
        route: '/login',
      ),
    ];
  }

  List<ProfileMenuItem> _buildPacienteMenuItems(int userId) {
    return [
      ProfileMenuItem(
        id: 'friends',
        label: 'Amigos',
        icon: Icons.person,
        route: '/friends',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'edit',
        label: 'Editar Dados',
        icon: Icons.person,
        route: '/edit_profile',
        arguments: {'userId': userId, 'isMedico': false},
      ),
      ProfileMenuItem(
        id: 'favorites',
        label: 'Favoritos',
        icon: Icons.favorite_border,
        route: '/favorites',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'history',
        label: 'Histórico de Exercícios',
        icon: Icons.history,
        route: '/exercise_history',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'settings',
        label: 'Configurações',
        icon: Icons.settings_sharp,
        route: '/settings',
        arguments: {'userId': userId},
      ),
      ProfileMenuItem(
        id: 'privacy',
        label: 'Políticas de Privacidade',
        icon: Icons.lock,
        route: '/privacy_policy',
      ),
      ProfileMenuItem(
        id: 'help',
        label: 'Ajuda',
        icon: Icons.help_outline_sharp,
        route: '/help',
      ),
      ProfileMenuItem(
        id: 'logout',
        label: 'Logout',
        icon: Icons.logout,
        route: '/login',
      ),
    ];
  }

  Future<void> atualizarPerfil(Map<String, dynamic> novosDados) async {
    _updateState(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (_state.userProfile != null) {
        final novoPerfil = UserProfile(
          id: _state.userProfile!.id,
          nome: novosDados['nome'] ?? _state.userProfile!.nome,
          email: novosDados['email'] ?? _state.userProfile!.email,
          userType: _state.userProfile!.userType,
          crm: novosDados['crm'] ?? _state.userProfile!.crm,
          dataDiagnostico: novosDados['dataDiagnostico'] ??
              _state.userProfile!.dataDiagnostico,
          fotoUrl: novosDados['fotoUrl'] ?? _state.userProfile!.fotoUrl,
          dataCadastro: _state.userProfile!.dataCadastro,
        );

        _updateState(userProfile: novoPerfil, isLoading: false);
      }
    } catch (e) {
      _updateState(
        errorMessage: 'Erro ao atualizar perfil',
        isLoading: false,
      );
    }
  }

  void _updateState({
    UserProfile? userProfile,
    bool? isLoading,
    String? errorMessage,
    List<ProfileMenuItem>? menuItems,
  }) {
    _state = _state.copyWith(
      userProfile: userProfile,
      isLoading: isLoading,
      errorMessage: errorMessage,
      menuItems: menuItems,
    );
    notifyListeners();
  }

  void limparErro() {
    if (_state.errorMessage != null) {
      _updateState(errorMessage: null);
    }
  }

  void fazerLogout() {
    // limpa os dados se necessário
    _updateState(
      userProfile: null,
      isLoading: false,
      menuItems: [],
    );
  }
}
