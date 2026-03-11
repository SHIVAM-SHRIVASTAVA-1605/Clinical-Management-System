// User model representing authenticated user data
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.createdAt,
  });

  // Create Usermodel from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '', 
      email: json['email'] ?? '', 
      name: json['name'] ?? '', 
      role: json['role'] ?? 'patient',
      phone: json['phone'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
}

// Convert usermodel to json
Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'email' : email,
      'name' : name,
      'role' : role,
      'phone' : phone,
      'createdAt' : createdAt?.toIso8601String(),
    };
  }

  // create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id, 
      email: email ?? this.email, 
      name: name ?? this.name, 
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // checking if user is admin
  bool get isAdmin => role == 'admin';

  // or clinician
  bool get isClinician => role == 'clinician';

  // or patient
  bool get isPatient => role == 'patient';
}