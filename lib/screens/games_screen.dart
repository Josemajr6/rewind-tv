import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/firestore_service.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color verde neón para los Juegos
    const Color colorJuegos = Color(0xFF00FF66);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213), // Fondo oscuro retro
      body: StreamBuilder<List<Game>>(
        // Conexión en tiempo real con la colección de Juegos en Firebase
        stream: FirestoreService().getGames(),
        builder: (context, snapshot) {
          // Mientras cargan los datos, mostramos un indicador circular
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorJuegos),
            );
          }

          final games = snapshot.data!;

          return ListView.builder(
            itemCount: games.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, i) {
              final game = games[i];

              // Diseño de cada tarjeta de juego
              return Card(
                color: Colors.white.withOpacity(0.05), // Fondo sutil
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: colorJuegos,
                    width: 0.5,
                  ), // Borde neón
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.gamepad, color: colorJuegos),
                  title: Text(
                    game.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${game.plataforma} • ${game.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  // Botones de acción unificados (Editar y Borrar)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _dialogoEditar(context, game),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () =>
                            FirestoreService().deleteGame(game.id!),
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

  // --- FUNCIÓN PARA MOSTRAR EL DIÁLOGO DE EDICIÓN ---
  void _dialogoEditar(BuildContext context, Game game) {
    final t1 = TextEditingController(text: game.titulo);
    String plat = game.plataforma;
    int nota = game.puntuacion;

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
              // Campo para el título
              TextField(
                controller: t1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 10),
              // Selector de Plataforma
              DropdownButton<String>(
                value: plat,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FF66)),
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plat = v!),
              ),
              // Selector de Nota
              DropdownButton<int>(
                value: nota,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FF66)),
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
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
                // Llamamos al servicio para actualizar en Firebase
                FirestoreService().updateGame(game.id!, {
                  'titulo': t1.text,
                  'plataforma': plat,
                  'puntuacion': nota,
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
}
