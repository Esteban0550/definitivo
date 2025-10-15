import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_form_page.dart';
import 'info_page.dart'; // pagina generica para privacidad/sobre

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Perfil'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileFormPage())),
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacidad'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoPage(title: 'Privacidad', content: 'Texto de privacidad...'))),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Sobre nosotros'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoPage(title: 'Sobre nosotros', content: 'Acerca de la app...'))),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/'); // o usa MaterialPageRoute al LoginPage
          },
        ),
      ],
    );
  }
}
