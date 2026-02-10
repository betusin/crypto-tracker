import 'dart:io';

import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/common/util/id_generator.dart';
import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class TransactionImporter {
  final SignedInUserProvider _signedInUserProvider;

  TransactionImporter(this._signedInUserProvider);

  Future<List<TransactionModel>> importFromExcel(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final transactions = <TransactionModel>[];

    // TODO(betka): refactor this spaghetti code
    // TODO(betka): handle errors with MaybeFailure or similar
    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      // Start from 5th row (index 4)
      for (int i = 4; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        try {
          // Date (Column 0)
          final dateCell = row[0];
          DateTime date;
          if (dateCell == null) continue;

          final dateValue = dateCell.value;
          if (dateValue is DateTimeCellValue) {
            date = DateTime(dateValue.year, dateValue.month, dateValue.day, dateValue.hour, dateValue.minute);
          } else if (dateValue is DateCellValue) {
            date = DateTime(dateValue.year, dateValue.month, dateValue.day);
          } else if (dateValue is TextCellValue) {
            date = DateTime.parse(dateValue.value.text ?? '');
          } else {
            debugPrint('Row $i: Unknown date cell type: ${dateValue.runtimeType}');
            continue;
          }

          // Type (Column 1)
          final typeCell = row[1];
          if (typeCell == null) continue;
          String typeString = '';
          final typeValue = typeCell.value;
          if (typeValue is TextCellValue) {
            typeString = typeValue.value.text?.toLowerCase() ?? '';
          } else {
            typeString = typeValue.toString().toLowerCase();
          }
          final type = typeString.contains('buy') ? TransactionType.buy : TransactionType.sell;

          // BTC Amount (Column 2)
          final amountCell = row[2];
          double amount = 0.0;
          if (amountCell != null) {
            final val = amountCell.value;
            if (val is DoubleCellValue) {
              amount = val.value;
            } else if (val is IntCellValue) {
              amount = val.value.toDouble();
            } else if (val is TextCellValue) {
              amount = double.tryParse(val.value.text ?? '') ?? 0.0;
            }
          }

          // EUR Spent (Column 3)
          final eurCell = row[3];
          double price = 0.0;
          if (eurCell != null) {
            final val = eurCell.value;
            if (val is DoubleCellValue) {
              price = val.value;
            } else if (val is IntCellValue) {
              price = val.value.toDouble();
            } else if (val is TextCellValue) {
              price = double.tryParse(val.value.text ?? '') ?? 0.0;
            }
          }

          final userId = _signedInUserProvider.currentUser?.uid;
          if (userId == null) throw Exception('User not signed in');

          final transaction = TransactionModel(
            id: generateId(),
            userId: userId,
            cryptoCurrency: Cryptocurrency.bitcoin,
            type: type,
            amount: amount.abs(),
            pricePerUnit: price,
            date: date,
          );

          transactions.add(transaction);
        } catch (e) {
          debugPrint('Error parsing row $i: $e');
        }
      }
    }

    return transactions;
  }
}
