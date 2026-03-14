class ClinicianModel {
  final String id;
  final ClinicianName name;
  final ClinicianCredentials credentials;
  final ClinicianContact contact;
  final List<ClinicianAvailability> availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClinicianModel({
    required this.id,
    required this.name,
    required this.credentials,
    required this.contact,
    required this.availability,
    this.createdAt,
    this.updatedAt,
  });

  // from json
  factory ClinicianModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['fullName'] ?? '').toString().trim();
    final nameJson = (json['name'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final split = fullName.isEmpty ? <String>[] : fullName.split(RegExp(r'\s+'));
    final inferredFirstName = split.isNotEmpty ? split.first : '';
    final inferredLastName = split.length > 1 ? split.sublist(1).join(' ') : '';

    final mergedName = <String, dynamic>{
      'firstName': nameJson['firstName'] ?? inferredFirstName,
      'lastName': nameJson['lastName'] ?? inferredLastName,
      'title': nameJson['title'] ?? '',
    };

    final contactJson = (json['contact'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final mergedContact = <String, dynamic>{
      'email': contactJson['email'] ?? json['email'] ?? '',
      'phone': contactJson['phone'] ?? json['phone'] ?? '',
      'officeAddress': contactJson['officeAddress'] ?? <String, dynamic>{},
    };

    return ClinicianModel(
      id: json['id'] ?? json['_id'] ?? '', 
      name: ClinicianName.fromJson(mergedName), 
      credentials: ClinicianCredentials.fromJson(json['credentials'] ?? {}), 
      contact: ClinicianContact.fromJson(mergedContact), 
      availability: (json['availability'] as List<dynamic>?)
        ?.map((e) => ClinicianAvailability.fromJson(e))
        .toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'credentials': credentials.toJson(),
      'contact': contact.toJson(),
      'availability': availability.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Full name helper
  String get fullName {
    final value = '${name.title} ${name.firstName} ${name.lastName}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return value.isEmpty ? 'Clinician' : value;
  }
}

// Name structure
class ClinicianName {
  final String firstName;
  final String lastName;
  final String title;

  ClinicianName({
    required this.firstName,
    required this.lastName,
    required this.title,
  });

  factory ClinicianName.fromJson(Map<String, dynamic> json) {
    return ClinicianName(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'title': title,
    };
  }
}

// Credentials structure
class ClinicianCredentials {
  final String licenseNumber;
  final String specialty;
  final List<Certification> certifications;

  ClinicianCredentials({
    required this.licenseNumber,
    required this.specialty,
    required this.certifications,
  });

  factory ClinicianCredentials.fromJson(Map<String, dynamic> json) {
    return ClinicianCredentials(
      licenseNumber: json['licenseNumber'] ?? '',
      specialty: json['specialty'] ?? '',
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => Certification.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'specialty': specialty,
      'certifications': certifications.map((e) => e.toJson()).toList(),
    };
  }
}

// Certification structure
class Certification {
  final String name;
  final String issuedBy;
  final DateTime issueDate;

  Certification({
    required this.name,
    required this.issuedBy,
    required this.issueDate,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] ?? '',
      issuedBy: json['issuedBy'] ?? '',
      issueDate: DateTime.parse(json['issueDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuedBy': issuedBy,
      'issueDate': issueDate.toIso8601String(),
    };
  }
}

// Contact structure
class ClinicianContact {
  final String email;
  final String phone;
  final OfficeAddress officeAddress;

  ClinicianContact({
    required this.email,
    required this.phone,
    required this.officeAddress,
  });

  factory ClinicianContact.fromJson(Map<String, dynamic> json) {
    return ClinicianContact(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      officeAddress: OfficeAddress.fromJson(json['officeAddress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'officeAddress': officeAddress.toJson(),
    };
  }
}

// Office Address structure
class OfficeAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  OfficeAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory OfficeAddress.fromJson(Map<String, dynamic> json) {
    return OfficeAddress(
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

  // Full address helper
  String get fullAddress => '$street, $city, $state $postalCode, $country';
}

// Availability structure
class ClinicianAvailability {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String location;

  ClinicianAvailability({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory ClinicianAvailability.fromJson(Map<String, dynamic> json) {
    return ClinicianAvailability(
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
    };
  }
}