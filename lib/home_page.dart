import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'screens/appointments_list_screen.dart';
import 'screens/appointment_form_screen.dart';
import 'pages/dashboard_page.dart';
import 'pages/doctor_home_page.dart';
import 'pages/doctor_patients_page.dart';
import 'pages/patient_medical_history_page.dart';
import 'pages/doctors_page.dart';

class Doctor {
  final String name;
  final String spec;
  final IconData icon;

  Doctor({
    required this.name,
    required this.spec,
    this.icon = Icons.person,
  });
}

class ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;
  Doctor? _favoriteDoctor;
  String? _userRole;
  bool _roleLoading = true;
  bool _notificationsEnabled = true;
  final _searchController = TextEditingController();

  final List<Doctor> _doctors = [
    Doctor(name: "Dr. Juan Pérez", spec: "Médico General", icon: Icons.medical_services),
    Doctor(name: "Dra. Ana Gómez", spec: "Pediatría", icon: Icons.child_care),
    Doctor(name: "Dr. Carlos Ruiz", spec: "Cardiología", icon: Icons.favorite),
  ];

  final List<ServiceItem> _services = [
    ServiceItem(
      title: "Consulta rápida",
      subtitle: "Atención médica inmediata",
      icon: Icons.access_time,
      iconColor: const Color(0xFF667EEA),
    ),
    ServiceItem(
      title: "Emergencias 24/7",
      subtitle: "Atención urgente las 24 horas",
      icon: Icons.emergency,
      iconColor: const Color(0xFFF5576C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _userRole = 'Paciente';
        _roleLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userRole = data['rol'] as String? ?? 'Paciente';
          _roleLoading = false;
        });
      } else {
        setState(() {
          _userRole = 'Paciente';
          _roleLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userRole = 'Paciente';
        _roleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _getPageForIndex(int index) {
    if (_roleLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDoctor = _userRole == 'Médico';

    if (isDoctor) {
      // Páginas para médicos - Menú diferente
      switch (index) {
        case 0:
          return const DoctorHomePage();
        case 1:
          return const DoctorPatientsPage();
        case 2:
          return AppointmentsListScreen();
        case 3:
          return const MessagesPage();
        case 4:
          return const SettingsPage();
        default:
          return const DoctorHomePage();
      }
    } else {
      // Páginas para pacientes - Menú diferente
      switch (index) {
        case 0:
          return _buildHomeContent(context);
        case 1:
          return const MessagesPage();
        case 2:
          return AppointmentsListScreen();
        case 3:
          return const PatientMedicalHistoryPage();
        case 4:
          return const SettingsPage();
        default:
          return _buildHomeContent(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_roleLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDoctor = _userRole == 'Médico';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isDoctor ? 'Panel Médico' : 'Simi Salud',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3E8DF5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay notificaciones nuevas')),
              );
            },
          ),
        ],
      ),
      body: _getPageForIndex(_currentIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF3E8DF5).withOpacity(0.2),
        destinations: isDoctor
            ? const [
                // Menú para Médicos - Diferente al de pacientes
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Pacientes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Citas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.message_outlined),
                  selectedIcon: Icon(Icons.message),
                  label: 'Mensajes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ]
            : const [
                // Menú para Pacientes
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.message_outlined),
                  selectedIcon: Icon(Icons.message),
                  label: 'Mensajes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Citas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_information_outlined),
                  selectedIcon: Icon(Icons.medical_information),
                  label: 'Historial',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    // Si aún está cargando el rol, mostrar loading
    if (_roleLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
    final isDoctor = _userRole == 'Médico';

    // Si es médico, no debería llegar aquí, pero por seguridad
    if (isDoctor) {
      return const Center(
        child: Text('Esta página es solo para pacientes'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contenido actualizado ✅")),
          );
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3E8DF5), Color(0xFF667EEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¡Hola, $displayName! 👋",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "¿En qué podemos ayudarte hoy?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar especialistas...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Action Cards
            _buildActionCards(context),
            const SizedBox(height: 24),

            // Botón para ver todos los doctores
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorsPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3E8DF5), Color(0xFF667EEA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ver Todos los Especialistas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Explora nuestro equipo médico completo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Doctors Section
            _buildDoctorSection(context),
            const SizedBox(height: 24),

            // Services Section
            _buildServiceSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    if (_roleLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Esta función solo se usa para pacientes
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.calendar_today,
                  title: 'Agendar Cita',
                  subtitle: 'Reserva aquí',
                  color1: const Color(0xFF667EEA),
                  color2: const Color(0xFF764BA2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppointmentFormScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.favorite,
                  title: 'Consejos',
                  subtitle: 'Tips de salud',
                  color1: const Color(0xFFF093FB),
                  color2: const Color(0xFFF5576C),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Consejos médicos 🩺"),
                        content: const Text(
                          "💧 Mantente hidratado\n😴 Duerme bien\n🏃‍♂️ Haz ejercicio\n🍎 Come saludable",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Ok"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.list,
                  title: 'Ver mis citas',
                  subtitle: 'Tus consultas',
                  color1: const Color(0xFF4FACFE),
                  color2: const Color(0xFF00F2FE),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AppointmentsListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.medical_information,
                  title: 'Historial',
                  subtitle: 'Médico',
                  color1: const Color(0xFF10B981),
                  color2: const Color(0xFF059669),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientMedicalHistoryPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: fullWidth
              ? Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white70),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nuestros Especialistas 🩺",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._doctors.map(
            (doctor) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF3E8DF5).withOpacity(0.1),
                  child: Icon(doctor.icon, color: const Color(0xFF3E8DF5)),
                ),
                title: Text(doctor.name),
                subtitle: Text(doctor.spec),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(doctor.name),
                      content: Text("Especialidad: ${doctor.spec}"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Servicios Destacados ⭐",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._services.map(
            (service) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: service.iconColor.withOpacity(0.1),
                  child: Icon(service.icon, color: service.iconColor),
                ),
                title: Text(service.title),
                subtitle: Text(service.subtitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Lógica para cada servicio
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
