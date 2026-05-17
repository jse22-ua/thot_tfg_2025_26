import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/sale.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/sale_service.dart';
import 'package:thot_tfg_2025_26/ui/sales/sales_reports.dart';
import 'package:thot_tfg_2025_26/ui/sales/sell_page.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}



class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final _saleService = SaleService();
  List<SaleModel> _sales = [];
  double _todayTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    if (mounted) setState(() => _isLoading = true);
    
    try {
      final sales = await _saleService.getSalesByShop(bookshopId);
      final todayTotal = await _saleService.getTodaySalesAmount(bookshopId);
      
      if (mounted) {
        setState(() {
          _sales = sales;
          _todayTotal = todayTotal;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading sales data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _sales.isEmpty
                ? const Center(child: Text("No hay ventas registradas todavía"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      final totalQty = sale.items.fold<int>(0, (sum, item) => sum + item.quantity);
                      final displayTitle = sale.items.length == 1 
                        ? sale.items.first.bookTitle 
                        : "${sale.items.length} libros (${sale.items.first.bookTitle}...)";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(displayTitle, style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.date)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${sale.totalPrice.toStringAsFixed(2)} €", 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC5A021), fontSize: 16)),
                              Text("Cant: $totalQty", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta de Resumen / Estadísticas rápidas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A5F),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Text(
                  "VENTAS DE HOY",
                  style: GoogleFonts.cinzel(color: const Color(0xFFC5A021), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "${_todayTotal.toStringAsFixed(2)} €",
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Total de ${_sales.where((s) => s.date.day == DateTime.now().day).length} transacciones",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Botón Vender
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellPage()),
                );
                if (result == true) {
                  await _loadData(); // Esperamos a que cargue
                }
              },
              icon: const Icon(Icons.point_of_sale, color: Colors.white),
              label: Text(
                "VENDER",
                style: GoogleFonts.spectral(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A021),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Título historial
          Row(
            children: [
              Text(
                "HISTORIAL RECIENTE",
                style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SalesReportsPage()),
                  );
                },
                child: const Text("VER INFORMES", style: TextStyle(color: Color(0xFFC5A021))),
              )
            ],
          ),
        ],
      ),
    );
  }
}
