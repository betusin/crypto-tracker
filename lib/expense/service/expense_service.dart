import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final SignedInUserProvider _signedInUserProvider;
  final FirestoreRepository<Expense> _expenseRepository;
  final FirestoreRepository<ExpenseCategory> _categoryRepository;

  ExpenseService(this._signedInUserProvider, this._expenseRepository, this._categoryRepository);

  String get _userId => _signedInUserProvider.currentUser!.uid;

  Stream<List<Expense>> observeExpensesForCurrentUser() {
    return _expenseRepository.observeByQuery((query) => query.where('userId', isEqualTo: _userId));
  }

  Stream<List<ExpenseCategory>> observeCategoriesForCurrentUser() {
    return _categoryRepository.observeByQuery((query) => query.where('userId', isEqualTo: _userId));
  }

  Future<void> seedDefaultCategoriesIfEmpty() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('expense_categories')
        .where('userId', isEqualTo: _userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      final defaultCategories = {
        'Food': 0xe390, // lunch_dining
        'Dining Out': 0xe56c, // restaurant
        'Transportation': 0xe1d7, // directions_car
        'Household': 0xe318, // home
        'Healthcare': 0xf10d, // medical_services
        'Social Life': 0xf07a, // groups
        'Shopping': 0xf37d, // shopping_bag
        'Sport': 0xe281, // fitness_center
        'Other': 0xe148, // category
      };

      final batch = FirebaseFirestore.instance.batch();
      for (final entry in defaultCategories.entries) {
        final docRef = FirebaseFirestore.instance.collection('expense_categories').doc();
        batch.set(docRef, {
          'id': docRef.id,
          'userId': _userId,
          'name': entry.key,
          'isCustom': false,
          'iconCodePoint': entry.value,
        });
      }
      await batch.commit();
    }
  }
}
