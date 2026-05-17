
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/providers/user_provider.dart';
import 'package:thot_tfg_2025_26/services/auth/auth_service.dart';
import 'package:thot_tfg_2025_26/services/bookshop_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/books/add_book.dart';
import 'package:thot_tfg_2025_26/ui/books/book_form.dart';
import 'package:thot_tfg_2025_26/ui/books/list_books.dart';
import 'package:thot_tfg_2025_26/ui/orders/order_list.dart';
import 'package:thot_tfg_2025_26/ui/sales/sales_history.dart';
import 'package:thot_tfg_2025_26/ui/sales/sales_reports.dart';
import 'package:thot_tfg_2025_26/ui/returns/return_list.dart';
import 'package:thot_tfg_2025_26/ui/widgets/navegationBarThot.dart';
import 'package:thot_tfg_2025_26/ui/auth/profile/profile.dart';

class HomePage extends StatefulWidget {
  final String id;
  const HomePage({super.key, required this.id});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return ListBook(key: UniqueKey());
      case 1:
        return const ReturnList();
      case 2:
        return SalesHistoryPage(key: UniqueKey());
      case 3:
        return const SalesReportsPage(showAppBar: false);
      case 4:
        return const OrderListPage();
      default:
        return ListBook(key: UniqueKey());
    }
  }

  Future<void> _checkUser() async {
    final userProvider = context.read<UserProvider>();
    
    // Si ya tenemos el usuario en el provider, no cargamos nada
    if (userProvider.userId == widget.id && userProvider.currentUser != null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final authService = AuthService();
    final user = await authService.getUser(widget.id);
    
    if (user != null && mounted) {
      userProvider.setUserId(widget.id);
      userProvider.setUser(user);
      if(user.bookshopId != ''){
        final bsProvider = context.read<BookshopProvider>();
        final bookshopservice = BookshopService();
        final bs = await bookshopservice.getBookShop(user.bookshopId);
        bsProvider.setBookshopId(user.bookshopId);
        bsProvider.setBookshop(bs!);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleAddBook(BuildContext context) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBook(),
    );

    // Si result es null, es que el usuario cerró o pulsó manual sin ISBN
    // Manejamos ambos casos para que pueda ir al formulario igualmente si quiere
    
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookForm(isbn: result),
        ),
      );
      
      // Al volver, forzamos la actualización de la página actual
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const ThotAppBar(),
      body: _getSelectedPage(),
      floatingActionButton: (_selectedIndex == 3 || _selectedIndex == 4)
          ? null 
          : FloatingActionButton.extended(
              onPressed: () => _handleAddBook(context),
              backgroundColor: const Color(0xFFC5A021),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Añadir Libro", style: TextStyle(color: Colors.white)),
            ),
      bottomNavigationBar: ThotNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
