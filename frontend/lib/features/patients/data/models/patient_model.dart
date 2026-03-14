class PatientModel {
  final String id;
  final String name;
  final int age;
  final String address;
  final String phoneNumber;
  final String clinicianId;
  final DateTime createdAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.address,
    required this.phoneNumber,
    required this.clinicianId,
    required this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      address: (json['address'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      clinicianId: (json['clinicianId'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'address': address,
      'phoneNumber': phoneNumber,
      'clinicianId': clinicianId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
