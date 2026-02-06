import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GameSelectionPage extends StatelessWidget {
  final int userId;
  const GameSelectionPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> games = [
      {
        'title': 'Jardineiro',
        'description': 'Exercício de coordenação motora fina',
        'icon': Icons.local_florist_rounded,
        'color': colorScheme.primary,
        'route': '/game_jardineiro',
      },
      {
        'title': 'Traçado',
        'description': 'Exercício de controle de tremores',
        'icon': Icons.gesture_rounded,
        'color': colorScheme.secondary,
        'route': '/game_tracing',
      },
      {
        'title': 'Classificação de objetos',
        'description': 'Exercício de raciocínio e memória',
        'icon': Icons.emoji_objects_outlined,
        'color': colorScheme.secondary,
        'route': '/game_classification',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios Diários'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: game['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(game['icon'], color: game['color'], size: 32),
              ),
              title: Text(
                game['title'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(game['description']),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Modular.to.pushNamed(game['route'], arguments: userId);
              },
            ),
          );
        },
      ),
    );
  }
}
