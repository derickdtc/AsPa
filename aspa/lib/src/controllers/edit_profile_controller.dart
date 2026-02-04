import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/api_service.dart';
import '../models/edit_profile_model.dart';
import '../models/profile_model.dart';

class EditProfileController extends ChangeNotifier {
  final ApiService _api = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  EditProfileState _state = EditProfileState(
    formData: EditProfileFormData(
      nome: '',
      telefone: '',
      email: '',
      userType: UserType.paciente,
    ),
  );

  // Getters
  EditProfileState get state => _state;
  bool get isLoading => _state.isLoading;
  bool get isSaving => _state.isSaving;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;
  EditProfileFormData get formData => _state.formData;

  Future<void> carregarDadosUsuario(int userId, bool isMedico) async {
    _updateState(isLoading: true);

    try {
      Map<String, dynamic>? dados;

      if (isMedico) {
        dados = await _api.getMedico(userId);
        if (dados != null) {
          final userProfile = UserProfile.fromMedicoJson(dados);
          _updateState(
            formData: EditProfileFormData.fromUserProfile(userProfile),
            isLoading: false,
          );
        }
      } else {
        dados = await _api.getPaciente(userId);
        if (dados != null) {
          final userProfile = UserProfile.fromPacienteJson(dados);
          _updateState(
            formData: EditProfileFormData.fromUserProfile(userProfile),
            isLoading: false,
          );
        }
      }

      if (dados == null) {
        _updateState(
          errorMessage: 'Erro ao carregar dados do usuário',
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

  // Setters para campos do formulário
  void setNome(String nome) {
    _updateState(
      formData: _state.formData.copyWith(nome: nome),
    );
  }

  void setTelefone(String telefone) {
    _updateState(
      formData: _state.formData.copyWith(telefone: telefone),
    );
  }

  void setEmail(String email) {
    _updateState(
      formData: _state.formData.copyWith(email: email),
    );
  }

  void setCrm(String crm) {
    _updateState(
      formData: _state.formData.copyWith(crm: crm),
    );
  }

  void setDataNascimento(DateTime dataNascimento) {
    _updateState(
      formData: _state.formData.copyWith(dataNascimento: dataNascimento),
    );
  }

  void setDataDiagnostico(DateTime dataDiagnostico) {
    _updateState(
      formData: _state.formData.copyWith(dataDiagnostico: dataDiagnostico),
    );
  }

  Future<void> selecionarFoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _updateState(selectedImagePath: pickedFile.path);

        // TODO: Upload da imagem para o servidor
        // final fotoUrl = await _api.uploadFoto(File(pickedFile.path));
        // if (fotoUrl != null) {
        //   _updateState(
        //     formData: _state.formData.copyWith(fotoUrl: fotoUrl),
        //   );
        // }
      }
    } catch (e) {
      _updateState(
        errorMessage: 'Erro ao selecionar imagem',
      );
    }
  }

  Future<void> salvarPerfil(int userId) async {
    // Validação
    final validation = _state.formData.validate();
    if (!validation.isValid) {
      _updateState(errorMessage: validation.firstError);
      return;
    }

    _updateState(isSaving: true, errorMessage: null, successMessage: null);

    try {
      // TODO: Implementar API para atualizar perfil
      // final resultado = await _api.atualizarPerfil(userId, _state.formData.toApiMap());

      // Simulando uma chamada de API
      await Future.delayed(const Duration(seconds: 1));

      // Mock de sucesso
      _updateState(
        isSaving: false,
        successMessage: 'Perfil atualizado com sucesso!',
      );

      // Limpar mensagem de sucesso após 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        _updateState(successMessage: null);
      });
    } catch (e) {
      _updateState(
        isSaving: false,
        errorMessage: 'Erro ao salvar perfil. Tente novamente.',
      );
    }
  }

  Future<void> selecionarDataNascimento(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _state.formData.dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (dataSelecionada != null) {
      setDataNascimento(dataSelecionada);
    }
  }

  Future<void> selecionarDataDiagnostico(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _state.formData.dataDiagnostico ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dataSelecionada != null) {
      setDataDiagnostico(dataSelecionada);
    }
  }

  void _updateState({
    EditProfileFormData? formData,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    String? selectedImagePath,
  }) {
    _state = _state.copyWith(
      formData: formData,
      isLoading: isLoading,
      isSaving: isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedImagePath: selectedImagePath,
    );
    notifyListeners();
  }

  void limparMensagens() {
    _updateState(errorMessage: null, successMessage: null);
  }
}
