import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'agendar_cita_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(context),
      const MessagesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('¡Hola, $displayName! ¿En qué podemos ayudarte?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Row: Agendar cita / Consejos médicos
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.calendar_month,
                  title: 'Agendar una cita',
                  subtitle: 'Selecciona fecha y especialista',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AgendarCitaPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.medical_information,
                  title: 'Consejos médicos',
                  subtitle: 'Alivio inmediato y cuidados',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Consejos médicos'),
                        content: const Text('Consejos básicos: hidratar, reposo, analgésicos si es necesario...'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Especialistas (lista vertical con iconos)
          const Text('Especialistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _doctorTile(Icons.person, 'Dr. Juan Pérez - Médico General'),
              _doctorTile(Icons.child_care, 'Dra. Ana Gómez - Pediatría'),
              _doctorTile(Icons.favorite, 'Dr. Carlos Ruiz - Cardiología'),
              _doctorTile(Icons.face, 'Dra. Laura Fernández - Dermatología'),
              _doctorTile(Icons.accessibility, 'Dr. Miguel Torres - Ortopedia'),
            ],
          ),
          const SizedBox(height: 24),

          // Servicios destacados
          const Text('Servicios destacados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Consulta rápida'),
              subtitle: const Text('Consulta breve para problemas leves'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _doctorTile(IconData icon, String nombre) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(nombre),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Has seleccionado a $nombre')),
          );
        },
      ),
    );
  }
}
