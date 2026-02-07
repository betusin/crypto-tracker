import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:rxdart/rxdart.dart';

class TransactionService {
  final _signedInUserService = getIt<SignedInUserProvider>();
  final _transactionRepository = getIt<FirestoreRepository<TransactionModel>>();

  Stream<List<TransactionModel>> observeTransactionsForCurrentUser() {
    return _signedInUserService.userStream.switchMap((user) {
      if (user == null) {
        return Stream.value([]);
      }
      return _transactionRepository.observeByQuery((collection) => collection.where('userId', isEqualTo: user.uid));
    });
  }

  // TODO(betka): create convenient add transaction which will generate the ID and get the current user
}
