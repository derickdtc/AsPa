import 'package:flutter/material.dart';
import '../../api_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PrescricaoPage extends StatefulWidget {
  final int idMedico;
  final int idPaciente;
  final String nomePaciente;

  const PrescricaoPage({
    super.key,
    required this.idMedico,
    required this.idPaciente,
    required this.nomePaciente,
  });

  @override
  State<PrescricaoPage> createState() => _PrescricaoPageState();
}

class _PrescricaoPageState extends State<PrescricaoPage> {
  final _obsController = TextEditingController();
  final ApiService _api = ApiService();

  final List<Map<String, String>> _remediosParaAdicionar = [];
  final List<Map<String, dynamic>> _exerciciosParaAdicionar = [];
  List<dynamic> _catalogoExercicios = [];
  dynamic _exercicioSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarCatalogo();
  }

  void _carregarCatalogo() async {
    final lista = await _api.getCatalogoExercicios();
    setState(() {
      _catalogoExercicios = lista;
    });
  }

  void _adicionarRemedioNaLista() {
    String nome = "";
    String hora = "08:00";
    String dose = "1 cp";

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            "Novo Medicamento",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => nome = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: "Dose",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => dose = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: "Horário",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: TextEditingController(text: hora),
                onChanged: (v) => hora = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nome.isNotEmpty) {
                  setState(() => _remediosParaAdicionar
                      .add({"nome": nome, "hora": hora, "dose": dose}));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Adicionar"),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colorScheme.surface,
        );
      },
    );
  }

  void _adicionarExercicioNaLista() {
    if (_catalogoExercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nenhum exercício cadastrado no sistema."),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    int repeticoes = 10;
    int minutos = 15;
    int freqSemanal = 3;
    String obs = "";
    _exercicioSelecionado = _catalogoExercicios[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return AlertDialog(
            title: Text(
              "Recomendar Exercício",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      value: _exercicioSelecionado,
                      items: _catalogoExercicios.map((ex) {
                        return DropdownMenuItem(
                          value: ex,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              ex['nome'],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => _exercicioSelecionado = val);
                      },
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Duração (minutos)",
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => minutos = int.tryParse(v) ?? 15,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Repetições (ex: 10)",
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => repeticoes = int.tryParse(v) ?? 10,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Vezes na semana",
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => freqSemanal = int.tryParse(v) ?? 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Observação (ex: Devagar)",
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) => obs = v,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _exerciciosParaAdicionar.add({
                      "id_exercicio": _exercicioSelecionado['id_exercicio'],
                      "nome": _exercicioSelecionado['nome'],
                      "duracao": minutos,
                      "repeticoes": repeticoes,
                      "frequencia": freqSemanal,
                      "obs": obs,
                    });
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Adicionar"),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: colorScheme.surface,
          );
        },
      ),
    );
  }

  void _salvarTudo() async {
    final idPrescricao = await _api.cadastrarPrescricao(
      widget.idPaciente,
      widget.idMedico,
      _obsController.text,
    );

    if (idPrescricao != null) {
      for (var item in _remediosParaAdicionar) {
        await _api.cadastrarLembrete(
          idPrescricao,
          "${item['hora']}:00",
          item['nome']!,
          1.0,
          "comprimido",
          "ativo",
        );
      }

      for (var ex in _exerciciosParaAdicionar) {
        await _api.cadastrarPrescricaoExercicio(
          idPrescricao,
          ex['id_exercicio'],
          ex['repeticoes'],
          ex['duracao'],
          ex['frequencia'],
          ex['obs'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Tratamento salvo com sucesso!"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Erro ao salvar."),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> gerarRelatorio() async {
    final relatorio = await _api.getRelatorio(widget.idPaciente);

    if (!mounted) return;

    if (relatorio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao gerar relatório")),
      );
      return;
    }

    final pdf = pw.Document();

    final paciente = relatorio['paciente'];
    final prescricoes = relatorio['prescricoes'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Text(
              "Relatório Clínico",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));
          widgets.add(pw.Text("Paciente: ${paciente['nome_usuario']}"));
          widgets.add(pw.Text(
              "Data do diagnóstico: ${formatarDate(paciente['data_diagnostico'])}"));
          widgets.add(pw.Divider());

          if (prescricoes is String) {
            widgets.add(pw.Text(prescricoes));
            return widgets;
          }

          for (final p in prescricoes) {
            widgets.add(pw.SizedBox(height: 12));

            widgets.add(
              pw.Text(
                "Prescrição - ${formatarDateTime(p['data_atualizacao'])}",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            );

            widgets
                .add(pw.Text("Observações: ${p['observacoes_gerais'] ?? '-'}"));
            widgets.add(pw.SizedBox(height: 8));

            /// Medicamentos
            widgets.add(
              pw.Text("Medicamentos:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            );

            if (p['lembretes'].isEmpty) {
              widgets.add(pw.Text("Nenhum medicamento registrado."));
            } else {
              for (final l in p['lembretes']) {
                widgets.add(
                  pw.Text(
                    "- Nome: ${l['nome_medicamento']} | Dose diária: ${l['dose_diaria']} | Horário: ${l['horario']}",
                  ),
                );
              }
            }

            widgets.add(pw.SizedBox(height: 8));

            /// Exercícios
            widgets.add(
              pw.Text("Exercícios:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            );

            if (p['exercicios'].isEmpty) {
              widgets.add(pw.Text("Nenhum exercício registrado."));
            } else {
              for (final e in p['exercicios']) {
                widgets.add(
                  pw.Text(
                    "- Nome: ${e['nome']} | Duração: ${e['duracao_minutos']} min | "
                    "${e['frequencia_semanal']}x/semana | Ultima execução: ${formatarDate(e['ultima_execucao'])}",
                  ),
                );
              }
            }
          }

          return widgets;
        },
      ),
    );

    await _salvarPdf(pdf);
  }

  Future<void> _salvarPdf(pw.Document pdf) async {
    final bytes = await pdf.save();

    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } else {
      // Abre o menu nativo de compartilhamento/salvamento
      await Printing.sharePdf(
          bytes: bytes, filename: 'relatorio_${widget.nomePaciente}.pdf');
    }
  }

  String formatarDateTime(dynamic data) {
    if (data == null) return '-';

    final dateTime = DateTime.parse(data.toString());
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String formatarDate(dynamic data) {
    if (data == null) return '-';

    final date = DateTime.parse(data.toString());
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tratamento: ${widget.nomePaciente}",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 4,
        shadowColor: colorScheme.shadow,
      ),
      body: Container(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.05),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Observações
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Observações Gerais:",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _obsController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText:
                                "Digite observações sobre o tratamento...",
                          ),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seção de Medicamentos
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Medicamentos",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _adicionarRemedioNaLista,
                            icon: Icon(
                              Icons.add,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                            label: Text(
                              "Adicionar",
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_remediosParaAdicionar.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Nenhum medicamento adicionado",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ..._remediosParaAdicionar.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.medication,
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                              title: Text(
                                r['nome']!,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "${r['dose']} às ${r['hora']}",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed: () => setState(
                                  () => _remediosParaAdicionar.remove(r),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seção de Exercícios
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exercícios Físicos",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _adicionarExercicioNaLista,
                            icon: Icon(
                              Icons.add,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                            label: Text(
                              "Adicionar",
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.tertiary,
                              foregroundColor: colorScheme.onTertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_exerciciosParaAdicionar.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fitness_center_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Nenhum exercício recomendado",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ..._exerciciosParaAdicionar.map((ex) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.directions_run,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                              title: Text(
                                ex['nome'],
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "${ex['duracao']} min - ${ex['frequencia']}x/semana",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed: () => setState(
                                  () => _exerciciosParaAdicionar.remove(ex),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Column(
                children: [
                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _salvarTudo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "SALVAR TRATAMENTO COMPLETO",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botão Gerar Relatório
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      //aqui
                      onPressed: gerarRelatorio,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "GERAR RELATÓRIO",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
