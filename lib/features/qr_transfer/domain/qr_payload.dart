import 'dart:convert';

/// QR Payload structure for TapPay transfers.
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

  /// Serialize to standard JSON string for QR generator
  String toRawString() {
    return jsonEncode({
      'app': 'tappay',
      'recipient': recipient,
      'handle': accountHandle,
      'amount': amount,
      'note': note,
    });
  }

  /// Parse from scanned QR raw string
  static QrTransferPayload? fromRawString(String raw) {
    try {
      if (raw.startsWith('{') && raw.endsWith('}')) {
        final Map<String, dynamic> data = jsonDecode(raw);
        return QrTransferPayload(
          recipient: data['recipient'] ?? 'TapPay User',
          accountHandle: data['handle'] ?? '@user',
          amount: data['amount'] != null ? (data['amount'] as num).toDouble() : null,
          note: data['note'],
        );
      }
      // Fallback for simple handle string
      return QrTransferPayload(
        recipient: raw,
        accountHandle: raw.startsWith('@') ? raw : '@$raw',
      );
    } catch (_) {
      return null;
    }
  }
}

