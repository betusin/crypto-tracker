import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:rxdart/rxdart.dart';

class TransactionService {
  final SignedInUserProvider _signedInUserService;
  final FirestoreRepository<TransactionModel> _transactionRepository;

  TransactionService(this._signedInUserService, this._transactionRepository);

  Stream<List<TransactionModel>> observeTransactionsForCurrentUser() {
    return _signedInUserService.userStream.switchMap((user) {
      if (user == null) {
        return Stream.value([]);
      }
      return _transactionRepository.observeByQuery(
        (collection) => collection.orderBy('date', descending: true).where('userId', isEqualTo: user.uid),
      );
    });
  }

  // TODO(betka): create convenient add transaction which will generate the ID and get the current user
}
