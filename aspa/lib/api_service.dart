import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ATENÇÃO AQUI:
  // se usar Emulador Android use '10.0.2.2'
  // se usar celular use o IP do PC (ex: '192.168.1.15')
  // se usar iOS emulador use '127.0.0.1'
  // se usar Edge/Chrome use http://127.0.0.1:8000
  static const String baseUrl = "http://127.0.0.1:8000";

  // static const String baseUrl = "http://192.168.3.126:8000";

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
        // print("Erro no login: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> cadastrarPaciente(
      String nome, String email, String senha, String dataDiagnostico,
      {String? dataNascimento, String? foto}) async {
    final url = Uri.parse('$baseUrl/pacientes/');

    final Map<String, dynamic> body = {
      "nome": nome,
      "email": email,
      "senha": senha,
      "data_diagnostico": dataDiagnostico,
    };

    if (dataNascimento != null) body["data_nascimento"] = dataNascimento;
    if (foto != null) body["foto"] = foto;

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
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
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePaciente(int id,
      {String? nome,
      String? email,
      String? senha,
      String? dataDiagnostico,
      int? sequenciaDias}) async {
    final url = Uri.parse('$baseUrl/pacientes/$id');

    final Map<String, dynamic> corpo = {};

    if (nome != null) corpo["nome"] = nome;
    if (email != null) corpo["email"] = email;
    if (senha != null) corpo["senha"] = senha;
    if (dataDiagnostico != null) {
      corpo["data_diagnostico"] = dataDiagnostico;
    }
    if (sequenciaDias != null) {
      corpo["sequencia_dias"] = sequenciaDias;
    }

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deletePaciente(int id) async {
    final url = Uri.parse('$baseUrl/pacientes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return false;
    }
  }

  Future<List<dynamic>> getHistoricoChat(int meuId, int amigoId) async {
    final url = Uri.parse('$baseUrl/chat/$amigoId?user_atual_id=$meuId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // retornando lista de msgs antigas
      }
      return [];
    } catch (e) {
      return [];
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
        // print("Erro de API: ${response.body}");
        return null; // Deu ruim
      }
    } catch (e) {
      // print("Erro de conexão: $e");
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
      // print("Erro ao buscar médico: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMedico(int id,
      {String? nome, String? email, String? senha, String? crm}) async {
    final url = Uri.parse('$baseUrl/medicos/$id');

    final Map<String, dynamic> corpo = {};

    if (nome != null) corpo["nome"] = nome;
    if (email != null) corpo["email"] = email;
    if (senha != null) corpo["senha"] = senha;
    if (crm != null) {
      corpo["crm"] = crm;
    }

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deleteMedico(int id) async {
    final url = Uri.parse('$baseUrl/medicos/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> cadastrarSessao(
      int idPacienteFk,
      String dataHora,
      double duracaoRealizada,
      String dificuldadeInfo,
      String comentarioPaciente
    ) async {
    final url = Uri.parse('$baseUrl/sessoes/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {
              "id_paciente_fk": idPacienteFk,
              "data_hora": dataHora, 
              "duracao_realizada": duracaoRealizada,
              "dificuldade_info": dificuldadeInfo,
              "comentario_paciente": comentarioPaciente
            }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSessao(int id) async {
    final url = Uri.parse('$baseUrl/sessoes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateSessao(int id,
      {String? dataHora,
      double? duracaoRealizada,
      String? dificuldadeInfo,
      String? comentarioPaciente}) async {
    final url = Uri.parse('$baseUrl/sessoes/$id');

    final Map<String, dynamic> corpo = {};

    if (dataHora != null) corpo["data_hora"] = dataHora;
    if (duracaoRealizada != null) corpo["duracao_realizada"] = duracaoRealizada;
    if (dificuldadeInfo != null) corpo["dificuldade_info"] = dificuldadeInfo;
    if (comentarioPaciente != null) {
      corpo["comentario_paciente"] = comentarioPaciente;
    }

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deleteSessao(int id) async {
    final url = Uri.parse('$baseUrl/sessoes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  // busca usuários para adicionar (parte de amizade)
  Future<List<dynamic>> buscarUsuarios(String termo, int meuId) async {
    final url =
        Uri.parse('$baseUrl/usuarios/buscar/$termo?user_id_logado=$meuId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> solicitarAmizade(int meuId, int idAmigo) async {
    final url = Uri.parse(
        '$baseUrl/amizade/solicitar?solicitante_id=$meuId&recebedor_id=$idAmigo');
    try {
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> cadastrarPrescricao(
    int idPacienteFk,
    String dataAtualizacao,
    String observacoesGerais
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {
              "id_paciente_fk": idPacienteFk,
              "data_atualizacao": dataAtualizacao,
              "observacoes_gerais": observacoesGerais,
            }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPrescricao(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePrescricao(int id,
      {
        int? idPacienteFk,
        String? dataAtualizacao,
        String? observacoesGerais
      }) async {
    final url = Uri.parse('$baseUrl/prescricoes/$id');

    final Map<String, dynamic> corpo = {};

    if (idPacienteFk != null) corpo["id_paciente_fk"] = idPacienteFk;
    if (dataAtualizacao != null) corpo["data_atualizacao"] = dataAtualizacao;
    if (observacoesGerais != null) corpo["observacoes_gerais"] = observacoesGerais;

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deletePrescricao(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

    } catch (e) {
      return false;
    }
  }


  Future<List<dynamic>> getPedidosPendentes(int meuId) async {
    final url = Uri.parse('$baseUrl/amizade/pendentes/$meuId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> responderAmizade(int idAmizade, bool aceitar) async {
    final url =
        Uri.parse('$baseUrl/amizade/responder/$idAmizade?aceitar=$aceitar');
    try {
      final response = await http.put(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> cadastrarLembrete(
    int idPrescricaoFk,
    String horario,
    String nomeMedicamento,
    double doseDiaria,
    String tipo,
    String status
  ) async {
    final url = Uri.parse('$baseUrl/lembretes/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {
              "id_prescricao_fk": idPrescricaoFk,
              "horario": horario,
              "nome_medicamento": nomeMedicamento,
              "dose_diaria": doseDiaria,
              "tipo": tipo,
              "status": status
            }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLembrete(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/lembretes/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateLembrete(int id,
      {
        int? idPrescricaoFk,
        String? horario,
        String? nomeMedicamento,
        double? doseDiaria,
        String? tipo,
        String? status
      }) async {
    final url = Uri.parse('$baseUrl/lembretes/$id');

    final Map<String, dynamic> corpo = {};

    if (idPrescricaoFk != null) corpo["id_prescricao_fk"] = idPrescricaoFk;
    if (horario != null) corpo["horario"] = horario;    
    if (nomeMedicamento != null) corpo["nome_medicamento"] = nomeMedicamento;
    if (doseDiaria != null) corpo["dose_diaria"] = doseDiaria;
    if (tipo != null) corpo["tipo"] = tipo;
    if (status != null) corpo["status"] = status;    

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deleteLembrete(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/lembretes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

    } catch (e) {
      return false;
    }
  }


  Future<List<dynamic>> getMeusAmigos(int meuId) async {
    final url = Uri.parse('$baseUrl/amizade/meus_amigos/$meuId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> cadastrarPrescricaoExercicio(
    int idPrescricaoFk,
    int idExercicioFk,
    int repeticoes,
    int duracaoMinutos,
    int frequenciaSemanal,
    String observacoes
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/$idPrescricaoFk/exercicios');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {
              "id_prescricao_fk": idPrescricaoFk,
              "id_exercicio_fk": idExercicioFk,
              "repeticoes": repeticoes,
              "duracao_minutos": duracaoMinutos,
              "frequencia_semanal": frequenciaSemanal,
              "observacoes": observacoes
            }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPrescricaoExercicio(
    int idPrescricao, int idExercicio
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/$idPrescricao/exercicios/$idExercicio');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePrescricaoExercicio(int idPrescricao, int idExercicio,
      {
        int? repeticoes,
        int? duracaoMinutos,
        int? frequenciaSemanal,
        String? observacoes
      }) async {
    final url = Uri.parse('$baseUrl/prescricoes/$idPrescricao/exercicios/$idExercicio');

    final Map<String, dynamic> corpo = {};

    if (repeticoes != null) corpo["repeticoes"] = repeticoes;
    if (duracaoMinutos != null) corpo["duracao_minutos"] = duracaoMinutos;
    if (frequenciaSemanal != null) corpo["frequencia_semanal"] = frequenciaSemanal;
    if (observacoes != null) corpo["observacoes"] = observacoes;  

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deletePrescricaoExercicio(
    int idPrescricao,
    int idExercicio
  ) async {
    final url = Uri.parse('$baseUrl/prescricoes/$idPrescricao/exercicios/$idExercicio');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> cadastrarExercicio(
    String nome,
    String descricao,
    String videoUrl,
    String tipo,
    String dificuldadePadrao
  ) async {
    final url = Uri.parse('$baseUrl/exercicios/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {
              "nome": nome,
              "descricao": descricao,
              "video_url": videoUrl,
              "tipo": tipo,
              "dificuldade_padrao": dificuldadePadrao
            }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro de API: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExercicio(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/exercicios/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print("Erro ao buscar paciente: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateExercicio(int id,
      {
        String? nome,
        String? descricao,
        String? videoUrl,
        String? tipo,
        String? dificuldadePadrao
      }) async {
    final url = Uri.parse('$baseUrl/exercicios/$id');

    final Map<String, dynamic> corpo = {};

    if (nome != null) corpo["nome"] = nome;
    if (descricao != null) corpo["descricao"] = descricao;    
    if (videoUrl != null) corpo["video_url"] = videoUrl;    
    if (tipo != null) corpo["tipo"] = tipo;
    if (dificuldadePadrao != null) corpo["dificuldade_padrao"] = dificuldadePadrao;     

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print("Erro ao atualizar paciente: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Erro de conexão: $e");
      return null;
    }
  }

  Future<bool> deleteExercicio(
    int id
  ) async {
    final url = Uri.parse('$baseUrl/exercicios/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;

    }
  }
}
