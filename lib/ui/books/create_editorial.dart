import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/models/editorial.dart';
import 'package:thot_tfg_2025_26/services/editorial_service.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';

class CreateEditorialPage extends StatefulWidget {
  const CreateEditorialPage({super.key});

  @override
  State<CreateEditorialPage> createState() => _CreateEditorialPageState();
}

class _CreateEditorialPageState extends State<CreateEditorialPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _daysController = TextEditingController(text: '30');
  bool _isLoading = false;
  final editorialService = EditorialService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _saveEditorial() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final editorial = Editorial(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          days_min_return: int.parse(_daysController.text),
        );

        final editorialId = await editorialService.addEditorial(editorial);

        if(editorialId == null){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear editorial')),
          );
          Navigator.pop(context);
        }else{
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Editorial creada correctamente')),
            );
            Navigator.pop(context, _nameController.text);
          }
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear editorial: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
                    "NUEVA EDITORIAL",
                    style: GoogleFonts.cinzel(
                      fontSize: 24,
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
              const SizedBox(height: 30),
              _buildTextField("Nombre", _nameController, icon: Icons.business),
              _buildTextField("Teléfono", _phoneController, icon: Icons.phone, keyboardType: TextInputType.phone, isRequired: false),
              _buildTextField(
                "Email", 
                _emailController, 
                icon: Icons.email, 
                keyboardType: TextInputType.emailAddress, 
                isRequired: false,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Introduce un email válido';
                    }
                  }
                  return null;
                },
              ),
              _buildTextField("Días devolución", _daysController, icon: Icons.calendar_today, keyboardType: TextInputType.number),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEditorial,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("GUARDAR EDITORIAL"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType keyboardType = TextInputType.text, bool isRequired = true, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? (value) => isRequired && (value == null || value.isEmpty) ? 'Campo requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1A3A5F)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
