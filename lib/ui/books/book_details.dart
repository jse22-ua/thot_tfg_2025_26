import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/books/edit_stock.dart';

class BookDetailsPage extends StatelessWidget {
  final BookStock stock;

  const BookDetailsPage({super.key, required this.stock});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Borrar Stock?", style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
        content: Text("¿Estás seguro de que quieres eliminar este libro del inventario? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final bookService = BookService();
      final success = await bookService.deleteStock(stock.id!);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Libro eliminado del stock correctamente')),
          );
          Navigator.pop(context); // Volver a la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el stock')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: const ThotAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3A5F)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(Icons.book, size: 60, color: Color(0xFF1A3A5F)),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                stock.title ?? "Título desconocido",
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A3A5F),
                ),
              ),
            ),
            Center(
              child: Text(
                stock.author ?? "Autor desconocido",
                style: GoogleFonts.spectral(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Información del Libro"),
            _buildDetailRow(Icons.qr_code, "ISBN", stock.id_book),
            _buildDetailRow(Icons.business, "Editorial", stock.editorialName ?? "N/A"),
            _buildDetailRow(Icons.category, "Categoría", stock.category ?? "N/A"),
            const Divider(height: 40, thickness: 1.5),
            _buildSectionTitle("Detalles del Stock"),
            Row(
              children: [
                Expanded(child: _buildInfoCard("CANTIDAD", "${stock.quantity}", Icons.inventory_2, const Color(0xFF1A3A5F))),
                const SizedBox(width: 15),
                Expanded(child: _buildInfoCard("PRECIO VENTA", "${stock.sale_price}€", Icons.payments, const Color(0xFFC5A021))),
              ],
            ),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.location_on, "Ubicación", stock.ubication ?? "No especificada"),
            _buildDetailRow(Icons.info_outline, "Estado", stock.state.toUpperCase()),
            _buildDetailRow(Icons.shopping_cart, "Costo Compra", "${stock.supplier_price} €"),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditStockPage(stock: stock),
                          ),
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(context); // Volvemos a la lista para forzar recarga
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("EDITAR STOCK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A5F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFC5A021),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A3A5F)),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3A5F)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}