import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/firestore_service.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorJuegos = Color(0xFF00FF66); // Verde neón

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: StreamBuilder<List<Game>>(
        // Obtener juegos en tiempo real desde Firestore
        stream: FirestoreService().getGames(),
        builder: (context, snapshot) {
          // Mostrar indicador de carga mientras se obtienen los datos
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorJuegos),
            );
          }

          final juegos = snapshot.data!;

          // Si no hay juegos, mostrar mensaje
          if (juegos.isEmpty) {
            return const Center(
              child: Text(
                'NO HAY JUEGOS.\nPULSA + PARA AÑADIR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          // Lista de juegos
          return ListView.builder(
            itemCount: juegos.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final juego = juegos[index];

              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: colorJuegos, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  // Icono de juego
                  leading: const Icon(Icons.gamepad, color: colorJuegos),

                  // Título del juego
                  title: Text(
                    juego.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Plataforma y puntuación
                  subtitle: Text(
                    "${juego.plataforma} • ${juego.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // Botones de editar y eliminar
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: colorJuegos),
                        onPressed: () => _mostrarDialogoEditar(context, juego),
                      ),

                      // Botón eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmarEliminar(context, juego),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ========== DIÁLOGO PARA EDITAR JUEGO ==========
  void _mostrarDialogoEditar(BuildContext context, Game juego) {
    final controladorTitulo = TextEditingController(text: juego.titulo);
    String plataformaSeleccionada = juego.plataforma;
    int notaSeleccionada = juego.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "EDITAR JUEGO",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de título
              TextField(
                controller: controladorTitulo,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Selector de plataforma
              DropdownButtonFormField<String>(
                value: plataformaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FF66)),
                decoration: const InputDecoration(
                  labelText: "Plataforma",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map(
                      (plataforma) => DropdownMenuItem(
                        value: plataforma,
                        child: Text(plataforma),
                      ),
                    )
                    .toList(),
                onChanged: (valor) =>
                    setState(() => plataformaSeleccionada = valor!),
              ),
              const SizedBox(height: 15),

              // Selector de puntuación
              DropdownButtonFormField<int>(
                value: notaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FF66)),
                decoration: const InputDecoration(
                  labelText: "Puntuación",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (nota) => DropdownMenuItem(
                        value: nota,
                        child: Text("Nota: $nota"),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => notaSeleccionada = valor!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Actualizar juego en Firestore
                FirestoreService().updateGame(juego.id!, {
                  'titulo': controladorTitulo.text,
                  'plataforma': plataformaSeleccionada,
                  'puntuacion': notaSeleccionada,
                });
                Navigator.pop(context);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // ========== CONFIRMAR ANTES DE ELIMINAR ==========
  void _confirmarEliminar(BuildContext context, Game juego) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0225),
        title: const Text(
          "CONFIRMAR ELIMINACIÓN",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "¿Eliminar '${juego.titulo}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Eliminar juego de Firestore
              FirestoreService().deleteGame(juego.id!);
              Navigator.pop(context);
            },
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
