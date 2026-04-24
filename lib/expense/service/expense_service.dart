import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/currency/model/fiat_currency.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ExpenseService {
  final SignedInUserProvider _signedInUserProvider;
  final FirestoreRepository<Expense> _expenseRepository;
  final FirestoreRepository<ExpenseCategory> _categoryRepository;

  ExpenseService(this._signedInUserProvider, this._expenseRepository, this._categoryRepository);

  String get _userId => _signedInUserProvider.currentUser!.uid;

  Stream<List<Expense>> observeExpensesForCurrentUser() {
    return _expenseRepository.observeByQuery((query) => query.where('userId', isEqualTo: _userId));
  }

  Stream<Map<ExpenseCategory, double>> observeCategorizedExpensesForLast30Days() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return Rx.combineLatest2<List<Expense>, List<ExpenseCategory>, Map<ExpenseCategory, double>>(
      _expenseRepository.observeByQuery((query) => query.where('userId', isEqualTo: _userId)),
      observeCategoriesForCurrentUser(),
      (expenses, categories) {
        final recentExpenses = expenses.where((e) => e.date.isAfter(thirtyDaysAgo)).toList();
        final categoryMap = {for (var c in categories) c.id: c};
        final grouped = <ExpenseCategory, double>{};

        for (var expense in recentExpenses) {
          final category = categoryMap[expense.categoryId];
          if (category != null) {
            grouped[category] = (grouped[category] ?? 0) + expense.amountInCzk;
          }
        }
        return grouped;
      },
    );
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

  Future<bool> importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final file = File(result.files.single.path!);
      final String csvString = await file.readAsString();

      await seedDefaultCategoriesIfEmpty();

      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('expense_categories')
          .where('userId', isEqualTo: _userId)
          .get();

      final Map<String, ExpenseCategory> existingCategories = {};
      for (final doc in categoriesSnapshot.docs) {
        final cat = ExpenseCategory.fromJson(doc.data());
        existingCategories[cat.name.toLowerCase()] = cat;
      }

      final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      final lines = const LineSplitter().convert(csvString);

      final batch = FirebaseFirestore.instance.batch();
      final uuid = const Uuid();

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        
        final columns = line.split(';');
        if (columns.length < 9) continue;

        final dateStr = columns[0].trim();
        final rawCategoryStr = columns[2].trim();
        final title = columns[4].trim();
        final amountStr = columns[8].trim();

        DateTime parsedDate;
        try {
          parsedDate = dateFormat.parse(dateStr);
        } catch (e) {
          continue;
        }

        String parsedCategoryName = rawCategoryStr;
        final spaceIdx = rawCategoryStr.indexOf(' ');
        if (spaceIdx != -1 && spaceIdx < 4) {
           parsedCategoryName = rawCategoryStr.substring(spaceIdx + 1).trim();
        }

        ExpenseCategory? category = existingCategories[parsedCategoryName.toLowerCase()];
        if (category == null) {
          final newDocRef = FirebaseFirestore.instance.collection('expense_categories').doc();
          category = ExpenseCategory(
            id: newDocRef.id,
            userId: _userId,
            name: parsedCategoryName,
            isCustom: true,
            iconName: 'category',
          );
          batch.set(newDocRef, category.toJson());
          existingCategories[parsedCategoryName.toLowerCase()] = category;
        }

        double amount = 0.0;
        try {
           final cleanAmountStr = amountStr.replaceAll(',', '.').replaceAll(' ', '').trim();
           amount = double.parse(cleanAmountStr).abs();
        } catch (e) {
           continue; 
        }

        final expenseDocRef = FirebaseFirestore.instance.collection('expenses').doc(uuid.v4());
        final expense = Expense(
          id: expenseDocRef.id,
          userId: _userId,
          title: title.isEmpty ? parsedCategoryName : title,
          categoryId: category.id,
          amount: amount,
          currency: FiatCurrency.czk,
          amountInCzk: amount,
          date: parsedDate,
        );

        batch.set(expenseDocRef, expense.toJson());
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error importing CSV: $e');
      return false;
    }
  }
}
