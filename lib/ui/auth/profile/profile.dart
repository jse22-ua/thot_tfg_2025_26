import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/providers/user_provider.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/auth/auth_service.dart';
import 'package:thot_tfg_2025_26/ui/auth/login/login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    final success = await authService.logout();
    
    if (success == true && context.mounted) {
      // Limpiar proveedores
      context.read<UserProvider>().clear();
      context.read<BookshopProvider>().clear();
      
      // Navegar a Login y limpiar stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final bookshopProvider = context.watch<BookshopProvider>();
    final bookshop = bookshopProvider.currentBookshop;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: Text("PERFIL", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: const Color(0xFFC5A021))),
        backgroundColor: const Color(0xFF1A3A5F),
        iconTheme: const IconThemeData(color: Color(0xFFC5A021)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
          const SizedBox(height: 20),
          // Avatar o icono de perfil
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF1A3A5F),
            child: Icon(
              Icons.person,
              size: 80,
              color: const Color(0xFFC5A021),
            ),
          ),
          const SizedBox(height: 24),
          
          // Información del usuario
          Text(
            user?.nombre ?? "Usuario Thot",
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A3A5F),
            ),
          ),
          Text(
            user?.email ?? "sin email",
            style: GoogleFonts.spectral(
              fontSize: 18,
              color: const Color(0xFF1A3A5F).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Tarjeta de detalles
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF5E6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF1A3A5F), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.business, "Librería", bookshop!.name ?? "No vinculada"),
                const Divider(),
                _buildInfoRow(Icons.admin_panel_settings, "Rol", user?.isAdmin == true ? "Administrador" : "Empleado"),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Botón Cerrar Sesión
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text("CERRAR SESIÓN"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000), // Rojo oscuro/sangre
                foregroundColor: Colors.white,
                shape: const BeveledRectangleBorder(),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC5A021)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.spectral(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A3A5F).withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.spectral(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A3A5F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
