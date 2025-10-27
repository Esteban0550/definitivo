import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de añadir 'intl' a tu pubspec.yaml

// --- 1. Modelo de Datos para la Cita ---
// Usar una clase hace que el manejo de datos sea más limpio y seguro.
class Cita {
  final String especialista;
  final String especialidad;
  final DateTime fechaHora;
  final String estado; // Ejemplo: 'Confirmada', 'Cancelada', 'Completada'
  final String avatarUrl; // URL para la foto del doctor

  Cita({
    required this.especialista,
    required this.especialidad,
    required this.fechaHora,
    required this.estado,
    required this.avatarUrl,
  });
}

// --- 2. Página Principal de Citas (StatefulWidget) ---
// Es un StatefulWidget para poder manejar el estado de las pestañas.
class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Datos de Ejemplo ---
  // En una app real, estos datos vendrían de Firebase o una API.
  final List<Cita> _proximasCitas = [
    Cita(
      especialista: 'Dr. Juan Pérez',
      especialidad: 'Medicina General',
      fechaHora: DateTime.now().add(const Duration(days: 3, hours: 5)),
      estado: 'Confirmada',
      avatarUrl: 'https://via.placeholder.com/150/FFC107/000000?Text=JP',
    ),
    Cita(
      especialista: 'Dr. Carlos Ruiz',
      especialidad: 'Cardiología',
      fechaHora: DateTime.now().add(const Duration(days: 10, hours: 2)),
      estado: 'Confirmada',
      avatarUrl: 'https://via.placeholder.com/150/F44336/FFFFFF?Text=CR',
    ),
  ];

  final List<Cita> _citasAnteriores = [
    Cita(
      especialista: 'Dra. Ana Gómez',
      especialidad: 'Pediatría',
      fechaHora: DateTime.now().subtract(const Duration(days: 20)),
      estado: 'Completada',
      avatarUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?Text=AG',
    ),
    Cita(
      especialista: 'Dra. Laura Fernández',
      especialidad: 'Dermatología',
      fechaHora: DateTime.now().subtract(const Duration(days: 45)),
      estado: 'Completada',
      avatarUrl: 'https://via.placeholder.com/150/2196F3/FFFFFF?Text=LF',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador para las 2 pestañas.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Anteriores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vista para citas próximas
          _buildCitasList(_proximasCitas, esProxima: true),
          // Vista para citas anteriores
          _buildCitasList(_citasAnteriores, esProxima: false),
        ],
      ),
    );
  }

  /// Construye la lista de citas o un mensaje si la lista está vacía.
  Widget _buildCitasList(List<Cita> citas, {required bool esProxima}) {
    if (citas.isEmpty) {
      return _buildEmptyState(
          esProxima ? 'No tienes citas próximas.' : 'No tienes citas anteriores.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        return _buildCitaCard(citas[index], esProxima: esProxima);
      },
    );
  }

  /// Widget reutilizable para mostrar una tarjeta de cita.
  Widget _buildCitaCard(Cita cita, {required bool esProxima}) {
    // Formateador de fecha y hora para una mejor presentación.
    final String fechaFormateada = DateFormat('EEEE, d MMMM, y', 'es_ES').format(cita.fechaHora);
    final String horaFormateada = DateFormat('h:mm a').format(cita.fechaHora);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(cita.avatarUrl),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cita.especialista, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(cita.especialidad, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[700], size: 16),
                const SizedBox(width: 8),
                Text(fechaFormateada, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[700], size: 16),
                const SizedBox(width: 8),
                Text(horaFormateada, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 20),

            // --- Botones de Acción ---
            // Los botones cambian dependiendo de si la cita es próxima o anterior.
            if (esProxima)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () { /* Lógica para cancelar */ },
                    child: const Text('Cancelar Cita'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () { /* Lógica para ver detalles */ },
                    child: const Text('Ver Detalles'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text(cita.estado),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(color: Colors.green[800]),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Widget para mostrar cuando no hay citas en una lista.
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}