import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:thot_tfg_2025_26/models/sale.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/services/sale_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';

class SalesReportsPage extends StatefulWidget {
  final bool showAppBar;
  const SalesReportsPage({super.key, this.showAppBar = true});

  @override
  State<SalesReportsPage> createState() => _SalesReportsPageState();
}

class _SalesReportsPageState extends State<SalesReportsPage> {
  final _saleService = SaleService();
  final _bookService = BookService();
  bool _isLoading = true;
  
  // Métricas
  double _dayRev = 0;
  double _monthRev = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;

  // Top libros
  List<MapEntry<String, int>> _topBooks = [];

  // Datos semanales
  DateTime _focusedWeek = DateTime.now();
  List<double> _weeklySales = List.filled(7, 0.0);
  
  List<SaleModel> _allSales = [];
  List<BookStock> _allStock = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final bookshopId = context.read<BookshopProvider>().bookshopId;
    if (bookshopId == null) return;

    final sales = await _saleService.getSalesByShop(bookshopId);
    final stock = await _bookService.getAllStockByShop(bookshopId);
    
    _allSales = sales;
    _allStock = stock;
    _calculateAllStats();
  }

  void _calculateAllStats() {
    final now = DateTime.now();
    
    double dayRev = 0;
    double monthRev = 0;
    double totalIncome = 0;
    double costOfSoldBooks = 0;
    
    Map<String, int> bookCounts = {};

    for (var sale in _allSales) {
      final sDate = sale.date;
      final bool isToday = sDate.year == now.year && sDate.month == now.month && sDate.day == now.day;
      final bool isThisMonth = sDate.year == now.year && sDate.month == now.month;

      totalIncome += sale.totalPrice;
      
      for (var item in sale.items) {
        costOfSoldBooks += item.supplierPrice * item.quantity;
        if (isThisMonth) {
          bookCounts[item.bookTitle] = (bookCounts[item.bookTitle] ?? 0) + item.quantity;
        }
      }

      if (isToday) dayRev += sale.totalPrice;
      if (isThisMonth) {
        monthRev += sale.totalPrice;
      }
    }

    // Calcular coste de libros en stock
    double costOfStock = 0;
    for (var stock in _allStock) {
      costOfStock += stock.supplier_price * stock.quantity;
    }

    // Gastos = Libros vendidos (coste) + Libros en stock (coste)
    double totalExpenses = costOfSoldBooks + costOfStock;

    // Calcular Top 3
    var sortedBooks = bookCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _topBooks = sortedBooks.take(3).toList();

    _updateWeeklyData();

    if (mounted) {
      setState(() {
        _dayRev = dayRev;
        _monthRev = monthRev;
        _totalIncome = totalIncome;
        _totalExpenses = totalExpenses;
        _isLoading = false;
      });
    }
  }

  void _updateWeeklyData() {
    // Calcular inicio de la semana enfocada (Lunes)
    DateTime startOfWeek = _focusedWeek.subtract(Duration(days: _focusedWeek.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

    List<double> dailyIncome = List.filled(7, 0.0);

    for (var sale in _allSales) {
      if (sale.date.isAfter(startOfWeek) && sale.date.isBefore(endOfWeek)) {
        int dayIdx = sale.date.weekday - 1; // 0 (Lun) a 6 (Dom)
        dailyIncome[dayIdx] += sale.totalPrice;
      }
    }

    setState(() {
      _weeklySales = dailyIncome;
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _focusedWeek = _focusedWeek.add(Duration(days: delta * 7));
    });
    _updateWeeklyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: widget.showAppBar ? const ThotAppBar() : null,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text("INFORME DE VENTAS", style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F))),
                      ),
                    ),
                    if (widget.showAppBar)
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF1A3A5F), size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Resumen Diario/Mensual
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard("INGRESOS HOY", "${_dayRev.toStringAsFixed(2)}€", Icons.today, Colors.orange)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildSummaryCard("INGRESOS MES", "${_monthRev.toStringAsFixed(2)}€", Icons.calendar_month, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 15),

                // Resumen Totales (Ingresos vs Gastos)
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard("INGRESOS TOTALES", "${_totalIncome.toStringAsFixed(2)}€", Icons.analytics, Colors.indigo)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildSummaryCard("GASTOS TOTALES", "${_totalExpenses.toStringAsFixed(2)}€", Icons.shopping_cart, Colors.red)),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "* Gastos = Libros vendidos + Libros en stock (a precio de coste)",
                    style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ),
                
                const SizedBox(height: 30),
                _buildSectionTitle("TOP 3 LIBROS MÁS VENDIDOS (MES)"),
                const SizedBox(height: 10),
                _buildTopBooksList(),

                const SizedBox(height: 30),
                _buildWeeklyHeader(),
                const SizedBox(height: 10),
                _buildWeeklySalesChart(),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F)),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          FittedBox(
            child: Text(value, style: GoogleFonts.spectral(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F))),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBooksList() {
    if (_topBooks.isEmpty) return const Center(child: Text("Sin ventas este mes"));

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: _topBooks.asMap().entries.map((e) {
          int index = e.key;
          var entry = e.value;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index == 0 ? const Color(0xFFC5A021) : Colors.grey[300],
              child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.key, style: GoogleFonts.spectral(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text("${entry.value} uds", style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyHeader() {
    DateTime startOfWeek = _focusedWeek.subtract(Duration(days: _focusedWeek.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    String range = "${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM').format(endOfWeek)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("INGRESOS DIARIOS (SEMANA)"),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(range, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC5A021))),
            Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.chevron_left), 
                  onPressed: () => _changeWeek(-1)
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.chevron_right), 
                  onPressed: () => _changeWeek(1)
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklySalesChart() {
    double maxVal = _weeklySales.reduce((a, b) => a > b ? a : b);
    if (maxVal < 100) maxVal = 100;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barGroups: _weeklySales.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value, color: const Color(0xFFC5A021), width: 18, borderRadius: BorderRadius.circular(4))],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text("${value.toInt()}€", style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
