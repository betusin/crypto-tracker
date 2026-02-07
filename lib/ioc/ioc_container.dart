import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/database/util/collection_names.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:get_it/get_it.dart';

final GetIt get = GetIt.instance;

class IocContainer {
  const IocContainer._();

  static void setup() {
    get.registerSingleton(FirestoreRepository(CollectionNames.transactions, TransactionModel.fromJson));
  }
}
