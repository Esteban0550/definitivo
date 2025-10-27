// Importa el paquete principal de Flutter para construir interfaces gráficas
import 'package:flutter/material.dart';
// Importa el paquete de autenticación de Firebase
import 'package:firebase_auth/firebase_auth.dart';
// Importa la página principal del sistema (pantalla de inicio)
import 'home_page.dart';

// Define un widget con estado llamado SimiLoginPage
class SimiLoginPage extends StatefulWidget {
  const SimiLoginPage({super.key}); // Constructor con clave opcional

  @override
  State<SimiLoginPage> createState() => _SimiLoginPageState(); // Crea el estado asociado
}

// Clase que maneja el estado del widget de login
class _SimiLoginPageState extends State<SimiLoginPage> {
  final _formKey = GlobalKey<FormState>(); // Llave para validar el formulario
  final TextEditingController emailCtl = TextEditingController(); // Controlador del campo email
  final TextEditingController passCtl = TextEditingController(); // Controlador del campo contraseña
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de FirebaseAuth para autenticación
  bool showPass = false; // Controla si se muestra la contraseña
  bool loading = false; // Controla si se muestra el indicador de carga

  // Función asincrónica para iniciar sesión
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return; // Valida el formulario
    setState(() => loading = true); // Activa el estado de carga
    try {
      // Intenta iniciar sesión con Firebase
      await _auth.signInWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      if (mounted) {
        // Si el widget sigue montado, navega a la página principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Muestra un mensaje de error si falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      // Desactiva el estado de carga
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // Función asincrónica para crear una nueva cuenta
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return; // Valida el formulario
    setState(() => loading = true); // Activa el estado de carga
    try {
      // Crea una cuenta en Firebase con correo y contraseña
      await _auth.createUserWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      if (mounted) {
        // Navega a la página principal si todo sale bien
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Muestra un mensaje de error si ocurre un problema
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      // Desactiva el indicador de carga
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // Libera los controladores cuando el widget se destruye
  @override
  void dispose() {
    emailCtl.dispose();
    passCtl.dispose();
    super.dispose();
  }

  // Construye la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Color de fondo azul claro
      body: Center(
        child: SingleChildScrollView( // Permite desplazamiento vertical
          padding: const EdgeInsets.all(30), // Margen interno
          child: Form(
            key: _formKey, // Asocia la llave del formulario
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos
              children: [
                const Text(
                  "Bienvenido a Simi Salud 🩺", // Título
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E8DF5), // Azul
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50), // Espacio vertical
                // Campo para ingresar correo electrónico
                TextFormField(
                  controller: emailCtl,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 20),
                // Campo para ingresar la contraseña
                TextFormField(
                  controller: passCtl,
                  obscureText: !showPass, // Oculta o muestra la contraseña
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton( // Botón para mostrar/ocultar contraseña
                      icon: Icon(
                          showPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => showPass = !showPass),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 30),
                // Botón para iniciar sesión
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _signIn, // Deshabilitado si está cargando
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E8DF5),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('INICIAR SESIÓN',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón para crear una nueva cuenta
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: loading ? null : _createAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3E8DF5),
                      side: const BorderSide(color: Color(0xFF3E8DF5), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Crear cuenta nueva',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 30),
                // Texto decorativo inferior
                const Text("💙 Atención médica con el toque Simi 💙",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF3E8DF5), fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
