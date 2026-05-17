import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/models/bookstock.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';

class EditStockPage extends StatefulWidget {
  final BookStock stock;

  const EditStockPage({super.key, required this.stock});

  @override
  State<EditStockPage> createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _salePriceController;
  late TextEditingController _ubicationController;
  
  // Controladores para campos de solo lectura
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _editorialController;
  late TextEditingController _categoryController;
  late TextEditingController _isbnController;

  bool _isLoading = false;
  final _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.stock.quantity.toString());
    _salePriceController = TextEditingController(text: widget.stock.sale_price.toString());
    _ubicationController = TextEditingController(text: widget.stock.ubication ?? '');
    
    _titleController = TextEditingController(text: widget.stock.title ?? '');
    _authorController = TextEditingController(text: widget.stock.author ?? '');
    _editorialController = TextEditingController(text: widget.stock.editorialName ?? '');
    _categoryController = TextEditingController(text: widget.stock.category ?? '');
    _isbnController = TextEditingController(text: widget.stock.id_book);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _salePriceController.dispose();
    _ubicationController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _editorialController.dispose();
    _categoryController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _updateStock() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Map<String, dynamic> updatedData = {
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'sale_price': double.tryParse(_salePriceController.text) ?? 0.0,
        'ubication': _ubicationController.text,
      };

      final success = await _bookService.updateStock(widget.stock.id!, updatedData);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock actualizado con éxito')),
          );
          // Volvemos atrás pasando el nuevo stock (opcional, pero ayuda a refrescar)
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el stock')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: const ThotAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "EDITAR STOCK",
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A3A5F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF1A3A5F)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Campos Desactivados (Lectura)
              _buildTextField("Título", _titleController, icon: Icons.book, readOnly: true),
              _buildTextField("Autor", _authorController, icon: Icons.person, readOnly: true),
              Row(
                children: [
                  Expanded(child: _buildTextField("ISBN", _isbnController, icon: Icons.qr_code, readOnly: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("Categoría", _categoryController, icon: Icons.category, readOnly: true)),
                ],
              ),
              _buildTextField("Editorial", _editorialController, icon: Icons.business, readOnly: true),
              
              const Divider(height: 40, thickness: 1),
              Text(
                "DATOS EDITABLES",
                style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFC5A021)),
              ),
              const SizedBox(height: 15),
              
              // Campos Editables
              Row(
                children: [
                  Expanded(child: _buildTextField("Cantidad", _quantityController, icon: Icons.inventory_2, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("Precio Venta (€)", _salePriceController, icon: Icons.payments, keyboardType: TextInputType.number)),
                ],
              ),
              _buildTextField("Ubicación en tienda", _ubicationController, icon: Icons.location_on),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateStock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "GUARDAR CAMBIOS",
                        style: GoogleFonts.spectral(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFC5A021)),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1A3A5F)) : null,
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF1A3A5F).withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}