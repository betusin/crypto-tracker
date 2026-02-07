import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_tracker/database/model/serializable.dart';

typedef JsonDoc = Map<String, dynamic>;
typedef DocDeserializer<T> = T Function(JsonDoc json);

const _ID_JSON_KEY = 'id';

T? deserializeJsonDocument<T>(DocumentSnapshot document, DocDeserializer<T> documentDeserializer) {
  final jsonData = (document.data() as Map<String, dynamic>?)?..[_ID_JSON_KEY] = document.id;

  if (jsonData == null) {
    return null;
  }

  return documentDeserializer(jsonData);
}

Map<String, dynamic> serializeDocument<T extends Serializable>(T document) {
  return document.toJson()..withoutId();
}

extension _IdExtension on JsonDoc {
  void withoutId() => remove(_ID_JSON_KEY);
}
