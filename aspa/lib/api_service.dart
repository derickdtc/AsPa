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
    final url = Uri.parse('$baseUrl/login'); // Chama a nova rota

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
        // Login Sucesso: Retorna os dados do usuário (ID, Nome)
        return jsonDecode(response.body);
      } else {
        // Login Falhou (401)
        print("Erro Login: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro de Conexão: $e");
      return null;
    }
  }

  Future<bool> cadastrarPaciente(
      String nome, String email, String senha) async {
    final url = Uri.parse('$baseUrl/pacientes/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "senha": senha,
          "data_diagnostico":
              DateTime.now().toIso8601String().substring(0, 10) // Data de hoje
        }),
      );

      if (response.statusCode == 200) {
        print("Sucesso: ${response.body}");
        return true; // Deu certo!
      } else {
        print("Erro API: ${response.body}");
        return false; // Deu erro no back (ex: email duplicado)
      }
    } catch (e) {
      print("Erro de Conexão: $e");
      return false; // Servidor desligado ou IP errado
    }
  }

  // Adicione dentro da class ApiService
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
