import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/database/model/identifiable_serializable.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends IdentifiableSerializableBase {
  final String userId;
  final TransactionType type;
  final Cryptocurrency cryptoCurrency;
  final double amount;
  final double priceInEur;
  final DateTime date;

  TransactionModel({
    required super.id,
    required this.userId,
    required this.type,
    required this.cryptoCurrency,
    required this.amount,
    required this.priceInEur,
    required this.date,
  });

  @override
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
}
