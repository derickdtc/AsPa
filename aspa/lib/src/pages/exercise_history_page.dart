import 'package:flutter/material.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({super.key});

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Histórico de Exercicios")),
        body: const Center(child: Text("Tela de Histórico")));
  }
}
