import 'package:flutter/material.dart'; // Importa el paquete de UI de Flutter
import 'package:flutter_sqlite/database_helper.dart'; // Importa el helper para la base de datos SQLite
import 'libros.dart'; // Importa el modelo de datos Libro

void main() { // Función principal
  runApp(const MyApp()); // Inicia la aplicación
}

class MyApp extends StatelessWidget { // Widget principal sin estado
  const MyApp ({super.key}); // Constructor con clave

  @override
  Widget build (BuildContext context) { // Método build para construir la interfaz
    return MaterialApp( // Retorna la aplicación
      title: 'Flutter Demo', // Título de la app
      theme: ThemeData( // Define el tema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Paleta de colores
        useMaterial3: true, // Usa Material Design 3
      ),
      home: const MyHomePage(), // Página principal
    );
  }
}

class MyHomePage extends StatefulWidget { // Widget con estado
  const MyHomePage({super.key}); // Constructor

  @override 
  State<MyHomePage> createState() => _MyHomePageState (); // Crea el estado
}

class _MyHomePageState extends State<MyHomePage> { // Clase del estado
  final DatabaseHelper _dbHelper =DatabaseHelper (); // Instancia del helper de BD
  final TextEditingController _EditTituloLibro = TextEditingController(); // Controlador de texto
  List<Libro> _items = []; // Lista de libros

  @override 
  void initState() { // Inicializa el estado
    super.initState (); // Llama al initState padre
    _cargarListaLibros (); // Carga los libros
  }

  Future<void> _cargarListaLibros() async { // Método para cargar libros
    final items = await _dbHelper.getItems (); // Obtiene los libros de la BD
    setState(() { // Actualiza el estado
      _items = items; // Asigna los libros
    });
  }

  void _agregarNuevoLibro(String tituloLibro) async { // Agrega un nuevo libro
    final nuevoLibro = Libro(tituloLibro: tituloLibro); // Crea el objeto libro
    await _dbHelper.insertLibro(nuevoLibro); // Inserta en la BD
    print("SE AGREGO EL NUEVO LIBRO"); // Mensaje en consola
    _cargarListaLibros(); // Recarga la lista
  }

  void _mostrarVentanaAgregar() { // Muestra diálogo para agregar libro
    showDialog( // Muestra ventana emergente
        context: context, // Contexto actual
        builder: (context) { // Constructor del diálogo
          return AlertDialog( // Diálogo de alerta
            title: const Text("Agregar Titulo"), // Título del diálogo
            content: TextField( // Campo de texto
              controller: _EditTituloLibro, // Controlador del campo
              decoration: const InputDecoration(hintText: "Ingrese el Titulo"), // Placeholder
            ),
            actions: [ // Botones del diálogo
              TextButton( // Botón de acción
                onPressed:(){ // Acción al presionar
                  if(_EditTituloLibro.text!.isNotEmpty){ // Verifica si hay texto
                    _agregarNuevoLibro(_EditTituloLibro.text.toString()); // Agrega libro
                    Navigator.of(context).pop(); // Cierra el diálogo
                  }
                },
                child: Text("Agregar")) // Texto del botón
            ],
          );
        }
    );
  }

  void _eliminarLibro(int id) async { // Elimina un libro por ID
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]); // Ejecuta eliminación
    _cargarListaLibros(); // Recarga la lista
  }

  void _mostrarMensajeModificar (int id) { // Muestra confirmación de eliminación
    showDialog( // Muestra diálogo
      context: context, // Contexto actual
      builder: (context) { // Constructor del diálogo
        return AlertDialog( // Diálogo de alerta
          title: Text("Confirmar eliminacion"), // Título del diálogo
          content: Text("Estas seguro de que quieres eliminar este libro?"), // Mensaje
          actions: [ // Botones
            TextButton( // Botón cancelar
              onPressed: () { // Acción al presionar
                _eliminarLibro(id); // Elimina el libro
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Cancelar"), // Texto del botón
            ),
            TextButton( // Botón eliminar
              onPressed: () { // Acción al presionar
                _eliminarLibro(id); // Elimina el libro
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Eliminar"), // Texto del botón
            ),
          ],
        );
      },
    );
  }

  void _actualizarLibro (int id, String nuevoTitulo) async { // Actualiza el título
    await _dbHelper.actualizar( // Ejecuta actualización
      'libros', // Tabla
      {'tituloLibro': nuevoTitulo}, // Nuevo valor
      where: 'id = ?', // Condición
      whereArgs: [id], // Argumento
    );
    _cargarListaLibros(); // Recarga la lista
  }

  void _ventanaEditar (int id, String tituloActual) { // Muestra diálogo para editar
    TextEditingController _tituloController = TextEditingController(text: tituloActual); // Controlador con texto inicial
    showDialog( // Muestra diálogo
      context: context, // Contexto actual
      builder: (context) { // Constructor del diálogo
        return AlertDialog( // Diálogo de alerta
          title: Text("Modificar Titulo del Libro"), // Título del diálogo
          content: TextField( // Campo de texto
            controller: _tituloController, // Controlador del campo
            decoration: InputDecoration( // Decoración del campo
              hintText: "Escribe el nuevo titulo", // Placeholder
            ),
          ),
          actions: [ // Botones
            TextButton( // Botón cancelar
              onPressed: () { // Acción al presionar
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Cancelar"), // Texto del botón
            ),
            TextButton( // Botón guardar
              onPressed: () { // Acción al presionar
                if (_tituloController.text!.isNotEmpty){ // Verifica si hay texto
                  _actualizarLibro(id, _tituloController.text.toString()); // Actualiza libro
                }
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Guardar"), // Texto del botón
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) { // Construye la interfaz
    return Scaffold( // Estructura principal
      appBar: AppBar( // Barra superior
        title: Text("SqlLite Flutter"), // Título de la app
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Color de fondo
      ),
      body: ListView.separated( // Lista con separadores
        itemCount: _items.length, // Cantidad de elementos
        separatorBuilder: (context, index) => Divider(), // Separador entre ítems
        itemBuilder: (context, index) { // Constructor de cada ítem
          final libro = _items[index]; // Obtiene el libro actual
          return ListTile( // Elemento de lista
            title: Text(libro.tituloLibro), // Muestra el título
            subtitle: Text('ID: ${libro.id}'), // Muestra el ID
            trailing: IconButton( // Botón de eliminar
              icon: Icon (Icons.delete, color: Colors.grey), // Ícono de basura
              onPressed: () { // Acción al presionar
                _mostrarMensajeModificar(int.parse(libro.id.toString())); // Muestra confirmación
              },
            ),
            onTap: () { // Acción al tocar el ítem
              _ventanaEditar(int.parse(libro.id.toString()), libro.tituloLibro); // Muestra edición
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton( // Botón flotante
        onPressed: _mostrarVentanaAgregar, // Acción al presionar
        child: Icon(Icons.add), // Ícono de agregar
      ),
    );
  }
}