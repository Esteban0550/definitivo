import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimiLoginPage extends StatefulWidget {
  const SimiLoginPage({super.key});

  @override
  State<SimiLoginPage> createState() => _SimiLoginPageState();
}

class _SimiLoginPageState extends State<SimiLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showPass = false;
  bool loading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenido ${user.user?.email ?? ''} 💊")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta creada con éxito 🩺")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtl.dispose();
    passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/en/d/d5/Dr._Simi_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Bienvenido a Simi Salud 🩺",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailCtl,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passCtl,
                  obscureText: !showPass,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          showPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => showPass = !showPass),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(loading ? 'Entrando...' : 'Iniciar sesión'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: loading ? null : _createAccount,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Crear cuenta nueva'),
                ),
                const SizedBox(height: 20),
                const Text(
                  "💙 Atención médica con el toque Simi 💙",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
