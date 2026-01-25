import 'dart:async'; // Para o Timer
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Modular.to.navigate('/landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 200,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image,
                          color: colorScheme.onSurface),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AsPa',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 58,
                  fontWeight: FontWeight.normal,
                  color: colorScheme.secondary,
                ),
              ),
              Text(
                'Nós cuidaremos de você.',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
