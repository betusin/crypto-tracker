import 'package:crypto_tracker/database/model/identifiable_serializable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_category.g.dart';

@JsonSerializable()
class ExpenseCategory extends IdentifiableSerializableBase {
  final String userId;
  final String name;
  final bool isCustom;
  final String iconName;

  ExpenseCategory({
    required super.id,
    required this.userId,
    required this.name,
    this.isCustom = true,
    this.iconName = 'category',
  });

  @override
  Map<String, dynamic> toJson() => _$ExpenseCategoryToJson(this);

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => _$ExpenseCategoryFromJson(json);
}
