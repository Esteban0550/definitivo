// Importa los paquetes necesarios para construir la interfaz y manejar fechas.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart'; // Importa el modelo de citas.
import '../services/appointment_service.dart'; // Importa el servicio que maneja las operaciones de citas.
import 'appointment_form_screen.dart'; // Importa la pantalla del formulario para crear/editar citas.

// Pantalla principal que muestra la lista de citas médicas.
class AppointmentsListScreen extends StatelessWidget {
  // Instancia del servicio que gestiona las citas.
  final AppointmentService _service = AppointmentService();

  // Constructor de la clase.
  AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación.
      appBar: AppBar(
        title: const Text('Agenda de Citas Médicas'), // Título.
        backgroundColor: const Color(0xFF3E8DF5), // Color de fondo.
        foregroundColor: Colors.white, // Color del texto.
      ),
      // Cuerpo principal que escucha los cambios en las citas.
      body: StreamBuilder<List<Appointment>>(
        stream: _service.getAppointments(), // Obtiene las citas en tiempo real.
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras se obtienen los datos.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Muestra un mensaje si ocurre un error.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Muestra un mensaje si no hay citas.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay citas agendadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Guarda las citas obtenidas.
          List<Appointment> appointments = snapshot.data!;

          // Muestra la lista de citas en tarjetas.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              Appointment appointment = appointments[index];
              return _buildAppointmentCard(context, appointment);
            },
          );
        },
      ),
      // Botón flotante para agregar una nueva cita.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega al formulario para crear una nueva cita.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentFormScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3E8DF5),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  // Construye la tarjeta que muestra los detalles básicos de una cita.
  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // Permite abrir los detalles al tocar la tarjeta.
        onTap: () {
          _showAppointmentDetails(context, appointment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con nombre del doctor, paciente y botones de acción.
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF3E8DF5),
                    child: Text(
                      appointment.doctorName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${appointment.doctorName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Paciente: ${appointment.patientName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón para editar la cita.
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3E8DF5)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentFormScreen(appointment: appointment),
                        ),
                      );
                    },
                  ),
                  // Botón para eliminar la cita.
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, appointment);
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              // Muestra la fecha y hora de la cita.
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(appointment.date),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.startTime} - ${appointment.endTime}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Muestra el motivo de la cita.
              Row(
                children: [
                  const Icon(Icons.medical_services,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Muestra un cuadro de diálogo con los detalles completos de la cita.
  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Cita'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Paciente:', appointment.patientName),
              _detailRow('Médico:', 'Dr. ${appointment.doctorName}'),
              _detailRow('Fecha:',
                  DateFormat('dd/MM/yyyy').format(appointment.date)),
              _detailRow('Horario:',
                  '${appointment.startTime} - ${appointment.endTime}'),
              _detailRow('Motivo:', appointment.reason),
              if (appointment.clinicAddress.isNotEmpty)
                _detailRow('Dirección:', appointment.clinicAddress),
              if (appointment.instructions.isNotEmpty)
                _detailRow('Instrucciones:', appointment.instructions),
            ],
          ),
        ),
        actions: [
          // Botón para cerrar el cuadro de diálogo.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Construye un renglón de detalle con etiqueta y valor.
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Muestra una alerta para confirmar la eliminación de una cita.
  void _confirmDelete(BuildContext parentContext, Appointment appointment) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Estás seguro de que deseas cancelar la cita con Dr. ${appointment.doctorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _service.deleteAppointment(appointment.id!);
                // 1) Cierra el diálogo
                Navigator.pop(dialogContext);
                // 2) Regresa al Home (cierra esta pantalla)
                Navigator.pop(parentContext);
              } catch (e) {
                // Si falla, solo cierra el diálogo y muestra error
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
