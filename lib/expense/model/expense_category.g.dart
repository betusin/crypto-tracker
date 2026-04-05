// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseCategory _$ExpenseCategoryFromJson(Map<String, dynamic> json) =>
    ExpenseCategory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? true,
      iconName: json['iconName'] as String? ?? 'category',
    );

Map<String, dynamic> _$ExpenseCategoryToJson(ExpenseCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'isCustom': instance.isCustom,
      'iconName': instance.iconName,
    };
