import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Necesario para el SnackBar y Material en Draggable
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'screens/appointments_list_screen.dart';

// --- MEJORA 2: MODELOS DE DATOS ---
class Doctor {
  final String name;
  final String spec;
  final IconData icon;

  Doctor({required this.name, required this.spec, this.icon = CupertinoIcons.person_alt_circle});
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
// --- FIN MEJORA 2 ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;
  Doctor? _favoriteDoctor;

  // --- 5 WIDGETS AÑADIDOS: Variables de Estado ---
  bool _notificationsEnabled = true;
  int? _selectedSegment = 0;
  final _searchController = TextEditingController();
  bool _loading = false; // Estado para el ActivityIndicator
  // --- FIN WIDGETS AÑADIDOS ---

  final List<Doctor> _doctors = [
    Doctor(name: "Dr. Juan Pérez", spec: "Médico General"),
    Doctor(name: "Dra. Ana Gómez", spec: "Pediatría"),
    Doctor(name: "Dr. Carlos Ruiz", spec: "Cardiología"),
  ];

  final List<ServiceItem> _services = [
    ServiceItem(
      title: "Consulta rápida",
      subtitle: "Atención médica inmediata",
      icon: CupertinoIcons.time_solid,
      iconColor: const Color(0xFF667EEA),
    ),
    ServiceItem(
      title: "Emergencias 24/7",
      subtitle: "Atención urgente las 24 horas",
      icon: CupertinoIcons.bolt_fill,
      iconColor: const Color(0xFFF5576C),
    ),
  ];

  // --- 5 WIDGETS AÑADIDOS: Dispose ---
  // Es buena práctica limpiar los controllers
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // --- FIN WIDGETS AÑADIDOS ---

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(context),
      const MessagesPage(),
      AppointmentsListScreen(),
      const SettingsPage(),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF3E8DF5),
        middle: const Text(
          'Simi Salud',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bell, color: Colors.white),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Colors.white,
            activeColor: const Color(0xFF3E8DF5),
            inactiveColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_text), label: 'Mensajes'),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Citas'),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Ajustes'),
            ],
            onTap: (i) => setState(() => _currentIndex = i),
          ),
          tabBuilder: (context, index) => CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            child: pages[index],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';

    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Contenido actualizado ✅")),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- MEJORA 1: HEADER LIMPIO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("¡Hola, $displayName! 👋",
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.black)),
                    const SizedBox(height: 6),
                    const Text("¿En qué podemos ayudarte hoy?",
                        style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 16)),
                  ],
                ),
              ),
              // --- FIN MEJORA 1 ---

              // --- 5 WIDGETS DE CUPERTINO AÑADIDOS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Widget 1: SearchTextField
                    CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Buscar especialistas...',
                    ),
                    const SizedBox(height: 16),

                    // Widget 2: SlidingSegmentedControl
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedSegment,
                        onValueChanged: (value) {
                          setState(() => _selectedSegment = value);
                        },
                        children: const {
                          0: Padding(padding: EdgeInsets.all(8), child: Text('Doctores')),
                          1: Padding(padding: EdgeInsets.all(8), child: Text('Servicios')),
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Widget 3: Switch (en un contenedor tipo lista)
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CupertinoListTile(
                        title: const Text('Activar recordatorios'),
                        // El Switch es el 'trailing'
                        trailing: CupertinoSwitch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Widgets 4 & 5: Alert Button & Activity Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Widget 4: Botón para Alerta
                        CupertinoButton(
                          child: const Text('Mostrar Alerta'),
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: const Text('Alerta de Salud'),
                                content: const Text('Recuerda tu próxima cita.'),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: const Text('Entendido'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        // Widget 5: Indicador de Carga
                        // Se mostrará si _loading es true
                        if (_loading)
                          const CupertinoActivityIndicator(radius: 12),
                      ],
                    ),
                    // Botón para probar el loading
                    CupertinoButton.filled(
                      child: const Text("Probar 'Cargando' (Toggle)"),
                      onPressed: () {
                        setState(() => _loading = !_loading);
                      },
                    ),
                    const SizedBox(height: 20), // Espacio extra antes de las tarjetas
                  ],
                ),
              ),
              // --- FIN 5 WIDGETS ---

              _buildCupertinoCards(context),
              const SizedBox(height: 30),
              _buildDoctorSection(context),
              const SizedBox(height: 30),
              _buildServiceSection(context),
              const SizedBox(height: 30), // Espacio al final
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _cupertinoActionCard(
                  icon: CupertinoIcons.calendar,
                  title: 'Agendar Cita',
                  subtitle: 'Reserva aquí',
                  color1: const Color(0xFF667EEA),
                  color2: const Color(0xFF764BA2),
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => AppointmentsListScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cupertinoActionCard(
                  icon: CupertinoIcons.heart,
                  title: 'Consejos',
                  subtitle: 'Tips de salud',
                  color1: const Color(0xFFF093FB),
                  color2: const Color(0xFFF5576C),
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text("Consejos médicos 🩺"),
                        content: const Text(
                            "💧 Mantente hidratado\n😴 Duerme bien\n🏃‍♂️ Haz ejercicio\n🍎 Come saludable"),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: const Text("Ok"),
                            onPressed: () => Navigator.pop(context),
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
          _cupertinoActionCard(
            icon: CupertinoIcons.list_bullet,
            title: 'Ver mis citas',
            subtitle: 'Tus consultas',
            color1: const Color(0xFF4FACFE),
            color2: const Color(0xFF00F2FE),
            fullWidth: true,
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => AppointmentsListScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _cupertinoActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showCupertinoModalPopup(
          context: context,
          builder: (ctx) => CupertinoActionSheet(
            title: Text(title),
            message: Text("Has hecho una pulsación larga en '$subtitle'"),
            actions: [
              CupertinoActionSheetAction(
                child: const Text("Ver detalles (Acción 1)"),
                onPressed: () => Navigator.pop(ctx),
              ),
              CupertinoActionSheetAction(
                child: const Text("Compartir (Acción 2)"),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDestructiveAction: true,
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: fullWidth ? 0 : 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: fullWidth
            ? Row(
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white70)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(CupertinoIcons.forward, color: Colors.white70, size: 18),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(color: Colors.white70)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18)),
                ],
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
          const Text("Nuestros Especialistas 🩺",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black)),
          const SizedBox(height: 12),
          DragTarget<Doctor>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _favoriteDoctor == null
                      ? CupertinoColors.systemGroupedBackground
                      : CupertinoColors.activeGreen.withOpacity(0.1),
                  border: Border.all(
                      color: candidateData.isNotEmpty
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.lightBackgroundGray,
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _favoriteDoctor == null
                        ? "Arrastra a tu doctor favorito aquí"
                        : "⭐ Dr. Favorito: ${_favoriteDoctor!.name}",
                    style: const TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                ),
              );
            },
            onAccept: (doctor) {
              setState(() {
                _favoriteDoctor = doctor;
              });
            },
          ),
          const SizedBox(height: 16),
          ..._doctors.map(
            (doctor) {
              return Dismissible(
                key: Key(doctor.name),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  final removedDoctor = doctor;
                  final removedDoctorIndex = _doctors.indexOf(doctor);

                  setState(() {
                    _doctors.remove(doctor);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${removedDoctor.name} eliminado."),
                      action: SnackBarAction(
                        label: "DESHACER",
                        onPressed: () {
                          setState(() {
                            _doctors.insert(removedDoctorIndex, removedDoctor);
                          });
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  color: CupertinoColors.destructiveRed,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Row(
                    children: [
                      Icon(CupertinoIcons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Eliminar", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                child: Draggable<Doctor>(
                  data: doctor,
                  feedback: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        color: Colors.white,
                        child: CupertinoListTile(
                          title: Text(doctor.name),
                          subtitle: Text(doctor.spec),
                          leading: Icon(doctor.icon, color: const Color(0xFF3E8DF5)),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                        color: CupertinoColors.systemGroupedBackground,
                        border: Border(
                            bottom: BorderSide(
                                color: CupertinoColors.lightBackgroundGray))),
                    child: CupertinoListTile(
                      title: Text(doctor.name,
                          style: TextStyle(color: CupertinoColors.placeholderText)),
                      subtitle: Text(doctor.spec,
                          style: TextStyle(color: CupertinoColors.placeholderText)),
                      leading:
                          Icon(doctor.icon, color: CupertinoColors.placeholderText),
                    ),
                  ),
                  child: CupertinoListTile(
                    title: Text(doctor.name),
                    subtitle: Text(doctor.spec),
                    leading: Icon(doctor.icon, color: const Color(0xFF3E8DF5)),
                    trailing: const Icon(CupertinoIcons.forward),
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text(doctor.name),
                          content: Text("Especialidad: ${doctor.spec}"),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("Cerrar"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
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
          const Text("Servicios Destacados ⭐",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black)),
          const SizedBox(height: 12),
          ..._services.map(
            (service) => CupertinoListTile(
              leading: Icon(service.icon, color: service.iconColor),
              title: Text(service.title),
              subtitle: Text(service.subtitle),
              onTap: () {
                // Aquí puedes agregar la lógica para cada servicio
              },
            ),
          ),
        ],
      ),
    );
  }
}