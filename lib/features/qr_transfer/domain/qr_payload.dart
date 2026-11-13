import 'dart:convert';

class QrTransferPayload {
  final String recipient;
  final String accountHandle;
  final double? amount;
  final String? note;

  const QrTransferPayload({
    required this.recipient,
    required this.accountHandle,
    this.amount,
    this.note,
  });

  String toRawString() {
    return jsonEncode({
      'app': 'tappay',
      'recipient': recipient,
      'handle': accountHandle,
      'amount': amount,
      'note': note,
    });
  }

  static QrTransferPayload? fromRawString(String raw) {
    try {
      if (raw.startsWith('{') && raw.endsWith('}')) {
        final Map<String, dynamic> data = jsonDecode(raw);
        return QrTransferPayload(
          recipient: data['recipient'] ?? 'TapPay User',
          accountHandle: data['handle'] ?? '@user',
          amount: data['amount'] != null
              ? (data['amount'] as num).toDouble()
              : null,
          note: data['note'],
        );
      }

      return QrTransferPayload(
        recipient: raw,
        accountHandle: raw.startsWith('@') ? raw : '@$raw',
      );
    } catch (_) {
      return null;
    }
  }
}
