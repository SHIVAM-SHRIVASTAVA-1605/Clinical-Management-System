// Patient model following backend schema
class PatientModel {
  final String id;
  final PatientName name;
  final PatientDemographics demographics;
  final PatientContact contact;
  final MedicalHistory medicalHistory;
  final List<String> assignedClinicianIds;
  final EmergencyContact? emergencyContact;
  final Insurance? insurance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.demographics,
    required this.contact,
    required this.medicalHistory,
    required this.assignedClinicianIds,
    this.emergencyContact,
    this.insurance,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: PatientName.fromJson(json['name'] ?? {}),
      demographics: PatientDemographics.fromJson(json['demographics'] ?? {}),
      contact: PatientContact.fromJson(json['contact'] ?? {}),
      medicalHistory: MedicalHistory.fromJson(json['medicalHistory'] ?? {}),
      assignedClinicianIds: (json['assignedClinicianIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContact.fromJson(json['emergencyContact'])
          : null,
      insurance: json['insurance'] != null
          ? Insurance.fromJson(json['insurance'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'demographics': demographics.toJson(),
      'contact': contact.toJson(),
      'medicalHistory': medicalHistory.toJson(),
      'assignedClinicianIds': assignedClinicianIds,
      'emergencyContact': emergencyContact?.toJson(),
      'insurance': insurance?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Full name helper
  String get fullName => '${name.firstName} ${name.lastName}';

  // Age calculation
  int get age {
    if (demographics.dateOfBirth == null) return 0;
    final now = DateTime.now();
    final dob = demographics.dateOfBirth!;
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}

// Patient Name structure
class PatientName {
  final String firstName;
  final String lastName;
  final String? middleName;

  PatientName({
    required this.firstName,
    required this.lastName,
    this.middleName,
  });

  factory PatientName.fromJson(Map<String, dynamic> json) {
    return PatientName(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
    };
  }
}

// Patient Demographics
class PatientDemographics {
  final DateTime? dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String? maritalStatus;
  final String? occupation;

  PatientDemographics({
    this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.maritalStatus,
    this.occupation,
  });

  factory PatientDemographics.fromJson(Map<String, dynamic> json) {
    return PatientDemographics(
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      maritalStatus: json['maritalStatus'],
      occupation: json['occupation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
    };
  }
}

// Patient Contact
class PatientContact {
  final String email;
  final String phone;
  final String? alternatePhone;
  final PatientAddress address;

  PatientContact({
    required this.email,
    required this.phone,
    this.alternatePhone,
    required this.address,
  });

  factory PatientContact.fromJson(Map<String, dynamic> json) {
    return PatientContact(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      alternatePhone: json['alternatePhone'],
      address: PatientAddress.fromJson(json['address'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'address': address.toJson(),
    };
  }
}

// Patient Address
class PatientAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  PatientAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory PatientAddress.fromJson(Map<String, dynamic> json) {
    return PatientAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  String get fullAddress => '$street, $city, $state $postalCode, $country';
}

// Medical History
class MedicalHistory {
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<PastSurgery> pastSurgeries;
  final List<String> currentMedications;
  final String? bloodPressure;
  final String? height;
  final String? weight;

  MedicalHistory({
    required this.allergies,
    required this.chronicConditions,
    required this.pastSurgeries,
    required this.currentMedications,
    this.bloodPressure,
    this.height,
    this.weight,
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pastSurgeries: (json['pastSurgeries'] as List<dynamic>?)
              ?.map((e) => PastSurgery.fromJson(e))
              .toList() ??
          [],
      currentMedications: (json['currentMedications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      bloodPressure: json['bloodPressure'],
      height: json['height'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'pastSurgeries': pastSurgeries.map((e) => e.toJson()).toList(),
      'currentMedications': currentMedications,
      'bloodPressure': bloodPressure,
      'height': height,
      'weight': weight,
    };
  }

  // BMI calculation
  double? get bmi {
    if (height == null || weight == null) return null;
    final h = double.tryParse(height!) ?? 0;
    final w = double.tryParse(weight!) ?? 0;
    if (h == 0) return null;
    return w / ((h / 100) * (h / 100));
  }
}

// Past Surgery
class PastSurgery {
  final String procedure;
  final DateTime date;
  final String? hospital;

  PastSurgery({
    required this.procedure,
    required this.date,
    this.hospital,
  });

  factory PastSurgery.fromJson(Map<String, dynamic> json) {
    return PastSurgery(
      procedure: json['procedure'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      hospital: json['hospital'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procedure': procedure,
      'date': date.toIso8601String(),
      'hospital': hospital,
    };
  }
}

// Emergency Contact
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
    };
  }
}

// Insurance Information
class Insurance {
  final String provider;
  final String policyNumber;
  final DateTime? expiryDate;

  Insurance({
    required this.provider,
    required this.policyNumber,
    this.expiryDate,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      provider: json['provider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'policyNumber': policyNumber,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}