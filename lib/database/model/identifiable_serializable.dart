import 'package:crypto_tracker/database/model/identifiable.dart';
import 'package:crypto_tracker/database/model/serializable.dart';

abstract interface class IdentifiableSerializable implements Identifiable, Serializable {}

abstract class IdentifiableSerializableBase extends IdentifiableBase implements IdentifiableSerializable {
  const IdentifiableSerializableBase({required super.id});
}
