import 'package:flutter/material.dart';

class UserProfile {
  final int id;
  final String nome;
  final String email;
  final UserType userType;
  final String? crm;
  final DateTime? dataDiagnostico;
  final String? fotoUrl;
  final DateTime? dataCadastro;

  UserProfile({
    required this.id,
    required this.nome,
    required this.email,
    required this.userType,
    this.crm,
    this.dataDiagnostico,
    this.fotoUrl,
    this.dataCadastro,
  });

  factory UserProfile.fromMedicoJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      userType: UserType.medico,
      crm: json['crm'],
      fotoUrl: json['foto_url'],
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.tryParse(json['data_cadastro'])
          : null,
    );
  }

  factory UserProfile.fromPacienteJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      userType: UserType.paciente,
      dataDiagnostico: json['data_diagnostico'] != null
          ? DateTime.tryParse(json['data_diagnostico'])
          : null,
      fotoUrl: json['foto_url'],
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.tryParse(json['data_cadastro'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': userType == UserType.medico ? 'medico' : 'paciente',
      'crm': crm,
      'data_diagnostico': dataDiagnostico?.toIso8601String(),
      'foto_url': fotoUrl,
      'data_cadastro': dataCadastro?.toIso8601String(),
    };
  }

  bool get isMedico => userType == UserType.medico;
  bool get isPaciente => userType == UserType.paciente;

  String get displayTipo {
    return isMedico ? 'Médico' : 'Paciente';
  }

  String? get dataDiagnosticoFormatada {
    if (dataDiagnostico == null) return null;
    return '${dataDiagnostico!.day.toString().padLeft(2, '0')}/'
        '${dataDiagnostico!.month.toString().padLeft(2, '0')}/'
        '${dataDiagnostico!.year}';
  }
}

// Modelo para item do menu de perfil
class ProfileMenuItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;
  final Map<String, dynamic>? arguments;

  ProfileMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.arguments,
  });
}

// Enum para tipo de usuário (reutilizável)
enum UserType { paciente, medico }

// Estado do perfil
class ProfileState {
  UserProfile? userProfile;
  bool isLoading = true;
  String? errorMessage;
  List<ProfileMenuItem> menuItems = [];

  ProfileState({
    this.userProfile,
    this.isLoading = true,
    this.errorMessage,
    List<ProfileMenuItem>? menuItems,
  }) : menuItems = menuItems ?? [];

  ProfileState copyWith({
    UserProfile? userProfile,
    bool? isLoading,
    String? errorMessage,
    List<ProfileMenuItem>? menuItems,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      menuItems: menuItems ?? this.menuItems,
    );
  }
}
