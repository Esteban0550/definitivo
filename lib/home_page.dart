import 'package:flutter/material.dart'; // Importa widgets visuales de Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Para manejar la autenticación de Firebase
import 'messages_page.dart'; // Página de mensajes
import 'settings_page.dart'; // Página de configuración
import 'agendar_cita_page.dart'; // Página para agendar citas
import 'citas_page.dart'; // Página que muestra citas
import 'screens/appointments_list_screen.dart'; // Pantalla de lista de citas

// Widget principal de la página de inicio
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

// Estado de la HomePage (donde se maneja la lógica)
class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Controla qué pestaña está seleccionada en el BottomNavigationBar
  final User? user = FirebaseAuth.instance.currentUser; // Usuario actual autenticado

  @override
  Widget build(BuildContext context) {
    // Lista de páginas que cambian según el índice actual
    final pages = [
      _buildHomeContent(context), // Página principal
      const MessagesPage(), // Mensajes
      AppointmentsListScreen(), // Citas
      const SettingsPage(), // Configuración
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simi Salud',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: const Color(0xFF3E8DF5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined), // Icono de notificaciones
            onPressed: () {}, // Sin acción aún
          ),
        ],
      ),
      body: pages[_currentIndex], // Muestra la página actual
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // Barra inferior con iconos de navegación
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF3E8DF5),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (i) => setState(() => _currentIndex = i), // Cambia la pestaña
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: 'Mensajes'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Mis Citas'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
          ],
        ),
      ),
    );
  }

  // Contenido principal de la pantalla de inicio
  Widget _buildHomeContent(BuildContext context) {
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuario'; // Nombre o email del usuario

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient( // Fondo con degradado azul
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3E8DF5), Color(0xFFE3F2FD)],
          stops: [0.0, 0.3],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con saludo al usuario
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola, $displayName! 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 8),
                  const Text(
                    '¿En qué podemos ayudarte hoy?',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Sección de tarjetas principales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Tarjeta de "Agendar Cita"
                      Expanded(
                        child: _actionCard(
                          context,
                          icon: Icons.calendar_month_rounded,
                          title: 'Agendar Cita',
                          subtitle: 'Reserva aquí',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentsListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tarjeta de "Consejos médicos"
                      Expanded(
                        child: _actionCard(
                          context,
                          icon: Icons.medical_information_rounded,
                          title: 'Consejos',
                          subtitle: 'Tips de salud',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                          ),
                          onTap: () {
                            // Muestra un diálogo con consejos
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: const [
                                    Icon(Icons.medical_information,
                                        color: Color(0xFF3E8DF5)),
                                    SizedBox(width: 8),
                                    Text('Consejos médicos'),
                                  ],
                                ),
                                content: const Text(
                                    '💧 Mantente hidratado\n😴 Descansa adecuadamente\n💊 Toma medicamentos según prescripción\n🏃 Mantén actividad física regular'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Entendido'),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tarjeta "Ver mis citas"
                  _actionCard(
                    context,
                    icon: Icons.list_alt_rounded,
                    title: 'Ver mis citas',
                    subtitle: 'Tus consultas',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    fullWidth: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentsListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Lista de especialistas
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.favorite, color: Color(0xFF3E8DF5)),
                      SizedBox(width: 8),
                      Text(
                        'Nuestros Especialistas',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _doctorCard(Icons.person_rounded, 'Dr. Juan Pérez', 'Médico General', const Color(0xFF667EEA)),
                  _doctorCard(Icons.child_care_rounded, 'Dra. Ana Gómez', 'Pediatría', const Color(0xFFF093FB)),
                  _doctorCard(Icons.favorite_rounded, 'Dr. Carlos Ruiz', 'Cardiología', const Color(0xFFF5576C)),
                  _doctorCard(Icons.face_rounded, 'Dra. Laura Fernández', 'Dermatología', const Color(0xFF4FACFE)),
                  _doctorCard(Icons.accessibility_new_rounded, 'Dr. Miguel Torres', 'Ortopedia', const Color(0xFF43E97B)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sección de servicios destacados
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.stars, color: Color(0xFFFFB800)),
                      SizedBox(width: 8),
                      Text(
                        'Servicios Destacados',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _serviceCard(Icons.local_hospital_rounded, 'Consulta Rápida',
                      'Atención inmediata para problemas leves', const Color(0xFF667EEA), () {}),
                  _serviceCard(Icons.medical_services_rounded, 'Emergencias 24/7',
                      'Atención de urgencias las 24 horas', const Color(0xFFF5576C), () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget genérico para las tarjetas de acción del home
  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: fullWidth ? 90 : 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 16),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70)),
                ],
              ),
      ),
    );
  }

  // Tarjeta para mostrar un doctor
  Widget _doctorCard(
      IconData icon, String name, String specialty, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(name,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle:
            Text(specialty, style: TextStyle(color: Colors.grey[600])),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contactando con $name...'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  // Tarjeta para servicios destacados
  Widget _serviceCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18),
        onTap: onTap, // Acción al presionar
      ),
    );
  }
}
