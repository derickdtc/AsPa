import 'package:flutter/material.dart';
import '../controllers/home_paciente_controller.dart';
import '../models/home_paciente_model.dart';

class ExerciciosPage extends StatefulWidget {
  final int userId;
  const ExerciciosPage({super.key, required this.userId});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  // Reaproveitamos o Controller para ter a lógica de "Marcar Concluído" e buscar dados
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
      appBar: AppBar(title: const Text("Meus Exercícios")),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.exercicios.isEmpty) {
            return Center(
                child: Text("Nenhum exercício encontrado.",
                    style: theme.textTheme.bodyLarge));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.exercicios.length,
            itemBuilder: (context, index) {
              final exercicio = controller.exercicios[index];
              return _buildExercicioItem(context, exercicio, colorScheme);
            },
          );
        },
      ),
    );
  }

  // Trouxemos esse Widget da Home para cá
  Widget _buildExercicioItem(BuildContext context, ExercicioPaciente exercicio,
      ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            exercicio.concluido ? Icons.check_circle : Icons.circle_outlined,
            color: exercicio.concluido ? Colors.green : colorScheme.secondary,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercicio.nome,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (exercicio.descricao.isNotEmpty)
                  Text(
                    exercicio.descricao,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 5),
                // Exibe a data de atribuição se quiser
                Text(
                  "Atribuído em: ${_formatDate(exercicio.dataAtribuicao)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
          if (!exercicio.concluido)
            IconButton(
              onPressed: () =>
                  controller.marcarExercicioConcluido(exercicio.id),
              icon: const Icon(Icons.play_circle_fill),
              color: colorScheme.primary,
              iconSize: 32,
              tooltip: "Marcar como feito",
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}";

  ThemeData get theme => Theme.of(context);
}
