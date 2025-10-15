import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});
  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtl = TextEditingController();
  final ageCtl = TextEditingController();
  final birthPlaceCtl = TextEditingController();
  final ailmentsCtl = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    nameCtl.dispose();
    ageCtl.dispose();
    birthPlaceCtl.dispose();
    ailmentsCtl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(user!.uid);
    await docRef.set({
      'nombre': nameCtl.text.trim(),
      'edad': int.tryParse(ageCtl.text.trim()) ?? 0,
      'lugar_nacimiento': birthPlaceCtl.text.trim(),
      'padecimientos': ailmentsCtl.text.trim(),
      'email': user!.email,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v==null||v.isEmpty? 'Ingresa nombre' : null),
              TextFormField(controller: ageCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad'), validator: (v)=> v==null||v.isEmpty? 'Ingresa edad' : null),
              TextFormField(controller: birthPlaceCtl, decoration: const InputDecoration(labelText: 'Lugar de nacimiento')),
              TextFormField(controller: ailmentsCtl, decoration: const InputDecoration(labelText: 'Padecimientos (opcional)')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProfile, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
