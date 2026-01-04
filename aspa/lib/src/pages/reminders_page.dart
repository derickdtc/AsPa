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
              // HEADER
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 29),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 28,
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
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // MEDICAÇÕES
              _sectionHeader('Medicações'),

              const SizedBox(height: 10),

              _reminderCard(
                title: '18:00 - Paracetamol',
                subtitle: '1 comprimido',
              ),

              const SizedBox(height: 18),

              // EXERCÍCIOS
              _sectionHeader('Exercícios'),

              const SizedBox(height: 10),

              _reminderCard(
                title: '10:00 - movimento de pinça',
                subtitle: '10 repetições',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- COMPONENTES ----------

  Widget _sectionHeader(String title) {
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
          const Icon(
            Icons.add,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _reminderCard({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFC62828),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.nunito(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
