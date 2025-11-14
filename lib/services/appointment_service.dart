import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  // CREATE - Crear una nueva cita
  Future<String> createAppointment(Appointment appointment) async {
    try {
      DocumentReference doc = await _firestore
          .collection(_collection)
          .add(appointment.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Error al crear la cita: $e');
    }
  }

  // READ - Obtener todas las citas
  Stream<List<Appointment>> getAppointments() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.id, doc.data()))
            .toList());
  }

  // READ - Obtener una cita específica
  Future<Appointment?> getAppointmentById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener la cita: $e');
    }
  }

  // UPDATE - Actualizar una cita existente
  Future<void> updateAppointment(String id, Appointment appointment) async {
    try {
      await _firestore.collection(_collection).doc(id).update(appointment.toMap());
    } catch (e) {
      throw Exception('Error al actualizar la cita: $e');
    }
  }

  // DELETE - Eliminar una cita
  Future<void> deleteAppointment(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar la cita: $e');
    }
  }

  // Verificar conflictos de horario
  Future<bool> hasTimeConflict(DateTime date, String startTime, String endTime,
      {String? excludeId}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('date',
              isEqualTo: DateTime(date.year, date.month, date.day)
                  .toIso8601String())
          .get();

      for (var doc in snapshot.docs) {
        if (excludeId != null && doc.id == excludeId) continue;

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String existingStart = data['startTime'];
        String existingEnd = data['endTime'];

        // Verificar si hay conflicto
        if (_timesOverlap(startTime, endTime, existingStart, existingEnd)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Error al verificar conflictos: $e');
    }
  }

  bool _timesOverlap(
      String start1, String end1, String start2, String end2) {
    int s1 = _timeToMinutes(start1);
    int e1 = _timeToMinutes(end1);
    int s2 = _timeToMinutes(start2);
    int e2 = _timeToMinutes(end2);

    return (s1 < e2 && e1 > s2);
  }

  int _timeToMinutes(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Obtener todas las citas de un médico específico
  Stream<List<Appointment>> getAppointmentsByDoctor(String doctorName) {
    return _firestore
        .collection(_collection)
        .where('doctorName', isEqualTo: doctorName)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => Appointment.fromMap(doc.id, doc.data()))
              .toList();
          // Ordenar por fecha después de obtener los datos
          appointments.sort((a, b) => a.date.compareTo(b.date));
          return appointments;
        });
  }

  // Obtener citas próximas/pendientes de un médico (fecha >= hoy)
  Stream<List<Appointment>> getUpcomingAppointmentsByDoctor(String doctorName) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _firestore
        .collection(_collection)
        .where('doctorName', isEqualTo: doctorName)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => Appointment.fromMap(doc.id, doc.data()))
              .where((appointment) {
                final appointmentDate = appointment.date;
                final appointmentDateOnly = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                );
                // Incluir citas de hoy y futuras
                return appointmentDateOnly.isAfter(today.subtract(const Duration(days: 1)));
              })
              .toList();
          // Ordenar por fecha
          appointments.sort((a, b) => a.date.compareTo(b.date));
          return appointments;
        });
  }

  // Obtener total de pacientes únicos de un médico
  Stream<int> getUniquePatientsCountByDoctor(String doctorName) {
    return _firestore
        .collection(_collection)
        .where('doctorName', isEqualTo: doctorName)
        .snapshots()
        .map((snapshot) {
          final patientNames = <String>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final patientName = data['patientName'] as String? ?? '';
            if (patientName.isNotEmpty) {
              patientNames.add(patientName);
            }
          }
          return patientNames.length;
        });
  }
}