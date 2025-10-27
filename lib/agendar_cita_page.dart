// Importa los paquetes necesarios para la interfaz y servicios de Firebase.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Base de datos Firestore.
import 'package:firebase_auth/firebase_auth.dart'; // Autenticación de usuarios.

// Pantalla que permite a un usuario agendar una nueva cita médica.
class AgendarCitaPage extends StatefulWidget {
  const AgendarCitaPage({super.key});

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

// Estado de la pantalla, donde se maneja la lógica y los datos del formulario.
class _AgendarCitaPageState extends State<AgendarCitaPage> {
  // Controlador para el campo de texto del motivo de la cita.
  final motivoCtl = TextEditingController();
  // Variable para guardar la fecha seleccionada.
  DateTime? selectedDate;
  // Identificador del médico (ejemplo fijo por ahora).
  String medicoId = 'medico1'; // ejemplo de especialista

  // Función que agenda una cita y la guarda en Firestore.
  Future<void> agendarCita({
    required String pacienteId, // ID del paciente.
    required String medicoId, // ID del médico.
    required DateTime fecha, // Fecha seleccionada.
    required String motivo, // Motivo de la cita.
  }) async {
    // Crea una nueva referencia de documento en la colección 'citas'.
    final docRef = FirebaseFirestore.instance.collection('citas').doc();
    // Guarda los datos de la cita en Firestore.
    await docRef.set({
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha': fecha,
      'motivo': motivo,
      'estado': 'pendiente',
      'created_at': FieldValue.serverTimestamp(), // Fecha de creación automática.
    });

    // Consulta la disponibilidad del médico para esa fecha.
    final dispoQuery = await FirebaseFirestore.instance
        .collection('disponibilidad_medicos')
        .where('medico_id', isEqualTo: medicoId)
        .where('fecha', isEqualTo: fecha)
        .limit(1)
        .get();

    // Si existe un registro de disponibilidad, lo marca como no disponible.
    if (dispoQuery.docs.isNotEmpty) {
      await dispoQuery.docs.first.reference.update({'esta_disponible': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título.
      appBar: AppBar(title: const Text('Agendar Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Contenedor principal con los campos del formulario.
        child: Column(
          children: [
            // Campo de texto para escribir el motivo de la cita.
            TextField(controller: motivoCtl, decoration: const InputDecoration(labelText: 'Motivo')),
            const SizedBox(height: 12),
            // Botón para seleccionar la fecha de la cita.
            ElevatedButton(
              child: Text(selectedDate == null ? 'Seleccionar fecha' : selectedDate.toString()),
              onPressed: () async {
                // Muestra un selector de fecha.
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), // Fecha inicial actual.
                  firstDate: DateTime.now(), // No se pueden fechas pasadas.
                  lastDate: DateTime.now().add(const Duration(days: 365)), // Hasta un año adelante.
                );
                // Si se elige una fecha, se guarda en el estado.
                if (date != null) setState(() => selectedDate = date);
              },
            ),
            const SizedBox(height: 20),
            // Botón final para confirmar y registrar la cita.
            ElevatedButton(
              child: const Text('Agendar'),
              onPressed: () async {
                // Valida que se haya elegido una fecha y escrito un motivo.
                if (selectedDate == null || motivoCtl.text.isEmpty) return;
                // Llama a la función para guardar la cita en Firestore.
                await agendarCita(
                  pacienteId: FirebaseAuth.instance.currentUser!.uid, // ID del usuario autenticado.
                  medicoId: medicoId,
                  fecha: selectedDate!,
                  motivo: motivoCtl.text,
                );
                // Muestra un mensaje de éxito.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita agendada')));
                // Regresa a la pantalla anterior.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
