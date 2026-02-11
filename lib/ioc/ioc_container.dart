import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/common/service/refetch_service.dart';
import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/database/util/collection_names.dart';
import 'package:crypto_tracker/price/service/current_price_controller.dart';
import 'package:crypto_tracker/price/service/price_service.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/service/holding_service.dart';
import 'package:crypto_tracker/transaction_import/service/transaction_importer.dart';
import 'package:crypto_tracker/transaction/service/transaction_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class IocContainer {
  const IocContainer._();

  static void setup() {
    getIt.registerSingleton(FirestoreRepository(CollectionNames.transactions, TransactionModel.fromJson));
    getIt.registerSingleton(AuthService());
    getIt.registerSingleton(SignedInUserProvider(getIt<AuthService>()));

    getIt.registerSingleton(PriceService());

    getIt.registerSingleton(
      TransactionService(getIt<SignedInUserProvider>(), getIt<FirestoreRepository<TransactionModel>>()),
    );
    getIt.registerSingleton(TransactionImporter(getIt<SignedInUserProvider>()));
    getIt.registerSingleton(
      Refetcher<Map<Cryptocurrency, double>>(fetchFunction: getIt<PriceService>().fetchCurrentPrices),
    );
    getIt.registerSingleton(CurrentPriceController(getIt<Refetcher<Map<Cryptocurrency, double>>>()));
    getIt.registerSingleton(HoldingService(getIt<TransactionService>(), getIt<CurrentPriceController>()));
  }
}
