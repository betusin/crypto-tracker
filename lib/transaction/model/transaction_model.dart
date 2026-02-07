import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';

// TODO(betka): use serializable, identifiable
class TransactionModel {
  final String? id;
  final String userId;
  final TransactionType type;
  final Cryptocurrency cryptoCurrency;
  final double amount;
  final double pricePerUnit;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.cryptoCurrency,
    required this.amount,
    required this.pricePerUnit,
    required this.date,
  });

  // TODO(betka): use JsonSerializable instead
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.index,
      'cryptoId': cryptoCurrency,
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
      cryptoCurrency: Cryptocurrency.values.firstWhere((e) => e.name == map['cryptoId']),
      amount: map['amount'],
      pricePerUnit: map['pricePerUnit'],
      date: DateTime.parse(map['date']),
    );
  }
}
