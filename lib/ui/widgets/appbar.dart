import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/ui/auth/profile/profile.dart';
import 'package:thot_tfg_2025_26/ui/widgets/notification_modal.dart';

class ThotAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThotAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bookshopId = context.watch<BookshopProvider>().bookshopId;
    final bookService = BookService();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1A3A5F),
      toolbarHeight: 110,
      centerTitle: true,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.history_edu, size: 40, color: Color(0xFFC5A021)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'THOT',
                      style: GoogleFonts.cinzel(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC5A021),
                      ),
                    ),
                    Text(
                      'GESTIÓN DE INVENTARIO',
                      style: GoogleFonts.spectral(
                        fontSize: 14,
                        color: const Color(0xFFFDF5E6),
                        letterSpacing: 1.2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Color(0xFFC5A021),
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: bookshopId != null 
                  ? bookService.getInventoryAlerts(bookshopId) 
                  : Future.value([]),
              builder: (context, snapshot) {
                final hasNotifications = snapshot.hasData && snapshot.data!.isNotEmpty;
                final count = snapshot.data?.length ?? 0;

                return Badge(
                  label: Text('$count'),
                  isLabelVisible: hasNotifications,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: Icon(
                      hasNotifications ? Icons.notifications_active : Icons.notifications_outlined, 
                      color: const Color(0xFFC5A021), 
                      size: 30
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const NotificationModal(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
