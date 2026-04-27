import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThotAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;

  const ThotAppBar({
    super.key,
    this.subtitle = 'GESTIÓN DE INVENTARIO',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1A3A5F), // Lapis Lazuli
      toolbarHeight: 90, // Reducido de 110
      centerTitle: true,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 55, // Reducido de 80
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.history_edu, size: 40, color: Color(0xFFC5A021)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'THOT',
                style: GoogleFonts.cinzel(
                  fontSize: 28, // Reducido de 36
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC5A021), // Oro
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.spectral(
                  fontSize: 12, // Reducido de 14
                  color: const Color(0xFFFDF5E6), // Papiro
                  letterSpacing: 1.2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90); // Ajustado a la nueva altura
}
