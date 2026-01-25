import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/serie_model.dart';
import '../models/episode_model.dart';
import '../services/firestore_service.dart';

class SerieDetailScreen extends StatelessWidget {
  const SerieDetailScreen({super.key});

  static const Color cian = Color(0xFF00FFFF);
  static const Color magenta = Color(0xFFFF00FF);

  @override
  Widget build(BuildContext context) {
    final serieCargada = ModalRoute.of(context)!.settings.arguments as Serie;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: cian),
            onPressed: () => _dialogoSerie(context, serieCargada),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => _borrarSerie(context, serieCargada.id!),
          ),
        ],
      ),
      body: Column(
        children: [
          // CABECERA DE LA SERIE (Reseña y datos generales)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('series')
                .doc(serieCargada.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final s = Serie.fromFirestore(snapshot.data!);
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: magenta, width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.titulo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "GÉNERO: ${s.genero} • NOTA: ${s.puntuacion}/10",
                      style: const TextStyle(color: cian, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.resena,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // LISTA DE CAPÍTULOS
          Expanded(
            child: StreamBuilder<List<Episode>>(
              stream: FirestoreService().getEpisodes(serieCargada.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final lista = snapshot.data!;
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final ep = lista[index];
                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: ListTile(
                        onTap: () => _dialogoEpisodio(
                          context,
                          serieCargada.id!,
                          episodio: ep,
                        ),
                        leading: Text(
                          "#${ep.numero}",
                          style: const TextStyle(
                            color: magenta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(
                          ep.titulo,
                          style: const TextStyle(
                            color: cian,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "NOTA: ${ep.puntuacion}/10\n${ep.resena}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white24,
                          ),
                          onPressed: () =>
                              FirestoreService().deleteEpisode(ep.id!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: magenta,
        child: const Icon(Icons.add_comment, color: Colors.white),
        onPressed: () => _dialogoEpisodio(context, serieCargada.id!),
      ),
    );
  }

  // --- DIÁLOGO PARA AÑADIR O EDITAR CAPÍTULO CON VALIDACIÓN REAL ---
  void _dialogoEpisodio(
    BuildContext context,
    String idSerie, {
    Episode? episodio,
  }) {
    final _formKeyEp =
        GlobalKey<FormState>(); // Llave para el control de errores
    final tNom = TextEditingController(text: episodio?.titulo ?? "");
    final tRes = TextEditingController(text: episodio?.resena ?? "");
    final tNum = TextEditingController(text: episodio?.numero.toString() ?? "");
    int nota = episodio?.puntuacion ?? 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: Text(
            episodio == null ? "NUEVO CAPÍTULO" : "EDITAR CAPÍTULO",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKeyEp, // Envolvemos en un Form
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CAMPO NÚMERO CON VALIDACIÓN DE LETRAS
                  TextFormField(
                    controller: tNum,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nº Capítulo",
                      labelStyle: TextStyle(color: cian),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Pon un número";
                      if (int.tryParse(value) == null)
                        return "¡Solo números!"; // Si no es número, sale aviso
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: tNom,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nombre del episodio",
                      labelStyle: TextStyle(color: cian),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Pon un nombre"
                        : null,
                  ),
                  TextFormField(
                    controller: tRes,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Tu reseña",
                      labelStyle: TextStyle(color: cian),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButton<int>(
                    value: nota,
                    dropdownColor: const Color(0xFF1A0225),
                    style: const TextStyle(color: cian),
                    items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                        .map(
                          (n) => DropdownMenuItem(
                            value: n,
                            child: Text("Nota: $n"),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => nota = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: magenta),
              onPressed: () {
                // Si el formulario detecta errores, no sigue
                if (_formKeyEp.currentState!.validate()) {
                  final epData = Episode(
                    titulo: tNom.text,
                    numero: int.parse(tNum.text),
                    puntuacion: nota,
                    resena: tRes.text,
                    serieId: idSerie,
                  );

                  if (episodio == null) {
                    FirestoreService().addEpisode(epData);
                  } else {
                    FirestoreService().updateEpisode(episodio.id!, {
                      'titulo': tNom.text,
                      'numero': int.parse(tNum.text),
                      'puntuacion': nota,
                      'resena': tRes.text,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGOS DE SERIE ---
  void _dialogoSerie(BuildContext context, Serie s) {
    final tTit = TextEditingController(text: s.titulo);
    final tRes = TextEditingController(text: s.resena);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0225),
        title: const Text("EDITAR SERIE"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tTit,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: tRes,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Reseña"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              FirestoreService().updateSerie(s.id!, {
                'titulo': tTit.text,
                'resena': tRes.text,
              });
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _borrarSerie(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0225),
        title: const Text("¿BORRAR SERIE?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirestoreService().deleteSerie(id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("SÍ"),
          ),
        ],
      ),
    );
  }
}
