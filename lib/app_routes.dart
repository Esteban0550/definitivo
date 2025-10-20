import 'package:flutter/material.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'agendar_cita_page.dart';
import 'info_page.dart';
import 'profile_form_page.dart';
// Importa tu página de login
import 'login_page.dart';

class AppRoutes {
  // 1. Define el NOMBRE de la ruta de login como una constante
  static const String login = '/login';

  // 2. AGREGA la ruta de login al mapa de rutas
  static Map<String, WidgetBuilder> routes = {
    // Se añade la ruta para el login
    login: (context) => const SimiLoginPage(),
    '/home': (context) => const HomePage(),
    '/mensajes': (context) => const MessagesPage(),
    '/ajustes': (context) => const SettingsPage(),
    '/perfil': (context) => const ProfileFormPage(),
    '/agendar': (context) => const AgendarCitaPage(),
    '/info': (context) =>
        const InfoPage(title: 'Información', content: 'Contenido pendiente'),
  };
}
