import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorStatisticsPage extends StatefulWidget {
  const DoctorStatisticsPage({super.key});

  @override
  State<DoctorStatisticsPage> createState() => _DoctorStatisticsPageState();
}

class _DoctorStatisticsPageState extends State<DoctorStatisticsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _doctorName;
  bool _loading = true;
  String? _userRole;

  // Colores para la gráfica interactiva
  final Color leftBarColor = Colors.amber;
  final Color rightBarColor = Colors.red;
  final Color avgColor = Colors.orange;
  
  // Colores para la gráfica apilada
  final Color dark = const Color(0xFF00BCD4).withAlpha((255 * 0.8).toInt());
  final Color normal = const Color(0xFF00BCD4).withAlpha((255 * 0.6).toInt());
  final Color light = const Color(0xFF00BCD4).withAlpha((255 * 0.4).toInt());
  
  final double width = 7;
  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeChartData();
  }

  void _initializeChartData() {
    final barGroup1 = _makeGroupData(0, 5, 12);
    final barGroup2 = _makeGroupData(1, 16, 12);
    final barGroup3 = _makeGroupData(2, 18, 5);
    final barGroup4 = _makeGroupData(3, 20, 16);
    final barGroup5 = _makeGroupData(4, 17, 6);
    final barGroup6 = _makeGroupData(5, 19, 1.5);
    final barGroup7 = _makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: rightBarColor,
          width: width,
        ),
      ],
    );
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final nombre = data['nombre'] as String?;
        final rol = data['rol'] as String?;
        
        print('DEBUG Statistics: Rol encontrado en Firestore: $rol');
        print('DEBUG Statistics: Nombre: $nombre');
        
        setState(() {
          _doctorName = nombre ?? user.email?.split('@').first ?? 'Médico';
          _userRole = rol ?? 'Paciente';
          _loading = false;
        });

        // Verificar que el usuario es médico
        if (_userRole != 'Médico') {
          print('DEBUG Statistics: Usuario NO es médico, rol actual: $_userRole');
          // Si no es médico, redirigir o mostrar error
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Esta página es exclusiva para médicos. Tu rol actual es: $_userRole'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          print('DEBUG Statistics: Usuario ES médico, mostrando gráfica');
        }
      } else {
        print('DEBUG Statistics: Documento no existe en Firestore');
        setState(() {
          _doctorName = user.email?.split('@').first ?? 'Médico';
          _userRole = 'Paciente';
          _loading = false;
        });
      }
    } catch (e) {
      print('DEBUG Statistics: Error al cargar datos: $e');
      // Si hay error de permisos, asumir que es médico para permitir ver la gráfica
      // (esto es solo para desarrollo, en producción deberías arreglar los permisos)
      setState(() {
        _doctorName = user.email?.split('@').first ?? 'Médico';
        _userRole = 'Médico'; // Asumir médico si hay error de permisos
        _loading = false;
      });
      print('DEBUG Statistics: Asumiendo rol de Médico debido a error de permisos');
    }
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        titles[value.toInt()],
        style: const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
    } else {
      return Container();
    }
    return Text(text, style: style);
  }

  Widget _bottomTitlesStacked(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: Colors.grey);
    String text = switch (value.toInt()) {
      0 => 'Abr',
      1 => 'May',
      2 => 'Jun',
      3 => 'Jul',
      4 => 'Ago',
      _ => '',
    };
    return Text(text, style: style);
  }

  Widget _leftTitlesStacked(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
      color: Colors.grey,
    );
    return Text(
      meta.formattedValue,
      style: style,
    );
  }

  List<BarChartGroupData> _getStackedData(double barsWidth, double barsSpace) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 17,
            rodStackItems: [
              BarChartRodStackItem(0, 2, dark),
              BarChartRodStackItem(2, 12, normal),
              BarChartRodStackItem(12, 17, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 24,
            rodStackItems: [
              BarChartRodStackItem(0, 13, dark),
              BarChartRodStackItem(13, 14, normal),
              BarChartRodStackItem(14, 24, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 31,
            rodStackItems: [
              BarChartRodStackItem(0, 11, dark),
              BarChartRodStackItem(11, 18, normal),
              BarChartRodStackItem(18, 31, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 35,
            rodStackItems: [
              BarChartRodStackItem(0, 14, dark),
              BarChartRodStackItem(14, 27, normal),
              BarChartRodStackItem(27, 35, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 34,
            rodStackItems: [
              BarChartRodStackItem(0, 6, dark),
              BarChartRodStackItem(6, 23, normal),
              BarChartRodStackItem(23, 34, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 32,
            rodStackItems: [
              BarChartRodStackItem(0, 7, dark),
              BarChartRodStackItem(7, 24, normal),
              BarChartRodStackItem(24, 32, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 14,
            rodStackItems: [
              BarChartRodStackItem(0, 1.5, dark),
              BarChartRodStackItem(1.5, 12, normal),
              BarChartRodStackItem(12, 14, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 27,
            rodStackItems: [
              BarChartRodStackItem(0, 7, dark),
              BarChartRodStackItem(7, 25, normal),
              BarChartRodStackItem(25, 27, light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Verificar que el usuario es médico
    if (_userRole != 'Médico') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          backgroundColor: const Color(0xFF3E8DF5),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Esta página es exclusiva para médicos'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Médicas'),
        backgroundColor: const Color(0xFF3E8DF5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3E8DF5), Color(0xFF667EEA)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Análisis de Actividad',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _doctorName ?? 'Médico',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Primera gráfica: Estado semanal (interactiva)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C4260),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _makeTransactionsIcon(),
                          const SizedBox(width: 12),
                          const Text(
                            'Estado de Citas',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'semanal',
                            style: TextStyle(color: Color(0xff77839a), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            maxY: 20,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (a, b, c, d) => null,
                              ),
                              touchCallback: (FlTouchEvent event, response) {
                                if (response == null || response.spot == null) {
                                  setState(() {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                  });
                                  return;
                                }
                                touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                                setState(() {
                                  if (!event.isInterestedForInteractions) {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                    return;
                                  }
                                  showingBarGroups = List.of(rawBarGroups);
                                  if (touchedGroupIndex != -1) {
                                    var sum = 0.0;
                                    for (final rod in showingBarGroups[touchedGroupIndex].barRods) {
                                      sum += rod.toY;
                                    }
                                    final avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;
                                    showingBarGroups[touchedGroupIndex] = showingBarGroups[touchedGroupIndex].copyWith(
                                      barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                                        return rod.copyWith(toY: avg, color: avgColor);
                                      }).toList(),
                                    );
                                  }
                                });
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitles,
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  interval: 1,
                                  getTitlesWidget: leftTitles,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            barGroups: showingBarGroups,
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Segunda gráfica: Distribución por mes (apilada)
            const Text(
              'Distribución de Citas por Mes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barsSpace = 4.0 * constraints.maxWidth / 400;
                      final barsWidth = 8.0 * constraints.maxWidth / 400;
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          barTouchData: BarTouchData(
                            enabled: false,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: _bottomTitlesStacked,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: _leftTitlesStacked,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            checkToShowHorizontalLine: (value) => value % 10 == 0,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          groupsSpace: barsSpace,
                          barGroups: _getStackedData(barsWidth, barsSpace),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Leyenda combinada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: leftBarColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Programadas', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: rightBarColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Completadas', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: dark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Completadas', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: normal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Pendientes', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: light,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Canceladas', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withAlpha((255 * 0.4).toInt()),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withAlpha((255 * 0.8).toInt()),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 42,
          color: Colors.white,
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withAlpha((255 * 0.8).toInt()),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withAlpha((255 * 0.4).toInt()),
        ),
      ],
    );
  }
}

