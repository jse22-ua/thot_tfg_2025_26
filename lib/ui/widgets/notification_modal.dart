import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final _bookService = BookService();
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null || bookshopId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final alerts = await _bookService.getInventoryAlerts(bookshopId);
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading alerts: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF5E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "NOTIFICACIONES",
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A3A5F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _alerts.isEmpty
                    ? const Center(child: Text("No tienes notificaciones pendientes"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          final bool isLowStock = alert['type'] == 'low_stock';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isLowStock ? Colors.orange.shade50 : Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isLowStock ? Colors.orange : Colors.blue,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                isLowStock ? Icons.warning_amber_rounded : Icons.calendar_today,
                                color: isLowStock ? Colors.orange.shade800 : Colors.blue.shade800,
                              ),
                              title: Text(
                                alert['title'],
                                style: GoogleFonts.spectral(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(alert['message']),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
