import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. COLECCIÓN DE USUARIOS ---
  // Tu `profile_page.dart` ya hace esto, pero esta es la forma de centralizarlo.
  Future<void> guardarDatosUsuario({
    required String nombre,
    required String telefono,
    required String enfermedades,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return; // No hacer nada si no hay usuario

    // La función `set` crea el documento si no existe, o lo actualiza si ya existe.
    await _firestore.collection('usuarios').doc(user.uid).set({
      'nombre': nombre,
      'telefono': telefono,
      'enfermedades': enfermedades,
      'email': user.email,
      'uid': user.uid,
    }, SetOptions(merge: true)); // `merge: true` evita sobreescribir datos si solo actualizas una parte.
  }

  // --- 2. COLECCIÓN DE CITAS ---
  // Función para crear un nuevo documento en la colección `citas`.
  Future<void> agendarNuevaCita({
    required String medicoId,
    required String nombreMedico,
    required DateTime fechaCita,
    required String motivo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // La función `add` crea un nuevo documento con un ID generado automáticamente.
    await _firestore.collection('citas').add({
      'pacienteId': user.uid,
      'pacienteEmail': user.email,
      'medicoId': medicoId,
      'nombreMedico': nombreMedico,
      'fecha': Timestamp.fromDate(fechaCita), // Firestore usa Timestamps para fechas
      'motivo': motivo,
      'estado': 'programada', // Estado inicial de la cita
    });
  }

  // --- 3. COLECCIÓN DE DISPONIBILIDAD DE MÉDICOS ---
  // Esta es una función de ejemplo para agregar un médico a la colección.
  // Podrías tener una pantalla de administrador para llamar a esta función.
  Future<void> agregarMedico({
    required String medicoId, // ej: "medico_01"
    required String nombre,
    required String especialidad,
    required List<String> horarios, // ej: ["09:00", "10:00", "11:00"]
  }) async {
    // Usamos `set` con un ID específico para tener control sobre los documentos de los médicos.
    await _firestore.collection('disponibilidad_medicos').doc(medicoId).set({
      'nombre': nombre,
      'especialidad': especialidad,
      'horariosDisponibles': horarios,
    });
  }

  // --- FUNCIONES DE LECTURA ---

  // Leer los médicos disponibles
  Stream<QuerySnapshot> getMedicos() {
    return _firestore.collection('disponibilidad_medicos').snapshots();
  }

  // Leer las citas de un usuario
  Stream<QuerySnapshot> getCitasUsuario() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('citas')
        .where('pacienteId', isEqualTo: user.uid)
        .snapshots();
  }
}










  