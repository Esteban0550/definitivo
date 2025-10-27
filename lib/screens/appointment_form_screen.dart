// Importa el paquete principal de Flutter para usar widgets y materiales visuales.
import 'package:flutter/material.dart';
// Importa la librería intl para formatear fechas.
import 'package:intl/intl.dart';
// Importa el modelo Appointment.
import '../models/appointment.dart';
// Importa el servicio que maneja las citas.
import '../services/appointment_service.dart';

// Pantalla que permite crear o editar una cita.
class AppointmentFormScreen extends StatefulWidget {
  // Cita existente (si se va a editar).
  final Appointment? appointment;

  // Constructor con parámetro opcional de cita.
  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

// Estado asociado al formulario de cita.
class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  // Llave global para validar el formulario.
  final _formKey = GlobalKey<FormState>();
  // Instancia del servicio de citas.
  final AppointmentService _service = AppointmentService();

  // Controladores de texto para los campos del formulario.
  late TextEditingController _patientController;
  late TextEditingController _doctorController;
  late TextEditingController _reasonController;
  late TextEditingController _addressController;
  late TextEditingController _instructionsController;

  // Variables para fecha y horas seleccionadas.
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

  // Estado de carga (para mostrar el spinner).
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con valores existentes si la cita no es nula.
    _patientController =
        TextEditingController(text: widget.appointment?.patientName ?? '');
    _doctorController =
        TextEditingController(text: widget.appointment?.doctorName ?? '');
    _reasonController =
        TextEditingController(text: widget.appointment?.reason ?? '');
    _addressController =
        TextEditingController(text: widget.appointment?.clinicAddress ?? '');
    _instructionsController =
        TextEditingController(text: widget.appointment?.instructions ?? '');

    // Si se está editando una cita, carga la fecha y horas guardadas.
    if (widget.appointment != null) {
      _selectedDate = widget.appointment!.date;
      _startTime = _parseTime(widget.appointment!.startTime);
      _endTime = _parseTime(widget.appointment!.endTime);
    }
  }

  // Convierte una cadena en formato "HH:mm" a un objeto TimeOfDay.
  TimeOfDay _parseTime(String time) {
    List<String> parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  void dispose() {
    // Libera la memoria de los controladores al cerrar la pantalla.
    _patientController.dispose();
    _doctorController.dispose();
    _reasonController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Estructura principal de la pantalla.
    return Scaffold(
      appBar: AppBar(
        // Título cambia según si se crea o edita una cita.
        title: Text(widget.appointment == null ? 'Nueva Cita' : 'Editar Cita'),
        backgroundColor: const Color(0xFF3E8DF5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo: Nombre del Paciente.
                TextFormField(
                  controller: _patientController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Paciente',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                // Campo: Nombre del Médico.
                TextFormField(
                  controller: _doctorController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Médico',
                    prefixIcon: const Icon(Icons.medical_services),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                // Campo: Fecha de la cita.
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF3E8DF5)),
                    title: const Text('Fecha de la Cita'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),

                // Campos: Horas de inicio y fin.
                Row(
                  children: [
                    // Hora de inicio.
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.access_time, color: Color(0xFF3E8DF5)),
                          title: const Text('Inicio'),
                          subtitle: Text(
                            _formatTime(_startTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _selectTime(true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Hora de fin.
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.access_time_filled, color: Color(0xFF3E8DF5)),
                          title: const Text('Fin'),
                          subtitle: Text(
                            _formatTime(_endTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Campo: Motivo de la consulta.
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Motivo de la Consulta',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                // Campo: Dirección de la clínica (opcional).
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Dirección de la Clínica (Opcional)',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo: Instrucciones previas (opcional).
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Instrucciones Previas (Opcional)',
                    prefixIcon: const Icon(Icons.info),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Botón para guardar la cita.
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E8DF5),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Muestra cargando o texto según el estado.
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            widget.appointment == null
                                ? 'CREAR CITA'
                                : 'ACTUALIZAR CITA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Muestra un selector de fecha y actualiza el estado.
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3E8DF5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Muestra un selector de hora (inicio o fin).
  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3E8DF5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // Devuelve la hora formateada como "HH:mm".
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Guarda o actualiza la cita validando los datos y conflictos de horario.
  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    // Verifica que la hora final sea después de la hora inicial.
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser posterior a la hora de inicio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convierte las horas a formato de texto.
      String startTimeStr = _formatTime(_startTime);
      String endTimeStr = _formatTime(_endTime);

      // Verifica si hay conflicto de horario en la base de datos.
      bool hasConflict = await _service.hasTimeConflict(
        _selectedDate,
        startTimeStr,
        endTimeStr,
        excludeId: widget.appointment?.id,
      );

      // Muestra mensaje si hay conflicto.
      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una cita en ese horario. Por favor selecciona otro.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Crea un objeto Appointment con los datos del formulario.
      Appointment appointment = Appointment(
        id: widget.appointment?.id,
        patientName: _patientController.text,
        doctorName: _doctorController.text,
        date: _selectedDate,
        startTime: startTimeStr,
        endTime: endTimeStr,
        reason: _reasonController.text,
        clinicAddress: _addressController.text,
        instructions: _instructionsController.text,
      );

      // Si no existe la cita, la crea. Si existe, la actualiza.
      if (widget.appointment == null) {
        await _service.createAppointment(appointment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita creada exitosamente ✓'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _service.updateAppointment(widget.appointment!.id!, appointment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita actualizada exitosamente ✓'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Captura errores y muestra un mensaje.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Al finalizar, quita el estado de carga.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
