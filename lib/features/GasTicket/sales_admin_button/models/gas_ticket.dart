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
  final String qrCode;

  // Datos de perfil
  final String firstName;
  final String middleName;
  final String lastName;
  final String secondLastName;
  final String photoUser;
  final String dateOfBirth;
  final String maritalStatus;
  final String sex;
  final String profileStatus;

  // Datos de usuario
  final String userName;
  final String userEmail;
  final String userProfilePic;

  // Datos de teléfono, emails, documentos y direcciones
  final List<String> phoneNumbers;
  final List<String> emailAddresses;
  final List<String> documentImages;
  final List<String> addresses;
  final String gasCylinderCode;
  final String cylinderQuantity;
  final String cylinderType;
  final String cylinderWeight;
  final String gasCylinderPhoto;
  final String manufacturingDate;

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
    required this.qrCode,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.secondLastName,
    required this.photoUser,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.sex,
    required this.profileStatus,
    required this.userName,
    required this.userEmail,
    required this.userProfilePic,
    required this.phoneNumbers,
    required this.emailAddresses,
    required this.documentImages,
    required this.addresses,
    required this.gasCylinderCode,
    required this.cylinderQuantity,
    required this.cylinderType,
    required this.cylinderWeight,
    required this.gasCylinderPhoto,
    required this.manufacturingDate,
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
      qrCode: json['qr_code'],
      
      // Datos del perfil
      firstName: json['profile']['firstName'],
      middleName: json['profile']['middleName'],
      lastName: json['profile']['lastName'],
      secondLastName: json['profile']['secondLastName'],
      photoUser: json['profile']['photo_users'],
      dateOfBirth: json['profile']['date_of_birth'],
      maritalStatus: json['profile']['maritalStatus'],
      sex: json['profile']['sex'],
      profileStatus: json['profile']['status'],

      // Datos del usuario
      userName: json['profile']['user']['name'],
      userEmail: json['profile']['user']['email'],
      userProfilePic: json['profile']['user']['profile_pic'],

      // Datos de teléfono, emails, documentos y direcciones
      phoneNumbers: List<String>.from(json['profile']['phones'].map((phone) => phone['number'])),
      emailAddresses: List<String>.from(json['profile']['emails'].map((email) => email['email'])),
      documentImages: List<String>.from(json['profile']['documents'].map((document) => document['front_image'])),
      addresses: List<String>.from(json['profile']['addresses'].map((address) => address['street'])),
      
      // Datos de bombonas de gas
      gasCylinderCode: json['gas_cylinder']['gas_cylinder_code'],
      cylinderQuantity: json['gas_cylinder']['cylinder_quantity'].toString(),
      cylinderType: json['gas_cylinder']['cylinder_type'],
      cylinderWeight: json['gas_cylinder']['cylinder_weight'],
      gasCylinderPhoto: json['gas_cylinder']['photo_gas_cylinder'],
      manufacturingDate: json['gas_cylinder']['manufacturing_date'],
    );
  }
}


// // lib/features/GasTicket/models/gas_ticket.dart
// class GasTicket {
//   final int id;
//   final int profileId;
//   final int gasCylindersId;
//   final String status;
//   final String reservedDate;
//   final String appointmentDate;
//   final String expiryDate;
//   final String queuePosition;
//   final String timePosition;
//   final String qrCode;
  

//   GasTicket({
//     required this.id,
//     required this.profileId,
//     required this.gasCylindersId,
//     required this.status,
//     required this.reservedDate,
//     required this.appointmentDate,
//     required this.expiryDate,
//     required this.queuePosition,
//     required this.timePosition,
//     required this.qrCode,
//   });

//   factory GasTicket.fromJson(Map<String, dynamic> json) {
//     return GasTicket(
//       id: json['id'],
//       profileId: json['profile_id'],
//       gasCylindersId: json['gas_cylinders_id'],
//       status: json['status'],
//       reservedDate: json['reserved_date'],
//       appointmentDate: json['appointment_date'],
//       expiryDate: json['expiry_date'],
//       queuePosition: json['queue_position'].toString(),
//       timePosition: json['time_position'],
//       qrCode: json['qr_code'],
//     );
//   }
// }