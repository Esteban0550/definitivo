import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // <--- AÑADIDO: Import para widgets de iOS
import 'dart:io'; // <--- AÑADIDO: Import para detectar la plataforma (iOS/Android)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_routes.dart'; // (Asegúrate que este sea el nombre correcto de tu archivo de rutas)

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

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    enfermedadesController.dispose();
    super.dispose();
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
        // Mostramos un SnackBar de error (simple y funciona en ambas plataformas)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
      }, SetOptions(merge: true)); // Usamos merge para no sobrescribir otros campos si existen

      // --- INICIO DE LÓGICA ADAPTATIVA ---
      // Mostramos un feedback diferente basado en la plataforma
      if (mounted) {
        if (Platform.isIOS) {
          // Muestra un diálogo de Cupertino en iOS
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Éxito'),
              content: const Text('Información guardada exitosamente'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        } else {
          // Muestra un SnackBar en Android (Material)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Información guardada exitosamente')),
          );
        }
      }
      // --- FIN DE LÓGICA ADAPTATIVA ---

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Lógica para cerrar sesión (extraída para reusar)
  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      // Usamos el nombre de tus rutas
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // --- CONSTRUCCIÓN DEL WIDGET ---
  @override
  Widget build(BuildContext context) {
    // Detectamos la plataforma
    final bool isIOS = Platform.isIOS;

    if (isIOS) {
      return _buildCupertinoPage();
    } else {
      return _buildMaterialPage();
    }
  }

  // --- WIDGET BUILDER PARA MATERIAL (ANDROID) ---
  Widget _buildMaterialPage() {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil de Usuario")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones
                  children: [
                    Text(
                      "Correo: ${user?.email ?? 'No disponible'}",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
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
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Volver al Menú Principal"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signOut, // Llama a la función de cerrar sesión
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Color rojo para cerrar sesión
                      ),
                      child: const Text("Cerrar sesión"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET BUILDER PARA CUPERTINO (iOS) ---
  Widget _buildCupertinoPage() {
    final user = _auth.currentUser;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Perfil de Usuario"),
      ),
      child: SafeArea( // SafeArea para evitar el notch y la barra inferior de iOS
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones
                    children: [
                      Text(
                        "Correo: ${user?.email ?? 'No disponible'}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Usamos CupertinoTextField para iOS
                      CupertinoTextField(
                        controller: nombreController,
                        placeholder: 'Nombre completo',
                        padding: const EdgeInsets.all(12),
                      ),
                      const SizedBox(height: 10),
                      CupertinoTextField(
                        controller: telefonoController,
                        placeholder: 'Teléfono',
                        keyboardType: TextInputType.phone,
                        padding: const EdgeInsets.all(12),
                      ),
                      const SizedBox(height: 10),
                      CupertinoTextField(
                        controller: enfermedadesController,
                        placeholder: 'Enfermedades',
                        maxLines: 3,
                        padding: const EdgeInsets.all(12),
                      ),
                      const SizedBox(height: 20),
                      // Usamos CupertinoButton para iOS
                      CupertinoButton.filled( // Botón con fondo
                        onPressed: _saveUserData,
                        child: const Text("Guardar información"),
                      ),
                      const SizedBox(height: 30),
                      CupertinoButton( // Botón sin fondo
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Volver al Menú Principal"),
                      ),
                      const SizedBox(height: 20),
                      CupertinoButton(
                        color: CupertinoColors.destructiveRed, // Color rojo de iOS
                        onPressed: _signOut, // Llama a la función de cerrar sesión
                        child: const Text("Cerrar sesión"),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
