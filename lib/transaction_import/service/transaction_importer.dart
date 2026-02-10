import 'dart:io';

import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/common/model/failable_result.dart';
import 'package:crypto_tracker/common/util/id_generator.dart';
import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:crypto_tracker/transaction_import/model/transaction_import_error.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class TransactionImporter {
  static const _dateColumn = 0;
  static const _typeColumn = 1;
  static const _amountColumn = 2;
  static const _priceColumn = 3;

  static const _cryptoCurrency = Cryptocurrency.bitcoin;
  static const _startRowIndex = 4;

  final SignedInUserProvider _signedInUserProvider;

  TransactionImporter(this._signedInUserProvider);

  Future<FailableResult<List<TransactionModel>, TransactionImportError>> importFromExcel(String filePath) async {
    final userId = _signedInUserProvider.currentUser?.uid;
    if (userId == null) {
      return FailableResult.failure(TransactionImportError.userNotSignedIn);
    }

    final Excel excel;
    try {
      excel = await _decodeExcel(filePath);
    } catch (e) {
      return FailableResult.failure(TransactionImportError.fileNotFound);
    }

    final transactions = <TransactionModel>[];

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) {
        continue;
      }

      transactions.addAll(_parseSheet(sheet, userId));
    }

    if (transactions.isEmpty) {
      return FailableResult.failure(TransactionImportError.noDataFound);
    }

    return FailableResult.success(transactions);
  }

  Future<Excel> _decodeExcel(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    return Excel.decodeBytes(bytes);
  }

  List<TransactionModel> _parseSheet(Sheet sheet, String userId) {
    final transactions = <TransactionModel>[];

    for (int i = _startRowIndex; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      try {
        final transaction = _parseRow(row, userId);
        if (transaction != null) {
          transactions.add(transaction);
        }
      } catch (e) {
        debugPrint('Error parsing row $i: $e');
      }
    }

    return transactions;
  }

  TransactionModel? _parseRow(List<Data?> row, String userId) {
    final date = _parseDate(row[_dateColumn]?.value);
    if (date == null) {
      return null;
    }

    final type = _parseType(row[_typeColumn]?.value);
    final amount = _cellValueToDouble(row[_amountColumn]?.value);
    final price = _cellValueToDouble(row[_priceColumn]?.value);

    return TransactionModel(
      id: generateId(),
      userId: userId,
      cryptoCurrency: _cryptoCurrency,
      type: type,
      amount: amount.abs(),
      pricePerUnit: price,
      date: date,
    );
  }

  DateTime? _parseDate(CellValue? value) {
    return switch (value) {
      DateCellValue() => DateTime(value.year, value.month, value.day),
      TextCellValue() => DateTime.tryParse(value.value.text ?? ''),
      _ => null,
    };
  }

  TransactionType _parseType(CellValue? value) {
    final typeString = switch (value) {
      TextCellValue() => value.value.text?.toLowerCase() ?? '',
      _ => value?.toString().toLowerCase() ?? '',
    };

    return typeString.contains('buy') ? TransactionType.buy : TransactionType.sell;
  }

  double _cellValueToDouble(CellValue? value) {
    return switch (value) {
      DoubleCellValue() => value.value,
      IntCellValue() => value.value.toDouble(),
      TextCellValue() => double.tryParse(value.value.text ?? '') ?? 0.0,
      _ => 0.0,
    };
  }
}
