import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/models/return_record.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/services/return_service.dart';
import 'package:thot_tfg_2025_26/ui/books/book_details.dart';

class ReturnList extends StatefulWidget {
  const ReturnList({super.key});

  @override
  State<ReturnList> createState() => _ReturnListState();
}

class _ReturnListState extends State<ReturnList> {
  final _bookService = BookService();
  final _returnService = ReturnService();
  
  List<BookStock> _booksToReturn = [];
  List<ReturnRecord> _historyReturns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    try {
      final pending = await _bookService.getBooksToReturn(bookshopId);
      final history = await _returnService.getReturnsByShop(bookshopId);
      
      if (mounted) {
        setState(() {
          _booksToReturn = pending;
          _historyReturns = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading returns data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReturn(BookStock stock) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Devolución", style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
        content: Text("¿Deseas devolver ${stock.quantity} unidades de '${stock.title}' a la editorial ${stock.editorialName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DEVOLVER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final bookshopId = context.read<BookshopProvider>().bookshopId!;
      final record = ReturnRecord(
        idBookStock: stock.id!,
        isbn: stock.id_book,
        title: stock.title ?? "N/A",
        author: stock.author ?? "N/A",
        editorialName: stock.editorialName ?? "N/A",
        idEditorial: stock.editorialId ?? "",
        idBookshop: bookshopId,
        quantity: stock.quantity,
        date: DateTime.now(),
      );

      final success = await _returnService.processReturn(record);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Devolución procesada con éxito")),
        );
        _refreshData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF1A3A5F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFC5A021),
              tabs: [
                Tab(text: "PENDIENTES (${_booksToReturn.length})"),
                Tab(text: "HISTORIAL (${_historyReturns.length})"),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _buildPendingList(),
                    _buildHistoryList(),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    if (_booksToReturn.isEmpty) {
      return _buildEmptyState("No hay libros pendientes de devolución", Icons.check_circle_outline, Colors.green);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _booksToReturn.length,
      itemBuilder: (context, index) {
        final stock = _booksToReturn[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                title: Text(stock.title ?? "Sin título", style: GoogleFonts.spectral(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text("${stock.author} | ${stock.editorialName}"),
                trailing: Text("${stock.quantity} uds", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsPage(stock: stock))),
                      child: const Text("VER DETALLES"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleReturn(stock),
                      icon: const Icon(Icons.keyboard_return, size: 18, color: Colors.white),
                      label: const Text("DEVOLVER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    if (_historyReturns.isEmpty) {
      return _buildEmptyState("Aún no se han realizado devoluciones", Icons.history, Colors.blueGrey);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyReturns.length,
      itemBuilder: (context, index) {
        final record = _historyReturns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1A3A5F),
              child: Icon(Icons.assignment_return, color: Colors.white, size: 20),
            ),
            title: Text(record.title, style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Editorial: ${record.editorialName}"),
                Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(record.date)}"),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("DEVUELTO", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                Text("${record.quantity} uds", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.spectral(fontSize: 18, color: const Color(0xFF1A3A5F))),
        ],
      ),
    );
  }
}
