class Libro { // Clase modelo para representar un libro
  int? id; // Identificador único del libro (puede ser nulo)
  String tituloLibro; // Título del libro

  Libro({this.id, required this.tituloLibro}); // Constructor con parámetros

  Map<String, dynamic> toMap () { // Convierte el objeto a un mapa para la BD
    return { // Retorna el mapa con los datos
      'id': id, // Clave 'id' con su valor
      'tituloLibro' : tituloLibro, // Clave 'tituloLibro' con su valor
    };
  }
}