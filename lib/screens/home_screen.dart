import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/serie_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cian = Color(0xFF00FFFF);
    const Color magenta = Color(0xFFFF00FF);

    final user = AuthService().currentUser;
    final String nombreUsuario =
        (user?.displayName?.split(" ")[0] ?? "INVITADO").toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        // 1. SALUDO A LA IZQUIERDA
        leadingWidth: 120,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              " HOLA, $nombreUsuario",
              style: const TextStyle(
                color: cian,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // 2. LOGO EN EL MEDIO
        title: Image.asset('assets/logo.png', height: 35),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: magenta),
            onPressed: () => AuthService().signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Serie>>(
        stream: FirestoreService().getSeries(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator(color: cian));

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
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/serie-detail',
                    arguments: s,
                  ),
                  title: Text(
                    s.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  subtitle: Text(
                    "${s.genero} | NOTA: ${s.puntuacion}/10",
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: cian),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: magenta,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/add-serie'),
      ),
    );
  }
}
