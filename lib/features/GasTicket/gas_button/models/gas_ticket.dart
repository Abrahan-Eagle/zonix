// lib/features/GasTicket/models/gas_ticket.dart
class GasTicket {
  final int id;
  final int profileId;
  final int gasCylindersId;
  final String status;
  final String reservedDate;
  final String appointmentDate;
  final String expiryDate;
  final String queuePosition;
  final String timePosition;

  GasTicket({
    required this.id,
    required this.profileId,
    required this.gasCylindersId,
    required this.status,
    required this.reservedDate,
    required this.appointmentDate,
    required this.expiryDate,
    required this.queuePosition,
    required this.timePosition,
  });

  factory GasTicket.fromJson(Map<String, dynamic> json) {
    return GasTicket(
      id: json['id'],
      profileId: json['profile_id'],
      gasCylindersId: json['gas_cylinders_id'],
      status: json['status'],
      reservedDate: json['reserved_date'],
      appointmentDate: json['appointment_date'],
      expiryDate: json['expiry_date'],
      queuePosition: json['queue_position'].toString(),
      timePosition: json['time_position'],
    );
  }
}
