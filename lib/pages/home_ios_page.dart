import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeIOSPage extends StatefulWidget {
  const HomeIOSPage({super.key});

  @override
  State<HomeIOSPage> createState() => _HomeIOSPageState();
}

class _HomeIOSPageState extends State<HomeIOSPage> {
  final List<String> _notifications = [
    'Tu cita médica ha sido confirmada',
    'Nuevo mensaje de tu doctor',
    'Recordatorio: toma tus medicamentos',
  ];

  bool _loading = false;
  bool _isFavorite = false;

  // --- VARIABLES PARA LOS NUEVOS WIDGETS ---
  bool _notificationsEnabled = true;
  int? _selectedSegment = 0;
  final _searchController = TextEditingController();
  // --- FIN VARIABLES NUEVAS ---

  @override
  void dispose() {
    // Es buena práctica limpiar los controllers
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // setState(() => _loading = true); // El RefreshControl lo maneja
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _notifications.add('Nueva actualización del sistema');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Simi Salud', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _refresh,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('👋 ¡Bienvenido de nuevo!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => CupertinoActionSheet(
                            title: const Text('Acciones disponibles'),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Agendar cita'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Ver mensajes'),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ),
                        );
                      },
                      child: const Text('Opciones rápidas'),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Ahora el corazón también activa el ActivityIndicator
                        setState(() {
                          _isFavorite = !_isFavorite;
                          _loading = !_loading; // Alterna el estado de carga
                        });
                      },
                      child: Icon(
                        _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: _isFavorite
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemGrey,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- NUEVO WIDGET 1: CupertinoSearchTextField ---
                    CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Buscar doctor o servicio...',
                      onChanged: (value) {
                        // Aquí puedes poner tu lógica de búsqueda
                      },
                    ),
                    // --- FIN NUEVO WIDGET 1 ---

                    const SizedBox(height: 20),

                    // --- NUEVO WIDGET 2: CupertinoSlidingSegmentedControl ---
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedSegment,
                        onValueChanged: (value) {
                          setState(() => _selectedSegment = value);
                        },
                        children: const {
                          0: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Notificaciones')),
                          1: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Mensajes')),
                        },
                      ),
                    ),
                    // --- FIN NUEVO WIDGET 2 ---

                    const SizedBox(height: 20),

                    // --- NUEVO WIDGET 3: CupertinoSwitch ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recibir Notificaciones', style: TextStyle(fontSize: 16)),
                          CupertinoSwitch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    // --- FIN NUEVO WIDGET 3 ---

                    const SizedBox(height: 10),

                    // --- NUEVO WIDGET 4: CupertinoAlertDialog (con botón) ---
                    CupertinoButton(
                      child: const Text('Mostrar Alerta'),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Alerta Importante'),
                            content: const Text('Esta es una acción de ejemplo.'),
                            actions: [
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: const Text('Aceptar'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // --- FIN NUEVO WIDGET 4 ---

                    const SizedBox(height: 20),

                    // --- NUEVO WIDGET 5: CupertinoActivityIndicator ---
                    // Se muestra si _loading es true (controlado por el corazón)
                    if (_loading)
                      const CupertinoActivityIndicator(radius: 15),
                    // --- FIN NUEVO WIDGET 5 ---
                  ],
                ),
              ),
            ),

            // Lista de notificaciones (sin cambios)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final notif = _notifications[index];
                  return Material(
                    type: MaterialType.transparency,
                    child: Dismissible(
                      key: ValueKey(notif),
                      background: Container(
                        color: CupertinoColors.destructiveRed,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child:
                            const Icon(CupertinoIcons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() => _notifications.removeAt(index));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CupertinoListTile(
                          title: Text(notif,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          trailing: const Icon(CupertinoIcons.right_chevron),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _notifications.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}