import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemindersPage extends StatelessWidget {//falta ajustar tamanho e posicionamento dos botões, cor dos bloquinhos
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: 
                  const EdgeInsets.symmetric(vertical: 10),
              ),
              Row(
                children: [
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          'Lembretes',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              _sectionHeader(context, 'Medicações'),

              const SizedBox(height: 10),

              _reminderCard(
                context,
                title: '18:00 - Paracetamol',
                subtitle: '1 comprimido',
                onTap: () {}
              ),

              const SizedBox(height: 18),

              // EXERCÍCIOS
              _sectionHeader(context, 'Exercícios'),

              const SizedBox(height: 10),

              _reminderCard(
                context,
                title: '10:00 - movimento de pinça',
                subtitle: '10 repetições',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _sectionHeader(
    BuildContext context,
    String title
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.leagueSpartan(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          Icons.add,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

    Widget _reminderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  }
}
