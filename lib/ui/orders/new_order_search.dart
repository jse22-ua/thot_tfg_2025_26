import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/models/book.dart';
import 'package:thot_tfg_2025_26/services/book_service.dart';
import 'package:thot_tfg_2025_26/ui/widgets/appbar.dart';
import 'package:thot_tfg_2025_26/ui/orders/order_form.dart';

class NewOrderSearchPage extends StatefulWidget {
  const NewOrderSearchPage({super.key});

  @override
  State<NewOrderSearchPage> createState() => _NewOrderSearchPageState();
}

class _NewOrderSearchPageState extends State<NewOrderSearchPage> {
  final _bookService = BookService();
  final _isbnController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _editorialController = TextEditingController();
  
  List<dynamic> _results = [];
  bool _isLoading = false;

  Future<void> _performSearch() async {
    final isbn = _isbnController.text.trim();
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final editorial = _editorialController.text.trim();

    if (isbn.isEmpty && title.isEmpty && author.isEmpty && editorial.isEmpty) return;

    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      // 1. BUSCAR EN FIRESTORE
      List<dynamic> firestoreResults = [];
      if (isbn.isNotEmpty) {
        final book = await _bookService.getBook(isbn);
        if (book != null) firestoreResults.add(book);
      }
      
      if (firestoreResults.isEmpty) {
        final query = title.isNotEmpty ? title : (author.isNotEmpty ? author : editorial);
        firestoreResults = await _bookService.searchBooksInFirestore(query);
      }

      if (firestoreResults.isNotEmpty) {
        if (mounted) {
          setState(() {
            _results = firestoreResults;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. SI NO HAY RESULTADOS, BUSCAR EN OPEN LIBRARY
      final openLibraryResults = await _bookService.searchFromOpenLibraryExtended(
        isbn, title, author, editorial, 10
      );

      if (openLibraryResults.isNotEmpty) {
        if (mounted) {
          setState(() {
            _results = openLibraryResults;
            _isLoading = false;
          });
        }
        return;
      }

      // 3. SI SIGUE SIN HABER RESULTADOS, BUSCAR EN GOOGLE BOOKS
      final googleResults = await _bookService.searchFromGoogleBooksExtended(
        isbn, title, author, editorial, 10
      );

      if (mounted) {
        setState(() {
          _results = googleResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error searching: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: const ThotAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text("BUSCAR LIBRO PARA PEDIDO", 
                    style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A3A5F))),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF1A3A5F), size: 28),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchField("ISBN", _isbnController, Icons.qr_code),
                        _buildSearchField("Título", _titleController, Icons.book),
                        _buildSearchField("Autor", _authorController, Icons.person),
                        _buildSearchField("Editorial", _editorialController, Icons.business),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _performSearch,
                            icon: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.search, color: Colors.white),
                            label: Text(_isLoading ? "BUSCANDO..." : "BUSCAR LIBRO", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC5A021),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading && _results.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        String title, author, isbn, editorial;

                        if (item is Book) {
                          title = item.title;
                          author = item.author;
                          isbn = item.isbn ?? 'N/A';
                          editorial = item.id_editorial ?? 'N/A';
                        } else {
                          title = item['title'] ?? 'Sin título';
                          author = item['author'] ?? 'Autor desconocido';
                          isbn = item['isbn'] ?? 'N/A';
                          editorial = item['editorial'] ?? 'Editorial desconocida';
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.book, color: Color(0xFF1A3A5F)),
                            title: Text(title, style: GoogleFonts.spectral(fontWeight: FontWeight.bold)),
                            subtitle: Text("$author | $editorial"),
                            trailing: const Icon(Icons.add_shopping_cart, color: Color(0xFFC5A021)),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderFormPage(
                                    isbn: isbn,
                                    title: title,
                                    author: author,
                                    editorial: editorial,
                                  ),
                                ),
                              );
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  if (_results.isEmpty && !_isLoading && (_isbnController.text.isNotEmpty || _titleController.text.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text("¿No encuentras el libro?"),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderFormPage(
                                    isbn: _isbnController.text,
                                    title: _titleController.text,
                                    author: _authorController.text,
                                    editorial: _editorialController.text,
                                  ),
                                ),
                              );
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                            icon: const Icon(Icons.edit_note),
                            label: const Text("Introducir datos manualmente"),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1A3A5F)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF1A3A5F).withOpacity(0.2)),
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }
}
