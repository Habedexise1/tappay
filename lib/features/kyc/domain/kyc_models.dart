enum EmploymentStatus {
  employed('Employed', 'Full-time or part-time salary worker'),
  selfEmployed('Self-Employed', 'Freelancer, contractor, or business owner'),
  student('Student', 'Enrolled in accredited education institution'),
  unemployed('Unemployed', 'Currently seeking employment'),
  retired('Retired', 'Retired professional');

  final String label;
  final String description;
  const EmploymentStatus(this.label, this.description);
}

enum IncomeBand {
  under1k('Under \$1,000 / month'),
  from1kTo3k('\$1,000 - \$3,000 / month'),
  from3kTo7k('\$3,000 - \$7,000 / month'),
  from7kTo15k('\$7,000 - \$15,000 / month'),
  over15k('Over \$15,000 / month');

  final String label;
  const IncomeBand(this.label);
}

enum IdType {
  nationalId('National Identity Card', 'Government issued National ID'),
  passport('International Passport', 'Machine-readable travel passport'),
  driverLicense('Driver’s License', 'State or national driving permit');

  final String label;
  final String description;
  const IdType(this.label, this.description);
}

class KycProfile {
  final EmploymentStatus? employmentStatus;
  final IncomeBand? incomeBand;
  final String? bankStatementPath;
  final IdType idType;
  final String idNumber;
  final DateTime? dateOfBirth;
  final String? idFrontPath;
  final String? idBackPath;
  final String? selfiePhotoPath;
  final bool isVerified;

  const KycProfile({
    this.employmentStatus,
    this.incomeBand,
    this.bankStatementPath,
    this.idType = IdType.nationalId,
    this.idNumber = '',
    this.dateOfBirth,
    this.idFrontPath,
    this.idBackPath,
    this.selfiePhotoPath,
    this.isVerified = false,
  });

  KycProfile copyWith({
    EmploymentStatus? employmentStatus,
    IncomeBand? incomeBand,
    String? bankStatementPath,
    IdType? idType,
    String? idNumber,
    DateTime? dateOfBirth,
    String? idFrontPath,
    String? idBackPath,
    String? selfiePhotoPath,
    bool? isVerified,
  }) {
    return KycProfile(
      employmentStatus: employmentStatus ?? this.employmentStatus,
      incomeBand: incomeBand ?? this.incomeBand,
      bankStatementPath: bankStatementPath ?? this.bankStatementPath,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      idFrontPath: idFrontPath ?? this.idFrontPath,
      idBackPath: idBackPath ?? this.idBackPath,
      selfiePhotoPath: selfiePhotoPath ?? this.selfiePhotoPath,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

