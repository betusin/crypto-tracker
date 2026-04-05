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
        'Food': 'lunch_dining',
        'Dining Out': 'restaurant',
        'Transportation': 'directions_car',
        'Household': 'home',
        'Healthcare': 'local_hospital',
        'Social Life': 'nightlife',
        'Shopping': 'shopping_bag',
        'Sport': 'fitness_center',
        'Other': 'category',
      };

      final batch = FirebaseFirestore.instance.batch();
      for (final entry in defaultCategories.entries) {
        final docRef = FirebaseFirestore.instance.collection('expense_categories').doc();
        batch.set(docRef, {
          'id': docRef.id,
          'userId': _userId,
          'name': entry.key,
          'isCustom': false,
          'iconName': entry.value,
        });
      }
      await batch.commit();
    }
  }
}
