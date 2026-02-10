import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction_import/model/transaction_import_error.dart';
import 'package:crypto_tracker/transaction_import/service/transaction_importer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TransactionImportButton extends StatefulWidget {
  const TransactionImportButton({super.key});

  @override
  State<TransactionImportButton> createState() => _TransactionImportButtonState();
}

class _TransactionImportButtonState extends State<TransactionImportButton> {
  final _transactionsRepository = getIt<FirestoreRepository<TransactionModel>>();
  final _transactionImporter = getIt<TransactionImporter>();

  Future<void> _pickAndImportFile() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickerResult != null && pickerResult.files.single.path != null) {
      _handleImport(pickerResult.files.single.path!);
    }
  }

  Future<void> _handleImport(String path) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importing...')));
    }

    final result = await _transactionImporter.importFromExcel(path);

    if (result.isFailure) {
      if (mounted) {
        final message = switch (result.error) {
          TransactionImportError.fileNotFound => 'File not found',
          TransactionImportError.userNotSignedIn => 'User not signed in',
          TransactionImportError.invalidExcelFile => 'Invalid Excel file',
          TransactionImportError.noDataFound => 'No transactions found in the file',
          _ => 'Unknown error occurred',
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    final transactions = result.data!;
    await _transactionsRepository.addAll(transactions);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import successful')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.file_upload), onPressed: _pickAndImportFile, tooltip: 'Import Excel');
  }
}
