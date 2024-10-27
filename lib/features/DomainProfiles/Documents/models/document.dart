import 'profile.dart'; // Asegúrate de que la ruta sea correcta

class Document {
  final int id;
  final String type;
  final String? number;
  final String? frontImage;
  final String? issuedAt;
  final String? expiresAt;
  final Profile profile;

  Document({
    required this.id,
    required this.type,
    this.number,
    this.frontImage,
    this.issuedAt,
    this.expiresAt,
    required this.profile,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      type: json['type']?.toString() ?? 'Unknown',
      number: json['number']?.toString(),
      frontImage: json['front_image'] as String?,
      issuedAt: json['issued_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      profile: Profile.fromJson(json['profile']),
    );
  }
}
