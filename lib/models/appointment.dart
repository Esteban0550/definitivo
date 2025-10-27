class Appointment {
  final String? id;
  final String patientName;
  final String doctorName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String reason;
  final String clinicAddress;
  final String instructions;

  Appointment({
    this.id,
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.clinicAddress = '',
    this.instructions = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
      'clinicAddress': clinicAddress,
      'instructions': instructions,
    };
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      patientName: map['patientName'] ?? '',
      doctorName: map['doctorName'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      reason: map['reason'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }
}