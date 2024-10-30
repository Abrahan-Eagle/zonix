class Profile {
  final int id;
  final String name;
  final String email;

  Profile({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['firstName'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
    );
  }
}




// 
//class Profile {
//   final int id;
//   final String name;
//   final String email;

//   Profile({
//     required this.id,
//     required this.name,
//     required this.email,
//   });

//   factory Profile.fromJson(Map<String, dynamic> json) {
//     return Profile(
//       id: json['id'],
//       name: json['firstName'] ?? 'No Name', // Ajuste por consistencia
//       email: json['user_id'].toString(), // Conversión a string para asegurar compatibilidad
//     );
//   }
// }
