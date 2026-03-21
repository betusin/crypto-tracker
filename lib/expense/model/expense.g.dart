// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  categoryId: json['categoryId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: $enumDecode(_$FiatCurrencyEnumMap, json['currency']),
  amountInCzk: (json['amountInCzk'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'currency': _$FiatCurrencyEnumMap[instance.currency]!,
  'amountInCzk': instance.amountInCzk,
  'date': instance.date.toIso8601String(),
};

const _$FiatCurrencyEnumMap = {
  FiatCurrency.eur: 'eur',
  FiatCurrency.czk: 'czk',
};
