import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/orders.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/order_service.dart';
import 'package:thot_tfg_2025_26/ui/orders/new_order_search.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _orderService = OrderService();
  final _searchController = TextEditingController();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await _orderService.getOrdersByShop(bookshopId);
      if (mounted) {
        setState(() {
          _orders = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    if (query.isEmpty) {
      _loadOrders();
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await _orderService.searchOrdersByBookTitle(bookshopId, query);
      if (mounted) {
        setState(() {
          _orders = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error searching orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Buscar pedido por título de libro...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3A5F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A3A5F)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewOrderSearchPage()),
                    );
                    if (result == true) {
                      _loadOrders();
                    }
                  },
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  label: const Text("REALIZAR PEDIDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? const Center(child: Text("No se encontraron pedidos"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(order.bookTitle, style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Editorial: ${order.editorialName}"),
                                Text("Fecha: ${DateFormat('dd/MM/yyyy').format(order.date)}"),
                                Row(
                                  children: [
                                    Text("Cant: ${order.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 10),
                                    Text("${order.price} €", style: const TextStyle(color: Color(0xFFC5A021), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(order.state, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
