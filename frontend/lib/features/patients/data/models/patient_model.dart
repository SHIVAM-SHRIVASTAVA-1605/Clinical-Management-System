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
    final rawClinician = json['clinicianId'] ?? json['clinician'];
    String parsedClinicianId = '';
    if (rawClinician is Map<String, dynamic>) {
      parsedClinicianId =
          (rawClinician['id'] ?? rawClinician['_id'] ?? '').toString();
    } else if (rawClinician != null) {
      parsedClinicianId = rawClinician.toString();
    }

    return PatientModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      address: (json['address'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      clinicianId: parsedClinicianId,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'phoneNumber': phoneNumber,
      'clinicianId': clinicianId,
    };
  }
}
