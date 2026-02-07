import 'package:flutter/material.dart';
import '../controllers/home_paciente_controller.dart';
import '../models/home_paciente_model.dart';

class LembretesPage extends StatefulWidget {
  final int userId;
  const LembretesPage({super.key, required this.userId});

  @override
  State<LembretesPage> createState() => _LembretesPageState();
}

class _LembretesPageState extends State<LembretesPage> {
  final HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.carregarDadosPaciente(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Meus Lembretes")),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lembretes.isEmpty) {
            return Center(
                child: Text("Nenhum lembrete ativo.",
                    style: theme.textTheme.bodyLarge));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.lembretes.length,
            itemBuilder: (context, index) {
              final lembrete = controller.lembretes[index];
              return _buildLembreteItem(context, lembrete, colorScheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildLembreteItem(BuildContext context, LembretePaciente lembrete,
      ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: lembrete.ativo
                    ? colorScheme.secondary.withValues(alpha: 0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle),
            child: Icon(
              Icons.medication,
              color: lembrete.ativo ? colorScheme.secondary : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lembrete.titulo,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  lembrete.descricao,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${lembrete.dataHora.hour.toString().padLeft(2, '0')}:${lembrete.dataHora.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmarExclusao(context, lembrete.id),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Lembrete"),
        content: const Text(
            "Tem certeza que deseja apagar este medicamento da sua lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // fech o dialog
              controller.excluirLembrete(id); // chama a exclusão
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
