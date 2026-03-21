import 'package:crypto_tracker/database/model/identifiable_serializable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_tracker/currency/model/fiat_currency.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense extends IdentifiableSerializableBase {
  final String userId;
  final String title;
  final String categoryId;
  final double amount;
  final FiatCurrency currency;
  final double amountInCzk;
  final DateTime date;

  Expense({
    required super.id,
    required this.userId,
    required this.title,
    required this.categoryId,
    required this.amount,
    required this.currency,
    required this.amountInCzk,
    required this.date,
  });

  @override
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
