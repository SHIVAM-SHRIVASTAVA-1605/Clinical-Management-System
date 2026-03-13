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
}
