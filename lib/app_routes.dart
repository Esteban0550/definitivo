import 'package:flutter/material.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'agendar_cita_page.dart';
import 'profile_page.dart';
import 'info_page.dart';
import 'profile_form_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/home': (context) => const HomePage(),
    '/mensajes': (context) => const MessagesPage(),
    '/ajustes': (context) => const SettingsPage(),
    '/perfil': (context) => const ProfileFormPage(),
    '/agendar': (context) => const AgendarCitaPage(),
    '/info': (context) =>
        const InfoPage(title: 'Información', content: 'Contenido pendiente'),
  };
}
