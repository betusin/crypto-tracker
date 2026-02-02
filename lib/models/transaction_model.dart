enum TransactionType { buy, sell }

// TODO(betka): use serializable, identifiable
class TransactionModel {
  final String? id;
  final String userId;
  final TransactionType type;
  final String cryptoId;
  final double amount;
  final double pricePerUnit;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.cryptoId,
    required this.amount,
    required this.pricePerUnit,
    required this.date,
  });

  // TODO(betka): use JsonSerializable
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.index,
      'cryptoId': cryptoId,
      'amount': amount,
      'pricePerUnit': pricePerUnit,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      type: TransactionType.values[map['type']],
      cryptoId: map['cryptoId'],
      amount: map['amount'],
      pricePerUnit: map['pricePerUnit'],
      date: DateTime.parse(map['date']),
    );
  }
}
