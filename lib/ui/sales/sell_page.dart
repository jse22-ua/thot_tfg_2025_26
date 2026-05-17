import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/models/sale.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/services/sale_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/books/add_book.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _bookService = BookService();
  final _saleService = SaleService();
  final List<BookStock> _selectedItems = [];
  final Map<String, int> _quantities = {};
  bool _isProcessing = false;

  Future<void> _scanOrAddBook() async {
    final String? isbn = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBook(isSale: true),
    );

    if (isbn != null && mounted) {
      _addBookToSale(isbn);
    }
  }

  Future<void> _addBookToSale(String isbn) async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    setState(() => _isProcessing = true);
    
    final stock = await _bookService.getStockByISBN(bookshopId, isbn);
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (stock != null) {
        if (stock.quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este libro no tiene stock disponible'), backgroundColor: Colors.red),
          );
          return;
        }

        final existingIndex = _selectedItems.indexWhere((item) => item.id == stock.id);
        if (existingIndex != -1) {
          if (_quantities[stock.id!]! < stock.quantity) {
            setState(() {
              _quantities[stock.id!] = _quantities[stock.id!]! + 1;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay más stock disponible'), backgroundColor: Colors.orange),
            );
          }
        } else {
          setState(() {
            _selectedItems.add(stock);
            _quantities[stock.id!] = 1;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro no encontrado en el inventario'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  double get _totalPrice {
    double total = 0;
    for (var item in _selectedItems) {
      total += item.sale_price * (_quantities[item.id] ?? 0);
    }
    return total;
  }

  Future<void> _confirmSale() async {
    if (_selectedItems.isEmpty) return;

    // --- Simulación TPV ---
    final bool? paid = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _TPVSimulationDialog(),
    );

    if (paid != true) return;
    // ---------------------

    setState(() => _isProcessing = true);
    final bookshopId = context.read<BookshopProvider>().bookshopId;

    try {
      final saleItems = _selectedItems.map((item) => SaleItem(
        idStock: item.id!,
        bookTitle: item.title ?? 'Sin título',
        author: item.author ?? 'Autor desconocido',
        quantity: _quantities[item.id]!,
        unitPrice: item.sale_price,
        supplierPrice: item.supplier_price,
        category: item.category,
      )).toList();

      final sale = SaleModel(
        items: saleItems,
        totalPrice: _totalPrice,
        date: DateTime.now(),
        idBookshop: bookshopId!,
      );

      final successId = await _saleService.addSale(sale);

      if (successId != null) {
        // Actualizar stock de cada libro
        for (var item in _selectedItems) {
          await _bookService.updateStockQuantity(item.id!, item.quantity - _quantities[item.id]!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venta registrada con éxito'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print("Error procesando venta: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: const ThotAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "TERMINAL DE VENTA", 
                          style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F))
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF1A3A5F), size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _scanOrAddBook,
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    label: const Text("ESCANEAR / AÑADIR LIBRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5A021),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedItems.isEmpty
                ? Center(child: Text("No hay libros en la venta", style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      final qty = _quantities[item.id] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          title: Text(
                            item.title ?? "Sin título", 
                            style: GoogleFonts.spectral(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "${item.author} - ${item.sale_price}€",
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Container(
                            constraints: const BoxConstraints(maxWidth: 175),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1A3A5F), size: 24),
                                  onPressed: () {
                                    if (qty > 1) {
                                      setState(() => _quantities[item.id!] = qty - 1);
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text("$qty", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1A3A5F), size: 24),
                                  onPressed: () {
                                    if (qty < item.quantity) {
                                      setState(() => _quantities[item.id!] = qty + 1);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Límite de stock alcanzado'), duration: Duration(seconds: 1)),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close, color: Colors.red, size: 22),
                                  onPressed: () {
                                    setState(() {
                                      _selectedItems.removeAt(index);
                                      _quantities.remove(item.id);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("${_totalPrice.toStringAsFixed(2)} €", 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC5A021))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _selectedItems.isEmpty || _isProcessing ? null : _confirmSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A5F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CONFIRMAR VENTA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TPVSimulationDialog extends StatefulWidget {
  const _TPVSimulationDialog();

  @override
  State<_TPVSimulationDialog> createState() => _TPVSimulationDialogState();
}

class _TPVSimulationDialogState extends State<_TPVSimulationDialog> {
  int _step = 0; // 0: Acerque tarjeta, 1: Procesando (rayas/giro), 2: Éxito

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  Future<void> _startSimulation() async {
    // Paso 0 -> 1 (Simula acercar la tarjeta)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _step = 1);

    // Paso 1 -> 2 (Simula procesamiento bancario)
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _step = 2);

    // Finalizar -> Cerrar diálogo
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 0) ...[
              const Icon(Icons.contactless, size: 80, color: Color(0xFF1A3A5F)),
              const SizedBox(height: 20),
              Text("ACERQUE LA TARJETA", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
            if (_step == 1) ...[
              const SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(strokeWidth: 6, color: Color(0xFFC5A021)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.remove, color: Color(0xFF1A3A5F), size: 30),
                )),
              ),
              const SizedBox(height: 10),
              Text("PROCESANDO PAGO...", style: GoogleFonts.spectral(fontStyle: FontStyle.italic, fontSize: 16)),
            ],
            if (_step == 2) ...[
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              Text("PAGO CORRECTO", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
