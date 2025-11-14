import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardStats extends DashboardEvent {
  final String doctorName;

  const LoadDashboardStats(this.doctorName);

  @override
  List<Object> get props => [doctorName];
}

