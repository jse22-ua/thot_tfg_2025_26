import 'package:flutter/material.dart';

class ThotNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ThotNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A3A5F),
      selectedItemColor: const Color(0xFFC5A021),
      unselectedItemColor: const Color(0xFFFDF5E6),
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          activeIcon: Icon(Icons.library_books),
          label: 'Catálogo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_return_outlined),
          activeIcon: Icon(Icons.assignment_return),
          label: 'Devoluciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale, size: 32),
          activeIcon: Icon(Icons.point_of_sale, size: 32),
          label: 'Vender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Análisis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Pedidos',
        ),
      ],
    );
  }
}
