class Adapter {

  static String convertInQueryOpenLibrary(String isbn, String title, String author, String editorial, {int limit = 20}) {
    List<String> queryParts = [];

    // Función auxiliar para procesar los campos: trim y sustituir espacios por '+'
    String process(String value) => value.trim().replaceAll(' ', '+');

    if (isbn.isNotEmpty) {
      queryParts.add('isbn=${process(isbn)}');
    }

    if (title.isNotEmpty) {
      queryParts.add('title=${process(title)}');
    }

    if (author.isNotEmpty) {
      queryParts.add('author=${process(author)}');
    }

    if (editorial.isNotEmpty) {
      queryParts.add('publisher=${process(editorial)}');
    }

    // Añadir el límite de resultados
    queryParts.add('limit=$limit');

    return queryParts.join('&');
  }

  static String convertInQueryGoogleBooks(String isbn, String title, String author, String editorial, {int limit = 10}) {
    List<String> queryParts = [];

    String process(String value) => value.trim().replaceAll(' ', '+');

    if (isbn.isNotEmpty) {
      queryParts.add('isbn:${process(isbn)}');
    }

    if (title.isNotEmpty) {
      queryParts.add('intitle:${process(title)}');
    }

    if (author.isNotEmpty) {
      queryParts.add('inauthor:${process(author)}');
    }

    if (editorial.isNotEmpty) {
      queryParts.add('inpublisher:${process(editorial)}');
    }

    // En Google Books, los términos de búsqueda van dentro del parámetro 'q' unidos por '+'
    // y el límite se define con 'maxResults'
    String query = queryParts.join('+');
    return 'q=$query&maxResults=$limit';
  }
}
