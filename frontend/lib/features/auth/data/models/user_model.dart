// User model representing authenticated user data
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final DateTime? createdAt;
  final bool isVerified; // For clinician verification by admin

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.createdAt,
    this.isVerified = true, // Default true for admin and patient
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
      isVerified: json['isVerified'] ?? true,
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
      'isVerified': isVerified,
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
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id, 
      email: email ?? this.email, 
      name: name ?? this.name, 
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // checking if user is admin
  bool get isAdmin => role == 'admin';

  // or clinician
  bool get isClinician => role == 'clinician';

  // or patient
  bool get isPatient => role == 'patient';
  
  // Check if pending verification (for clinicians)
  bool get isPending => isClinician && !isVerified;
}