import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';

class PatientMedicalHistoryPage extends StatefulWidget {
  const PatientMedicalHistoryPage({super.key});

  @override
  State<PatientMedicalHistoryPage> createState() => _PatientMedicalHistoryPageState();
}

class _PatientMedicalHistoryPageState extends State<PatientMedicalHistoryPage> {
  final AppointmentService _appointmentService = AppointmentService();
  String _filter = 'Todas'; // Todas, Pasadas, Próximas

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final patientName = user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historial Médico'),
        backgroundColor: const Color(0xFF3E8DF5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                _buildFilterChip('Todas', _filter == 'Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('Próximas', _filter == 'Próximas'),
                const SizedBox(width: 8),
                _buildFilterChip('Pasadas', _filter == 'Pasadas'),
              ],
            ),
          ),

          // Lista de citas
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _appointmentService.getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_information, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes citas registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agenda tu primera cita médica',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar citas del paciente
                var patientAppointments = snapshot.data!
                    .where((appointment) => appointment.patientName == patientName)
                    .toList();

                // Aplicar filtro adicional
                final now = DateTime.now();
                if (_filter == 'Próximas') {
                  patientAppointments = patientAppointments
                      .where((a) => a.date.isAfter(now.subtract(const Duration(days: 1))))
                      .toList();
                } else if (_filter == 'Pasadas') {
                  patientAppointments = patientAppointments
                      .where((a) => a.date.isBefore(now))
                      .toList();
                }

                // Ordenar por fecha
                patientAppointments.sort((a, b) => b.date.compareTo(a.date));

                if (patientAppointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _filter == 'Próximas' ? Icons.calendar_today : Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'Próximas'
                              ? 'No tienes citas próximas'
                              : 'No tienes citas pasadas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: patientAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = patientAppointments[index];
                    final isPast = appointment.date.isBefore(now);
                    final isToday = appointment.date.year == now.year &&
                        appointment.date.month == now.month &&
                        appointment.date.day == now.day;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: isToday ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isToday
                            ? const BorderSide(color: Color(0xFF3E8DF5), width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.grey[200]
                                : isToday
                                    ? const Color(0xFF3E8DF5).withOpacity(0.1)
                                    : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPast
                                ? Icons.check_circle
                                : isToday
                                    ? Icons.today
                                    : Icons.upcoming,
                            color: isPast
                                ? Colors.grey[600]
                                : isToday
                                    ? const Color(0xFF3E8DF5)
                                    : Colors.green[700],
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3E8DF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'HOY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(appointment.date),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${appointment.startTime} - ${appointment.endTime}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (appointment.reason.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                appointment.reason,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (appointment.clinicAddress.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      appointment.clinicAddress,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.grey[200]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPast ? 'Completada' : 'Pendiente',
                            style: TextStyle(
                              color: isPast
                                  ? Colors.grey[700]
                                  : Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showAppointmentDetails(context, appointment);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = label);
      },
      selectedColor: const Color(0xFF3E8DF5),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3E8DF5), Color(0xFF667EEA)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.medical_services, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(appointment.date),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
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
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.access_time, 'Horario',
                        '${appointment.startTime} - ${appointment.endTime}'),
                    const SizedBox(height: 16),
                    if (appointment.reason.isNotEmpty) ...[
                      _buildDetailRow(Icons.description, 'Motivo', appointment.reason),
                      const SizedBox(height: 16),
                    ],
                    if (appointment.clinicAddress.isNotEmpty) ...[
                      _buildDetailRow(
                          Icons.location_on, 'Dirección', appointment.clinicAddress),
                      const SizedBox(height: 16),
                    ],
                    if (appointment.instructions.isNotEmpty) ...[
                      _buildDetailRow(
                          Icons.info, 'Instrucciones', appointment.instructions),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3E8DF5), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

