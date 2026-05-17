import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/models/book.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/services/editorial_service.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/books/bookstock_form.dart';
import 'package:thot_tfg_2025_26/ui/books/create_editorial.dart';
import 'package:thot_tfg_2025_26/ui/widgets/navegationBarThot.dart';
import 'package:thot_tfg_2025_26/utils/validators.dart';

class BookForm extends StatefulWidget {
  final String? isbn;

  const BookForm({super.key, this.isbn});

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();
  final _editorialService = EditorialService();

  
  late TextEditingController _isbnController;
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _editorialController = TextEditingController();
  
  String? _editorialId;
  double _generatedPrice = 0.0;
  bool _isAutoFilling = false;
  String? _nameEditorial;

  @override
  void initState() {
    super.initState();
    _isbnController = TextEditingController(text: widget.isbn ?? '');
    if (widget.isbn != null && widget.isbn!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchBookData(widget.isbn!);
      });
    }
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _editorialController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookData(String isbn) async {
    if (isbn.isEmpty) return;
    
    setState(() => _isAutoFilling = true);
    
    try {
      // 1. Intentar buscar primero en nuestra base de datos (Firebase)
      final existingBook = await _bookService.getBook(isbn);

      if (existingBook != null && mounted) {
        _titleController.text = existingBook.title;
        _authorController.text = existingBook.author;
        _categoryController.text = existingBook.category;
        _generatedPrice = existingBook.price;

        // Si tiene editorial, intentar obtener su nombre/ID
        if (existingBook.id_editorial != null && existingBook.id_editorial!.isNotEmpty) {
           _editorialId = existingBook.id_editorial;
           final editorial = await EditorialService().getEditorial(_editorialId!);
           _editorialController.text = editorial!.name;
           _nameEditorial = editorial.name;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro encontrado')),
        );
        return; // Salimos si lo encontramos en la BD
      }

      // 2. Si no está en BD, llamar a las APIs externas
      final data = await _bookService.fetchBookData(isbn);

      if (data != null && mounted) {
        _titleController.text = data['title'] ?? '';
        _authorController.text = data['author'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _editorialController.text = data['editorial'] ?? '';
        _generatedPrice = data['price'] ?? 0.0;
        _nameEditorial = _editorialController.text;
        _editorialId = data['editorial'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos autocompletados')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron datos para este ISBN')),
        );
      }
    } catch (e) {
      print("Error fetching book data: $e");
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }



  void _showEditorialSearch() async {
    String searchText = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFFFDF5E6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "BUSCAR EDITORIAL",
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A3A5F),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      onChanged: (value) {
                        setModalState(() {
                          searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Escribe al menos 3 letras...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3A5F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateEditorialPage()),
                        );
                        if (result != null && mounted) {
                          // Suponiendo que result es el nombre de la editorial
                          final id = await _editorialService.checkAndGetEditorialId(result);
                          setState(() {
                            _editorialController.text = result;
                            _editorialId = id;
                          });
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC5A021)),
                      label: Text(
                        "CREAR NUEVA EDITORIAL",
                        style: GoogleFonts.spectral(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A3A5F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: searchText.length < 3
                    ? FirebaseService.firestore.collection('editorials').limit(10).snapshots()
                    : FirebaseService.firestore.collection('editorials')
                        .where('name', isGreaterThanOrEqualTo: searchText)
                        .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
                        .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "No se encontró la editorial",
                                style: GoogleFonts.spectral(fontSize: 16),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CreateEditorialPage()),
                                  );
                                  if (result != null && mounted) {
                                    final id = await _editorialService.checkAndGetEditorialId(result);
                                    setState(() {
                                      _editorialController.text = result;
                                      _editorialId = id;
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("AÑADIR EDITORIAL"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        return ListTile(
                          title: Text(data['name'] ?? 'Sin nombre', style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
                          leading: const Icon(Icons.business, color: Color(0xFFC5A021)),
                          onTap: () {
                            setState(() {
                              _editorialController.text = data['name'];
                              _editorialId = docs[index].id;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // Papiro
      appBar: const ThotAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Información del Libro"),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF1A3A5F)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  _buildTextField(
                    "ISBN", 
                    _isbnController, 
                    icon: Icons.qr_code, 
                    suffixIcon: Icons.search,
                    onSuffixPressed: () => _fetchBookData(_isbnController.text),
                    onSubmitted: (value) => _fetchBookData(value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      if (!Validators.validateISBN(value)) return 'ISBN no válido (13 dígitos)';
                      return null;
                    },
                  ),
                  _buildTextField("Título", _titleController, icon: Icons.book),
                  _buildTextField("Autor", _authorController, icon: Icons.person),
                  _buildTextField("Categoría", _categoryController, icon: Icons.category),
                  _buildTextField(
                    "Editorial", 
                    _editorialController, 
                    icon: Icons.business,
                    suffixIcon: Icons.search,
                    onSuffixPressed: _showEditorialSearch,
                  ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _goToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A5F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "SIGUIENTE",
                        style: GoogleFonts.spectral(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC5A021),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isAutoFilling)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: ThotNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.pop(context);
        },
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

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool enabled = true, TextInputType keyboardType = TextInputType.text, IconData? suffixIcon, VoidCallback? onSuffixPressed, Function(String)? onSubmitted, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            onFieldSubmitted: onSubmitted,
            validator: validator ?? (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1A3A5F)) : null,
              suffixIcon: suffixIcon != null ? IconButton(
                icon: Icon(suffixIcon, color: const Color(0xFFC5A021)),
                onPressed: onSuffixPressed,
              ) : null,
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF1A3A5F)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNext() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        isbn: _isbnController.text,
        title: _titleController.text,
        author: _authorController.text,
        category: _categoryController.text,
        price: _generatedPrice > 0 ? _generatedPrice : 15.0,
        id_editorial: _editorialId, // Pasamos el ID o el Nombre
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookStockForm(book: book, nameEditorial: _nameEditorial!),
          ),
        );
      }
    }
  }
}
