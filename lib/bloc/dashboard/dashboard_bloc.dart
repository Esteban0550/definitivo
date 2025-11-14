import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AppointmentService _appointmentService;
  StreamSubscription<List<Appointment>>? _appointmentsSubscription;
  StreamSubscription<List<Appointment>>? _upcomingSubscription;
  StreamSubscription<int>? _patientsSubscription;

  int _totalAppointments = 0;
  int _upcomingAppointments = 0;
  int _uniquePatients = 0;
  bool _initialized = false;
  Emitter<DashboardState>? _currentEmitter;

  DashboardBloc(this._appointmentService) : super(DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    _currentEmitter = emit;
    
    if (!_initialized) {
      emit(DashboardLoading());
    }

    // Cancelar suscripciones anteriores si existen
    await _appointmentsSubscription?.cancel();
    await _upcomingSubscription?.cancel();
    await _patientsSubscription?.cancel();

    // Resetear valores solo si no está inicializado
    if (!_initialized) {
      _totalAppointments = 0;
      _upcomingAppointments = 0;
      _uniquePatients = 0;
    }

    try {
      // Suscribirse a los streams para actualización en tiempo real
      _appointmentsSubscription = _appointmentService
          .getAppointmentsByDoctor(event.doctorName)
          .listen((appointments) {
        _totalAppointments = appointments.length;
        _emitLoadedState();
      });

      _upcomingSubscription = _appointmentService
          .getUpcomingAppointmentsByDoctor(event.doctorName)
          .listen((upcoming) {
        _upcomingAppointments = upcoming.length;
        _emitLoadedState();
      });

      _patientsSubscription = _appointmentService
          .getUniquePatientsCountByDoctor(event.doctorName)
          .listen((count) {
        _uniquePatients = count;
        _emitLoadedState();
      });

      // Cargar valores iniciales solo la primera vez
      if (!_initialized) {
        final appointments = await _appointmentService
            .getAppointmentsByDoctor(event.doctorName)
            .first;
        _totalAppointments = appointments.length;

        final upcoming = await _appointmentService
            .getUpcomingAppointmentsByDoctor(event.doctorName)
            .first;
        _upcomingAppointments = upcoming.length;

        final uniquePatients = await _appointmentService
            .getUniquePatientsCountByDoctor(event.doctorName)
            .first;
        _uniquePatients = uniquePatients;

        _initialized = true;
        _emitLoadedState();
      }
    } catch (e) {
      emit(DashboardError('Error al cargar estadísticas: $e'));
    }
  }

  void _emitLoadedState() {
    if (_currentEmitter != null) {
      _currentEmitter!(DashboardLoaded(
        totalAppointments: _totalAppointments,
        upcomingAppointments: _upcomingAppointments,
        uniquePatients: _uniquePatients,
      ));
    }
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _patientsSubscription?.cancel();
    return super.close();
  }
}

