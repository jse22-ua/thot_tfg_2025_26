import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/book.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/services/editorial_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/widgets/navegationBarThot.dart';

class BookStockForm extends StatefulWidget {
  final Book book;
  final String nameEditorial;

  const BookStockForm({super.key, required this.book, required this.nameEditorial});

  @override
  State<BookStockForm> createState() => _BookStockFormState();
}

class _BookStockFormState extends State<BookStockForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _supplierPriceController;
  String? _recommendedPrice;
  final _bookService = BookService();
  final _editorialService = EditorialService();

  @override
  void initState() {
    super.initState();
    // Si el libro ya tiene precio, lo mostramos y bloqueamos el campo
    String priceText = widget.book.price > 0 ? widget.book.price.toString() : '';
    _supplierPriceController = TextEditingController(text: priceText);
    
    // Calcular recomendación inicial
    _updateRecommendation();
    
    // Escuchar cambios para actualizar recomendación
    _supplierPriceController.addListener(_updateRecommendation);
  }

  void _updateRecommendation() {
    final double? supplierPrice = double.tryParse(_supplierPriceController.text);
    if (supplierPrice != null && supplierPrice > 0) {
      setState(() {
        _recommendedPrice = (supplierPrice * 1.30).toStringAsFixed(2);
      });
    } else {
      setState(() {
        _recommendedPrice = null;
      });
    }
  }
  
  final _quantityController = TextEditingController(text: '1');
  final _salePriceController = TextEditingController();
  final _ubicationController = TextEditingController();

  String _selectedState = 'Comprado';
  final List<String> _states = ['Comprado', 'En deposito'];

  @override
  void dispose() {
    _quantityController.dispose();
    _supplierPriceController.dispose();
    _salePriceController.dispose();
    _ubicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: const ThotAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Detalles de Stock para:"),
              Text(
                widget.book.title,
                style: GoogleFonts.spectral(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A3A5F),
                ),
              ),
              const SizedBox(height: 25),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Cantidad", 
                      _quantityController, 
                      icon: Icons.numbers, 
                      keyboardType: TextInputType.number
                    )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      "Ubicación", 
                      _ubicationController, 
                      icon: Icons.location_on, 
                      isRequired: false
                    )
                  ),
                ],
              ),
              const SizedBox(height: 5),
              
              const Text(
                "Estado", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1A3A5F),
                  fontSize: 14,
                )
              ),
              const SizedBox(height: 8),
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A3A5F)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedState,
                    isExpanded: true,
                    items: _states.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedState = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                "Precio Compra (€)", 
                _supplierPriceController, 
                icon: Icons.shopping_cart, 
                keyboardType: TextInputType.number, 
                readOnly: _supplierPriceController.text.isNotEmpty
              ),
              
              _buildTextField(
                "Precio Venta (€)", 
                _salePriceController, 
                icon: Icons.sell, 
                keyboardType: TextInputType.number,
                helperText: _recommendedPrice != null ? "Sugerencia: $_recommendedPrice€ (+30% margen)" : null,
              ),

              const SizedBox(height: 20),
              
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1A3A5F), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "ATRÁS",
                          style: GoogleFonts.spectral(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A3A5F),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveBookAndStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A5F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "GUARDAR",
                          style: GoogleFonts.spectral(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC5A021),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ThotNavigationBar(
        currentIndex: 0,
        onTap: (index) => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFC5A021),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType keyboardType = TextInputType.text, bool isRequired = true, bool readOnly = false, String? helperText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            validator: isRequired ? (value) => value == null || value.isEmpty ? 'Requerido' : null : null,
            decoration: InputDecoration(
              labelText: label,
              helperText: helperText,
              helperStyle: const TextStyle(color: Color(0xFFC5A021), fontWeight: FontWeight.bold),
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1A3A5F)) : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[200] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF1A3A5F).withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBookAndStock() async {
    if (_formKey.currentState!.validate()) {
      final bookshopProvider = context.read<BookshopProvider>();
      
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 1. Asegurar que la editorial existe y obtener su ID final
        String? finalEditorialId = await _editorialService.checkAndGetEditorialId(widget.nameEditorial);

        // 2. Actualizar el objeto libro con el ID real de la editorial
        final finalBook = Book(
          isbn: widget.book.isbn,
          title: widget.book.title,
          author: widget.book.author,
          category: widget.book.category,
          price: widget.book.price,
          id_editorial: finalEditorialId,
        );

        // 3. Crear el objeto BookStock con datos denormalizados
        final stock = BookStock(
          id_book: widget.book.isbn!,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          state: _selectedState,
          supplier_price: double.tryParse(_supplierPriceController.text) ?? 0.0,
          sale_price: double.tryParse(_salePriceController.text) ?? 0.0,
          ubication: _ubicationController.text,
          id_bookshop: bookshopProvider.bookshopId ?? "N/A",
          title: widget.book.title,
          author: widget.book.author,
          category: widget.book.category,
          editorialName: widget.nameEditorial,
          editorialId: finalEditorialId
        );

        // 4. Guardar Libro y Stock en Firebase
        final idBook = await _bookService.addBook(finalBook);
        if (idBook == null) {
          throw Exception("Error en la creación del libro");
        }

        final stockId = await _bookService.addBookStock(stock);
        if (stockId == null) {
          throw Exception("Error al añadir el stock");
        }

        if (mounted) {
          Navigator.pop(context); // Quitar el loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Libro ${widget.book.title} guardado con éxito')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Quitar el loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
          );
        }
      }
    }
  }
}
