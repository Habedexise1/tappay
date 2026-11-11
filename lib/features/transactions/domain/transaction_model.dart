enum TransactionStatus {
  completed('Completed'),
  pending('Pending'),
  failed('Failed');

  final String label;
  const TransactionStatus(this.label);
}

enum TransactionType {
  inflow,
  outflow,
}

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final TransactionType type;
  final String referenceNumber;
  final double fee;
  final String recipientName;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    required this.referenceNumber,
    this.fee = 0.0,
    required this.recipientName,
    this.note,
  });

  bool get isOutflow => type == TransactionType.outflow;

  TransactionModel copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    TransactionStatus? status,
    TransactionType? type,
    String? referenceNumber,
    double? fee,
    String? recipientName,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      type: type ?? this.type,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      fee: fee ?? this.fee,
      recipientName: recipientName ?? this.recipientName,
      note: note ?? this.note,
    );
  }
}

