import 'package:flutter_sqlite/libros.dart'; // Importa el modelo Libro
import 'package:sqflite/sqflite.dart'; // Importa el paquete SQLite
import 'package:path/path.dart'; // Importa funciones para manejar rutas

class DatabaseHelper { // Clase para manejar la base de datos
  static final DatabaseHelper _instance = DatabaseHelper._internal(); // Instancia única (singleton)
  factory DatabaseHelper () => _instance; // Constructor de fábrica

  static Database? _database; // Variable para almacenar la base de datos

  DatabaseHelper._internal(); // Constructor privado

  Future<Database> get database async { // Getter para obtener la base de datos
    if (_database != null) return _database!; // Si ya está creada, la retorna
    _database = await _initDatabase(); // Si no, la inicializa
    return _database!; // Retorna la base de datos
  }

  Future<Database> _initDatabase() async { // Inicializa la base de datos
    String path = join(await getDatabasesPath(), 'bdlibros.db'); // Ruta del archivo de BD
    return await openDatabase( // Abre la base de datos
      path, // Ruta del archivo
      onCreate: (db, version) { // Callback al crear la BD
        return db.execute( // Ejecuta la creación de tabla
          "CREATE TABLE libros (id INTEGER PRIMARY KEY AUTOINCREMENT, tituloLibro TEXT)", // SQL para crear tabla
        );
      },
      version: 1, // Versión de la base de datos
    );
  }

  Future<void> insertLibro(Libro item) async { // Inserta un libro en la BD
    final db = await database; // Obtiene la BD
    await db.insert('libros', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace); // Inserta el libro
  }

  Future<List<Libro>> getItems () async { // Obtiene todos los libros
    final db = await database; // Obtiene la BD
    final List<Map<String, dynamic>> maps = await db.query('libros'); // Consulta la tabla libros
    return List.generate(maps.length, (i){ // Convierte los resultados en objetos Libro
      return Libro(id: maps[i] ['id'], tituloLibro: maps[i] ['tituloLibro']); // Crea cada objeto Libro
    });
  }

  Future<int> eliminar (String table, {String? where, List<Object?>? whereArgs}) async { // Elimina registros
    final db = await _initDatabase (); // Obtiene la BD
    return await db.delete(table, where: where, whereArgs: whereArgs); // Ejecuta la eliminación
  }

  Future <int> actualizar(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async{ // Actualiza registros
    final db = await _initDatabase(); // Obtiene la BD
    return await db.update(table, values, where: where, whereArgs: whereArgs); // Ejecuta la actualización
  }
}