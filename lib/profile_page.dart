import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Se corrige el nombre del archivo de rutas
import 'app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores para los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nombreController.text = data['nombre'] ?? '';
          telefonoController.text = data['telefono'] ?? '';
          enfermedadesController.text = data['enfermedades'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Guardar datos del usuario en Firestore
  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nombre': nombreController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'enfermedades': enfermedadesController.text.trim(),
        'email': user.email,
        'uid': user.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información guardada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar datos: $e')),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    enfermedadesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Correo: ${user?.email ?? 'No disponible'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // FORMULARIO
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: enfermedadesController,
                      decoration: const InputDecoration(labelText: 'Enfermedades'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text("Guardar información"),
                    ),
                    const SizedBox(height: 30),

                    // Botón para volver al menú principal
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Volver al Menú Principal"),
                    ),
                    const SizedBox(height: 20),

                    // Botón para cerrar sesión
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        if (mounted) {
                          // Se corrige el nombre de la clase de rutas
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        }
                      },
                      child: const Text("Cerrar sesión"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

