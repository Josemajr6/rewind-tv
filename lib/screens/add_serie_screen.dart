import 'package:flutter/material.dart';
import '../models/serie_model.dart';
import '../services/firestore_service.dart';

class AddSerieScreen extends StatefulWidget {
  const AddSerieScreen({super.key});

  @override
  State<AddSerieScreen> createState() => _AddSerieScreenState();
}

class _AddSerieScreenState extends State<AddSerieScreen> {
  // Clave global para validar el formulario (Punto obligatorio de la rúbrica)
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _resenaController = TextEditingController();

  // Listas "normales" de géneros y notas
  final List<String> _generos = [
    'Acción',
    'Comedia',
    'Drama',
    'Terror',
    'Ciencia Ficción',
    'Suspenso',
  ];
  final List<int> _notas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Valores por defecto (IMPORTANTE: Deben existir en las listas de arriba)
  String _generoSeleccionado = 'Acción';
  int _notaSeleccionada = 5;

  @override
  Widget build(BuildContext context) {
    const Color cian = Color(0xFF00FFFF);
    const Color magenta = Color(0xFFFF00FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "NUEVA CINTA VHS",
          style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: cian),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("NOMBRE DE LA SERIE"),
              TextFormField(
                controller: _tituloController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle("Ej: Corrupción en Miami"),
                // VALIDACIÓN: No permite guardar si el campo está vacío
                validator: (val) =>
                    val == null || val.isEmpty ? "Escribe un título" : null,
              ),
              const SizedBox(height: 20),

              _label("RESEÑA / COMENTARIO"),
              TextFormField(
                controller: _resenaController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle("¿Qué tal la serie?"),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // DESPLEGABLE GÉNERO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("GÉNERO"),
                        DropdownButtonFormField<String>(
                          value: _generoSeleccionado,
                          dropdownColor: const Color(0xFF1A0225),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputStyle(""),
                          items: _generos
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _generoSeleccionado = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // DESPLEGABLE NOTA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("NOTA"),
                        DropdownButtonFormField<int>(
                          value: _notaSeleccionada,
                          dropdownColor: const Color(0xFF1A0225),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputStyle(""),
                          items: _notas
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(n.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _notaSeleccionada = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // BOTÓN DE GUARDAR (Neon Magenta)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magenta,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: _procesarGuardado,
                  child: const Text(
                    "GUARDAR EN BASE DE DATOS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _procesarGuardado() async {
    // Si el formulario pasa la validación...
    if (_formKey.currentState!.validate()) {
      final service = FirestoreService();

      await service.addSerie(
        Serie(
          titulo: _tituloController.text,
          resena: _resenaController.text,
          genero: _generoSeleccionado,
          temporadas: 1,
          puntuacion: _notaSeleccionada,
          uidPropietario: service.uid,
        ),
      );

      if (mounted) Navigator.pop(context);
    }
  }

  // Estilos reutilizables para el formulario
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white12),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00FFFF)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF00FFFF),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
