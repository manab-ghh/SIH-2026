class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String preferredLanguage;
  final String profileImage;
  final String location;
  final String craftSpecialty;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.preferredLanguage = 'hi',
    this.profileImage = '',
    this.location = '',
    this.craftSpecialty = '',
    this.role = 'artisan',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Artisan',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? 'hi',
      profileImage: json['profileImage'] ?? '',
      location: json['location'] ?? 'Varanasi, India',
      craftSpecialty: json['craftSpecialty'] ?? 'Handloom & Handicrafts',
      role: json['role'] ?? 'artisan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'preferredLanguage': preferredLanguage,
      'profileImage': profileImage,
      'location': location,
      'craftSpecialty': craftSpecialty,
      'role': role,
    };
  }
}
