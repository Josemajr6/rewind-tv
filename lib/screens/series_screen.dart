import 'package:flutter/material.dart';
import '../models/serie_model.dart';
import '../services/firestore_service.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color magenta = Color(0xFFFF00FF);
    const Color cian = Color(0xFF00FFFF);

    return StreamBuilder<List<Serie>>(
      stream: FirestoreService().getSeries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: magenta));
        }
        final series = snapshot.data!;
        return ListView.builder(
          itemCount: series.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final s = series[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: magenta),
                boxShadow: const [
                  BoxShadow(color: cian, offset: Offset(-3, 3)),
                ],
              ),
              child: ListTile(
                onTap: () =>
                    Navigator.pushNamed(context, '/serie-detail', arguments: s),
                title: Text(
                  s.titulo.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("${s.genero} • ${s.puntuacion}/10"),
              ),
            );
          },
        );
      },
    );
  }
}
