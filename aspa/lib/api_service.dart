import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ATENÇÃO AQUI:
  // se usar Emulador Android use '10.0.2.2'
  // se usar celular use o IP do PC (ex: '192.168.1.15')
  // se usar iOS emulador use '127.0.0.1'
  // se usar Edge/Chrome use http://127.0.0.1:8000
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>?> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/login'); // chamando a nova rota

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      if (response.statusCode == 200) {
        // Se deu bom: retorna os dados do usuário (ID, nome)
        return jsonDecode(response.body);
      } else {
        // Se deu ruim: (401)
        print("Erro no login: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> cadastrarPaciente(
      String nome, String email, String senha, String dataDiagnostico) async {
    final url = Uri.parse('$baseUrl/pacientes/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "senha": senha,
          "data_diagnostico": dataDiagnostico
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> cadastrarMedico(
      String nome, String email, String senha, String crm) async {
    final url = Uri.parse('$baseUrl/medicos/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "senha": senha,
          "registro_profissional": crm,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erro de API: ${response.body}");
        return null; // Deu ruim
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return null; // Server desligado ou IP errado
    }
  }

  Future<Map<String, dynamic>?> getMedico(int id) async {
    final url = Uri.parse('$baseUrl/medicos/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Erro ao buscar médico: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPaciente(int id) async {
    final url = Uri.parse('$baseUrl/pacientes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Erro ao buscar paciente: $e");
      return null;
    }
  }
}
