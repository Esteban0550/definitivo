import 'package:flutter/material.dart';

// Importaciones de las páginas existentes en tu proyecto
import 'home_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'agendar_cita_page.dart';
import 'info_page.dart';
import 'profile_form_page.dart';
import 'package:definitivo/login_page.dart';

// NUEVO: Importa el archivo para la página de Citas
// Asegúrate de haber creado el archivo 'citas_page.dart' en la carpeta 'lib'
import 'citas_page.dart';
import 'screens/appointments_list_screen.dart';

/// Clase centralizada para gestionar las rutas de la aplicación.
///
/// Define los nombres de las rutas como constantes estáticas para evitar errores
/// de escritura y los mapea a los widgets de página correspondientes.
class AppRoutes {
  // Nombres de las rutas definidos como constantes para mayor seguridad.
  static const String login = '/login';
  static const String home = '/home';
  static const String mensajes = '/mensajes';
  static const String ajustes = '/ajustes';
  static const String perfil = '/perfil';
  static const String agendar = '/agendar';
  static const String info = '/info';
  
  // NUEVO: Se define la constante para la ruta de citas
  static const String citas = '/citas';

  /// Mapa que asocia los nombres de las rutas con el constructor del widget de la página.
  ///
  /// Este mapa se utiliza en la propiedad `routes` de `MaterialApp`.
  static Map<String, WidgetBuilder> routes = {
    // Usamos las constantes como llaves para evitar errores de tipeo.
    login: (context) => const SimiLoginPage(),
    home: (context) => const HomePage(),
    mensajes: (context) => const MessagesPage(),
    ajustes: (context) => const SettingsPage(),
    perfil: (context) => const ProfileFormPage(),
    agendar: (context) => const AgendarCitaPage(),
    info: (context) =>
        const InfoPage(title: 'Información', content: 'Contenido pendiente'),
        
    // NUEVO: Se agrega la ruta y la página de citas al mapa
    citas: (context) => const CitasPage(),
    '/appointments': (context) => AppointmentsListScreen(),
  };
}