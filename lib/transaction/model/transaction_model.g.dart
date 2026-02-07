// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      cryptoCurrency: $enumDecode(
        _$CryptocurrencyEnumMap,
        json['cryptoCurrency'],
      ),
      amount: (json['amount'] as num).toDouble(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'cryptoCurrency': _$CryptocurrencyEnumMap[instance.cryptoCurrency]!,
      'amount': instance.amount,
      'pricePerUnit': instance.pricePerUnit,
      'date': instance.date.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.buy: 'buy',
  TransactionType.sell: 'sell',
};

const _$CryptocurrencyEnumMap = {
  Cryptocurrency.bitcoin: 'bitcoin',
  Cryptocurrency.ethereum: 'ethereum',
};
