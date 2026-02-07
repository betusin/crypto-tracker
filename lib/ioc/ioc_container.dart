import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/database/util/collection_names.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class IocContainer {
  const IocContainer._();

  static void setup() {
    getIt.registerSingleton(FirestoreRepository(CollectionNames.transactions, TransactionModel.fromJson));
    getIt.registerSingleton(AuthService());
    getIt.registerSingleton(SignedInUserProvider(getIt<AuthService>()));
  }
}
