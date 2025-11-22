enum TransactionType { buy, sell }

class TransactionModel {
  final int? id;
  final TransactionType type;
  final String cryptoId;
  final double amount;
  final double pricePerUnit;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.type,
    required this.cryptoId,
    required this.amount,
    required this.pricePerUnit,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'cryptoId': cryptoId,
      'amount': amount,
      'pricePerUnit': pricePerUnit,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: TransactionType.values[map['type']],
      cryptoId: map['cryptoId'],
      amount: map['amount'],
      pricePerUnit: map['pricePerUnit'],
      date: DateTime.parse(map['date']),
    );
  }
}
