/// KYC journeys from the Figma "USD KYC" and "GBP/EUR KYC" rows. The wallet
/// currency decides which journey a user must complete.
enum KycFlow {
  usd('USD', [KycStep.employment, KycStep.income, KycStep.selfie]),
  gbpEur('GBP/EUR', [
    KycStep.employment,
    KycStep.income,
    KycStep.identity,
    KycStep.idDetails,
    KycStep.address,
    KycStep.utility,
  ]);

  final String label;
  final List<KycStep> steps;
  const KycFlow(this.label, this.steps);

  /// GBP and EUR accounts need the full GBP/EUR KYC; every other currency
  /// (NGN, USD, KES…) is covered by the USD tier.
  static KycFlow forCurrencyCode(String code) => switch (code.toUpperCase()) {
    'GBP' || 'EUR' => KycFlow.gbpEur,
    _ => KycFlow.usd,
  };

  /// Step that follows [step], or null when [step] is the last one.
  KycStep? stepAfter(KycStep step) {
    final i = steps.indexOf(step);
    return i < 0 || i == steps.length - 1 ? null : steps[i + 1];
  }
}

enum KycStep {
  employment,
  income,
  identity,
  idDetails,
  address,
  utility,
  selfie,
}

enum KycStatus {
  unverified('Unverified'),
  inReview('In review'),
  verified('Verified'),
  failed('Failed');

  final String label;
  const KycStatus(this.label);
}

enum EmploymentStatus {
  employed('Employed'),
  selfEmployed('Self-employed'),
  unemployed('Unemployed'),
  student('Student');

  final String label;
  const EmploymentStatus(this.label);
}

enum IncomeBand {
  upTo100('0 - \$100'),
  upTo10k('\$100 - \$10,000'),
  upTo100k('\$10,000 - \$100,000'),
  upTo1m('\$100,000 - \$1M'),
  upTo100m('\$1M - \$100M'),
  above100m('\$100M - Above');

  final String label;
  const IncomeBand(this.label);
}

enum MeansOfId {
  votersCard("Voter's Card"),
  nin('NIN'),
  driversLicense("Driver's license"),
  passport('Passport');

  final String label;
  const MeansOfId(this.label);
}

/// A file the user attached (bank statement, ID photo, utility bill, selfie).
class KycDocument {
  final String name;
  final String path;
  final int sizeBytes;
  final bool isImage;

  const KycDocument({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.isImage,
  });

  static const maxSizeBytes = 10 * 1024 * 1024;

  String get readableSize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).ceil()} KB';
  }
}

/// Month/year pair entered as MM/YY on the ID details step.
class MonthYear {
  final int month;
  final int year;

  const MonthYear(this.month, this.year);

  /// Parses `MM/YY`; returns null when malformed or the month is invalid.
  static MonthYear? tryParse(String input) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(input.trim());
    if (match == null) return null;
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return null;
    return MonthYear(month, year);
  }

  bool isBefore(MonthYear other) =>
      year < other.year || (year == other.year && month < other.month);

  static MonthYear fromDate(DateTime d) => MonthYear(d.month, d.year);

  @override
  String toString() =>
      '${month.toString().padLeft(2, '0')}/${(year % 100).toString().padLeft(2, '0')}';
}

class KycAddress {
  final String country;
  final String state;
  final String city;
  final String street;

  const KycAddress({
    this.country = '',
    this.state = '',
    this.city = '',
    this.street = '',
  });

  bool get isComplete =>
      [country, state, city, street].every((v) => v.trim().isNotEmpty);

  KycAddress copyWith({
    String? country,
    String? state,
    String? city,
    String? street,
  }) => KycAddress(
    country: country ?? this.country,
    state: state ?? this.state,
    city: city ?? this.city,
    street: street ?? this.street,
  );
}

enum KycDocumentSlot { bankStatement, idFront, utilityBill, selfie }

/// Everything collected across a KYC journey.
class KycApplication {
  final EmploymentStatus? employmentStatus;
  final String occupation;
  final IncomeBand? incomeBand;
  final KycDocument? bankStatement;
  final DateTime? dateOfBirth;
  final MeansOfId? meansOfId;
  final KycDocument? idFront;
  final String idNumber;
  final MonthYear? idIssueDate;
  final MonthYear? idExpiryDate;
  final KycAddress address;
  final KycDocument? utilityBill;
  final KycDocument? selfie;

  const KycApplication({
    this.employmentStatus,
    this.occupation = '',
    this.incomeBand,
    this.bankStatement,
    this.dateOfBirth,
    this.meansOfId,
    this.idFront,
    this.idNumber = '',
    this.idIssueDate,
    this.idExpiryDate,
    this.address = const KycAddress(),
    this.utilityBill,
    this.selfie,
  });

  KycApplication copyWith({
    EmploymentStatus? employmentStatus,
    String? occupation,
    IncomeBand? incomeBand,
    KycDocument? bankStatement,
    DateTime? dateOfBirth,
    MeansOfId? meansOfId,
    KycDocument? idFront,
    String? idNumber,
    MonthYear? idIssueDate,
    MonthYear? idExpiryDate,
    KycAddress? address,
    KycDocument? utilityBill,
    KycDocument? selfie,
  }) {
    return KycApplication(
      employmentStatus: employmentStatus ?? this.employmentStatus,
      occupation: occupation ?? this.occupation,
      incomeBand: incomeBand ?? this.incomeBand,
      bankStatement: bankStatement ?? this.bankStatement,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      meansOfId: meansOfId ?? this.meansOfId,
      idFront: idFront ?? this.idFront,
      idNumber: idNumber ?? this.idNumber,
      idIssueDate: idIssueDate ?? this.idIssueDate,
      idExpiryDate: idExpiryDate ?? this.idExpiryDate,
      address: address ?? this.address,
      utilityBill: utilityBill ?? this.utilityBill,
      selfie: selfie ?? this.selfie,
    );
  }

  KycDocument? document(KycDocumentSlot slot) => switch (slot) {
    KycDocumentSlot.bankStatement => bankStatement,
    KycDocumentSlot.idFront => idFront,
    KycDocumentSlot.utilityBill => utilityBill,
    KycDocumentSlot.selfie => selfie,
  };

  /// Sets or clears (with null) the document in [slot].
  KycApplication withDocument(KycDocumentSlot slot, KycDocument? doc) {
    return KycApplication(
      employmentStatus: employmentStatus,
      occupation: occupation,
      incomeBand: incomeBand,
      bankStatement: slot == KycDocumentSlot.bankStatement
          ? doc
          : bankStatement,
      dateOfBirth: dateOfBirth,
      meansOfId: meansOfId,
      idFront: slot == KycDocumentSlot.idFront ? doc : idFront,
      idNumber: idNumber,
      idIssueDate: idIssueDate,
      idExpiryDate: idExpiryDate,
      address: address,
      utilityBill: slot == KycDocumentSlot.utilityBill ? doc : utilityBill,
      selfie: slot == KycDocumentSlot.selfie ? doc : selfie,
    );
  }
}

/// Business rules for each step. Returns null when the step is complete,
/// otherwise the reason it cannot continue.
abstract final class KycRules {
  static const minimumAge = 18;

  static String? validateDateOfBirth(DateTime? dob, {DateTime? now}) {
    if (dob == null) return 'Select your date of birth';
    final today = now ?? DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    if (age < minimumAge) return 'You must be at least $minimumAge years old';
    if (age > 120) return 'Enter a valid date of birth';
    return null;
  }

  static String? validateIdNumber(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Enter your ID number';
    if (v.length < 6) return 'ID number looks too short';
    return null;
  }

  static String? validateIssueDate(MonthYear? issue, {DateTime? now}) {
    if (issue == null) return 'Use MM/YY';
    if (MonthYear.fromDate(now ?? DateTime.now()).isBefore(issue)) {
      return 'Cannot be in the future';
    }
    return null;
  }

  static String? validateExpiryDate(
    MonthYear? expiry, {
    MonthYear? issue,
    DateTime? now,
  }) {
    if (expiry == null) return 'Use MM/YY';
    if (expiry.isBefore(MonthYear.fromDate(now ?? DateTime.now()))) {
      return 'This ID has expired';
    }
    if (issue != null && !issue.isBefore(expiry)) {
      return 'Must be after issue date';
    }
    return null;
  }

  static String? validateStep(
    KycStep step,
    KycApplication app, {
    DateTime? now,
  }) {
    return switch (step) {
      KycStep.employment =>
        app.employmentStatus == null
            ? 'Select your employment status'
            : app.occupation.trim().isEmpty
            ? 'Enter your occupation'
            : null,
      KycStep.income =>
        app.incomeBand == null
            ? 'Select your income band'
            : app.bankStatement == null
            ? 'Upload a bank statement'
            : null,
      KycStep.identity =>
        validateDateOfBirth(app.dateOfBirth, now: now) ??
            (app.meansOfId == null ? 'Select a means of ID' : null) ??
            (app.idFront == null
                ? 'Add a front-view picture of your ID'
                : null),
      KycStep.idDetails =>
        validateIdNumber(app.idNumber) ??
            validateIssueDate(app.idIssueDate, now: now) ??
            validateExpiryDate(
              app.idExpiryDate,
              issue: app.idIssueDate,
              now: now,
            ),
      KycStep.address =>
        app.address.isComplete ? null : 'Complete your address',
      KycStep.utility =>
        app.utilityBill == null ? 'Upload a recent utility bill' : null,
      KycStep.selfie => app.selfie == null ? 'Take a selfie' : null,
    };
  }
}
