import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/models/orders.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/order_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';

class OrderFormPage extends StatefulWidget {
  final String isbn;
  final String title;
  final String author;
  final String editorial;

  const OrderFormPage({
    super.key,
    required this.isbn,
    required this.title,
    required this.author,
    required this.editorial,
  });

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _editorialController;
  
  String _selectedState = 'Comprado';
  final List<String> _states = ['Comprado', 'En deposito'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _priceController = TextEditingController();
    _titleController = TextEditingController(text: widget.title);
    _authorController = TextEditingController(text: widget.author);
    _editorialController = TextEditingController(text: widget.editorial);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _editorialController.dispose();
    super.dispose();
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
              Text("DETALLES DEL PEDIDO", style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F))),
              const SizedBox(height: 20),
              
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInlineEditField("Título", _titleController),
                      _buildInlineEditField("Autor", _authorController),
                      Text("ISBN: ${widget.isbn}"),
                      _buildInlineEditField("Editorial", _editorialController),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Cantidad", _quantityController, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Estado Compra", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedState,
                              isExpanded: true,
                              items: _states.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                              onChanged: (val) => setState(() => _selectedState = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField("Precio por unidad (€)", _priceController, keyboardType: TextInputType.number),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("CONFIRMAR PEDIDO", style: GoogleFonts.spectral(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFC5A021))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineEditField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: label == "Título" ? GoogleFonts.spectral(fontSize: 18, fontWeight: FontWeight.bold) : null,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final bookshopProvider = context.read<BookshopProvider>();
      
      final order = OrderModel(
        isbn: widget.isbn,
        bookTitle: _titleController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        date: DateTime.now(),
        state: _selectedState,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        idEditorial: "N/A", 
        editorialName: _editorialController.text,
        idBookshop: bookshopProvider.bookshopId ?? "N/A",
      );

      final successId = await OrderService().addOrder(order);

      if (mounted) {
        setState(() => _isSaving = false);
        if (successId != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido realizado con éxito')));
          Navigator.of(context).pop(true); // Retornamos true para indicar éxito
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al realizar el pedido')));
        }
      }
    }
  }
}
