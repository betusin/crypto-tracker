import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  final CollectionReference _transactionsCollection = FirebaseFirestore.instance.collection('transactions');

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsCollection.add(transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final snapshot = await _transactionsCollection.orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) {
      return TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }
}
