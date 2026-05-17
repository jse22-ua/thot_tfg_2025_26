import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/ui/books/book_details.dart';

class ListBook extends StatefulWidget {
  const ListBook({super.key});

  @override
  State<ListBook> createState() => _ListBookState();
}

class _ListBookState extends State<ListBook> {
  final _bookService = BookService();
  final _searchController = TextEditingController();
  List<BookStock> _stockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialStock();
  }

  Future<void> _loadInitialStock() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await _bookService.getStockByShop(bookshopId, 20);
      if (mounted) {
        setState(() {
          _stockItems = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading stock: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 3) {
      if (query.isEmpty) _loadInitialStock();
      return;
    }

    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await _bookService.searchStockEfficient(bookshopId, query);
      if (mounted) {
        setState(() {
          _stockItems = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error searching stock: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Buscar libro en stock...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3A5F)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A3A5F)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC5A021), width: 2),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _stockItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay libros que coincidan",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _stockItems.length,
                      itemBuilder: (context, index) {
                        final stock = _stockItems[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              stock.title ?? "Sin título",
                              style: GoogleFonts.spectral(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: const Color(0xFF1A3A5F)
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stock.author ?? "Autor desconocido", style: const TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoTag(
                                      stock.quantity == 0 ? "Sin Stock" : "Stock: ${stock.quantity}",
                                      stock.quantity == 0 ? Colors.red : const Color(0xFF1A3A5F)
                                    ),
                                    const SizedBox(width: 8),
                                    _buildInfoTag("${stock.sale_price} €", const Color(0xFFC5A021)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoTag(stock.ubication?.isEmpty ?? true ? "Sin ubicación" : "${stock.ubication}", Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    _buildStateTag(stock.state),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A3A5F)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailsPage(stock: stock),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
      ),
    );
  }

  Widget _buildStateTag(String state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Text(
        state.toUpperCase(),
        style: TextStyle(
          fontSize: 10, 
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}