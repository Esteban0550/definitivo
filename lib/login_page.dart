import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class SimiLoginPage extends StatefulWidget {
  const SimiLoginPage({super.key});

  @override
  State<SimiLoginPage> createState() => _SimiLoginPageState();
}

class _SimiLoginPageState extends State<SimiLoginPage> {
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showPass = false;
  bool loading = false;
  bool acceptTerms = false;
  String selectedRole = 'Paciente'; // Rol por defecto

  // Recarga (pull-to-refresh). Limpia campos y muestra diálogo Cupertino.
  Future<void> _recargarFormulario() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      emailCtl.clear();
      passCtl.clear();
      acceptTerms = false;
      showPass = false;
    });

    // Mostrar diálogo de confirmación estilo Cupertino (no usar SnackBar aquí)
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Actualizado'),
          content: const Text('Formulario recargado ✅'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Aviso'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _translateError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      default:
        return 'Ocurrió un error. Intenta de nuevo.';
    }
  }

  Future<void> _signIn() async {
    if (!acceptTerms) {
      _showErrorDialog('Debes aceptar los términos y condiciones para continuar.');
      return;
    }
    if (emailCtl.text.isEmpty || passCtl.text.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos.');
      return;
    }

    setState(() => loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_translateError(e));
    } catch (_) {
      _showErrorDialog('Error inesperado. Intenta más tarde.');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createAccount() async {
    if (!acceptTerms) {
      _showErrorDialog('Debes aceptar los términos y condiciones para continuar.');
      return;
    }
    if (emailCtl.text.isEmpty || passCtl.text.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos.');
      return;
    }
    if (passCtl.text.length < 6) {
      _showErrorDialog('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailCtl.text.trim(),
        password: passCtl.text.trim(),
      );
      
      // Guardar el rol en Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'rol': selectedRole,
          'uid': userCredential.user!.uid,
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_translateError(e));
    } catch (_) {
      _showErrorDialog('Error inesperado. Intenta más tarde.');
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
    // IMPORTANTE: como usamos RefreshIndicator (widget Material), lo envolvemos en Material
    // para evitar errores de "no Material ancestor" cuando el app usa CupertinoPageScaffold.
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Simi Salud 🩺'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Material( // <-- Proporciona el ancestro Material necesario para RefreshIndicator
          color: Colors.transparent,
          child: RefreshIndicator(
            onRefresh: _recargarFormulario,
            color: CupertinoColors.activeBlue,
            backgroundColor: CupertinoColors.white,
            displacement: 50,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("💙", style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 10),
                  const Text(
                    "Bienvenido a Simi Salud",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Correo
                  CupertinoTextField(
                    controller: emailCtl,
                    placeholder: "Correo electrónico",
                    keyboardType: TextInputType.emailAddress,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  CupertinoTextField(
                    controller: passCtl,
                    placeholder: "Contraseña",
                    obscureText: !showPass,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                    ),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.only(right: 12),
                      onPressed: () => setState(() => showPass = !showPass),
                      child: Icon(
                        showPass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selector de Rol
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.person_alt, color: CupertinoColors.systemGrey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Rol:',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Text(
                                selectedRole,
                                style: const TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                size: 16,
                                color: CupertinoColors.activeBlue,
                              ),
                            ],
                          ),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                title: const Text('Selecciona tu rol'),
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: const Text('Paciente'),
                                    onPressed: () {
                                      setState(() => selectedRole = 'Paciente');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text('Médico'),
                                    onPressed: () {
                                      setState(() => selectedRole = 'Médico');
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  isDestructiveAction: true,
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Aceptar términos y condiciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Acepto los términos y condiciones",
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      CupertinoSwitch(
                        value: acceptTerms,
                        onChanged: (v) => setState(() => acceptTerms = v),
                        activeColor: CupertinoColors.activeBlue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botón iniciar sesión
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: loading ? null : _signIn,
                      child: loading
                          ? const CupertinoActivityIndicator()
                          : const Text("INICIAR SESIÓN"),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón crear cuenta
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: loading ? null : _createAccount,
                      child: const Text("Crear cuenta nueva"),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "💊 Atención médica con el toque Simi 💊",
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
