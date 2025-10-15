import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendarCitaPage extends StatefulWidget {
  const AgendarCitaPage({super.key});

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  final motivoCtl = TextEditingController();
  DateTime? selectedDate;
  String medicoId = 'medico1'; // ejemplo de especialista

  Future<void> agendarCita({
    required String pacienteId,
    required String medicoId,
    required DateTime fecha,
    required String motivo,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('citas').doc();
    await docRef.set({
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha': fecha,
      'motivo': motivo,
      'estado': 'pendiente',
      'created_at': FieldValue.serverTimestamp(),
    });

    // actualizar disponibilidad
    final dispoQuery = await FirebaseFirestore.instance
        .collection('disponibilidad_medicos')
        .where('medico_id', isEqualTo: medicoId)
        .where('fecha', isEqualTo: fecha)
        .limit(1)
        .get();

    if (dispoQuery.docs.isNotEmpty) {
      await dispoQuery.docs.first.reference.update({'esta_disponible': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: motivoCtl, decoration: const InputDecoration(labelText: 'Motivo')),
            const SizedBox(height: 12),
            ElevatedButton(
              child: Text(selectedDate == null ? 'Seleccionar fecha' : selectedDate.toString()),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => selectedDate = date);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Agendar'),
              onPressed: () async {
                if (selectedDate == null || motivoCtl.text.isEmpty) return;
                await agendarCita(
                  pacienteId: FirebaseAuth.instance.currentUser!.uid,
                  medicoId: medicoId,
                  fecha: selectedDate!,
                  motivo: motivoCtl.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita agendada')));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
