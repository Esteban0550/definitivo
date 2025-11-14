import 'package:flutter/material.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String description;
  final List<String> languages;
  final String location;
  final Color accentColor;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.reviews,
    this.imageUrl = '',
    required this.description,
    this.languages = const [],
    required this.location,
    required this.accentColor,
  });
}

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'Todas';
  String _searchQuery = '';

  final List<Doctor> _allDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Juan Pérez',
      specialty: 'Médico General',
      experience: '15 años',
      rating: 4.8,
      reviews: 234,
      description: 'Especialista en medicina general con amplia experiencia en diagnóstico y tratamiento de enfermedades comunes.',
      languages: ['Español', 'Inglés'],
      location: 'Clínica Central',
      accentColor: const Color(0xFF667EEA),
    ),
    Doctor(
      id: '2',
      name: 'Dra. Ana Gómez',
      specialty: 'Pediatría',
      experience: '12 años',
      rating: 4.9,
      reviews: 189,
      description: 'Pediatra especializada en atención infantil y adolescente. Experiencia en desarrollo y crecimiento.',
      languages: ['Español', 'Francés'],
      location: 'Hospital Infantil',
      accentColor: const Color(0xFFF5576C),
    ),
    Doctor(
      id: '3',
      name: 'Dr. Carlos Ruiz',
      specialty: 'Cardiología',
      experience: '20 años',
      rating: 4.7,
      reviews: 312,
      description: 'Cardiólogo con especialización en enfermedades del corazón y sistema circulatorio.',
      languages: ['Español', 'Inglés', 'Alemán'],
      location: 'Centro Cardíaco',
      accentColor: const Color(0xFF4FACFE),
    ),
    Doctor(
      id: '4',
      name: 'Dra. María López',
      specialty: 'Dermatología',
      experience: '10 años',
      rating: 4.9,
      reviews: 156,
      description: 'Dermatóloga especializada en cuidado de la piel, tratamientos estéticos y enfermedades cutáneas.',
      languages: ['Español', 'Inglés'],
      location: 'Clínica de Piel',
      accentColor: const Color(0xFFF093FB),
    ),
    Doctor(
      id: '5',
      name: 'Dr. Roberto Martínez',
      specialty: 'Ortopedia',
      experience: '18 años',
      rating: 4.6,
      reviews: 278,
      description: 'Ortopedista con experiencia en lesiones deportivas, cirugía de columna y articulaciones.',
      languages: ['Español'],
      location: 'Centro Ortopédico',
      accentColor: const Color(0xFF10B981),
    ),
    Doctor(
      id: '6',
      name: 'Dra. Laura Sánchez',
      specialty: 'Ginecología',
      experience: '14 años',
      rating: 4.8,
      reviews: 201,
      description: 'Ginecóloga especializada en salud femenina, obstetricia y medicina reproductiva.',
      languages: ['Español', 'Inglés'],
      location: 'Clínica de la Mujer',
      accentColor: const Color(0xFFF5576C),
    ),
  ];

  final List<String> _specialties = [
    'Todas',
    'Médico General',
    'Pediatría',
    'Cardiología',
    'Dermatología',
    'Ortopedia',
    'Ginecología',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> get _filteredDoctors {
    var filtered = _allDoctors;

    // Filtrar por especialidad
    if (_selectedSpecialty != 'Todas') {
      filtered = filtered
          .where((doctor) => doctor.specialty == _selectedSpecialty)
          .toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((doctor) =>
              doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con gradiente
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF3E8DF5),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3E8DF5), Color(0xFF667EEA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Nuestros Especialistas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_filteredDoctors.length} especialistas disponibles',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Barra de búsqueda
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o especialidad...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),

          // Filtros de especialidad
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _specialties.length,
                itemBuilder: (context, index) {
                  final specialty = _specialties[index];
                  final isSelected = _selectedSpecialty == specialty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(specialty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedSpecialty = specialty);
                      },
                      selectedColor: const Color(0xFF3E8DF5),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Lista de doctores
          _filteredDoctors.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron especialistas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otros filtros',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doctor = _filteredDoctors[index];
                      return _buildDoctorCard(doctor);
                    },
                    childCount: _filteredDoctors.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => _showDoctorDetails(doctor),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  doctor.accentColor.withOpacity(0.1),
                  doctor.accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar del doctor
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              doctor.accentColor,
                              doctor.accentColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: doctor.accentColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            doctor.name.split(' ').map((n) => n[0]).join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: doctor.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                doctor.specialty,
                                style: TextStyle(
                                  color: doctor.accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.rating}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${doctor.reviews} reseñas)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.work_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        doctor.experience,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (doctor.languages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: doctor.languages.map((lang) {
                        return Chip(
                          label: Text(
                            lang,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.grey[100],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDoctorDetails(doctor),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Ver perfil'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBookAppointmentDialog(doctor);
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Agendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: doctor.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                doctor.accentColor.withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [doctor.accentColor, doctor.accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              doctor.name.split(' ').map((n) => n[0]).join(),
                              style: TextStyle(
                                color: doctor.accentColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.specialty,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          value: doctor.rating.toString(),
                          label: 'Calificación',
                          color: Colors.white,
                        ),
                        _buildStatItem(
                          icon: Icons.rate_review,
                          value: doctor.reviews.toString(),
                          label: 'Reseñas',
                          color: Colors.white,
                        ),
                        _buildStatItem(
                          icon: Icons.work,
                          value: doctor.experience,
                          label: 'Experiencia',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Sobre el especialista'),
                      const SizedBox(height: 8),
                      Text(
                        doctor.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Ubicación'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: doctor.accentColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doctor.location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      if (doctor.languages.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('Idiomas'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: doctor.languages.map((lang) {
                            return Chip(
                              label: Text(lang),
                              backgroundColor: doctor.accentColor.withOpacity(0.1),
                              labelStyle: TextStyle(color: doctor.accentColor),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showBookAppointmentDialog(doctor);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text(
                            'Agendar Cita',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: doctor.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showBookAppointmentDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: doctor.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, color: doctor.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Agendar con ${doctor.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Especialidad: ${doctor.specialty}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para agendar una cita, ve a la sección de "Citas" y crea una nueva cita seleccionando este médico.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías navegar a la pantalla de crear cita
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Redirigiendo para agendar con ${doctor.name}'),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: doctor.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

