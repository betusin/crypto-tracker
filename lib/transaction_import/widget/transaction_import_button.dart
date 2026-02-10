import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importing...')));
        }

        final transactions = await _transactionImporter.importFromExcel(path);

        if (transactions.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No transactions found')));
          }
          return;
        }

        await _transactionsRepository.addAll(transactions);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import successful')));
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.file_upload), onPressed: _pickAndImportFile, tooltip: 'Import Excel');
  }
}
