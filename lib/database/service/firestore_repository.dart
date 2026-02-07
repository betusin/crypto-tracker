import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_tracker/database/model/identifiable_serializable.dart';
import 'package:crypto_tracker/database/util/firestore_document_serialization.dart';

class FirestoreRepository<T extends IdentifiableSerializable> {
  final String collection;
  final CollectionReference<Map<String, dynamic>> _collectionReference;
  final CollectionReference<T> _collectionMappedReference;

  FirestoreRepository(this.collection, DocDeserializer<T> mapper)
    : _collectionReference = FirebaseFirestore.instance.collection(collection),
      _collectionMappedReference = FirebaseFirestore.instance
          .collection(collection)
          .withConverter(
            fromFirestore: (snapshot, _) => deserializeJsonDocument(snapshot, mapper)!,
            toFirestore: (model, _) => serializeDocument(model),
          );

  Future<void> add(T item) {
    return _collectionMappedReference.add(item);
  }

  Future<void> delete(String id) {
    return _collectionReference.doc(id).delete();
  }

  Future<void> update(String id, JsonDoc json) {
    return _collectionReference.doc(id).update(json);
  }

  Future<void> set(String id, JsonDoc json, {bool merge = false}) {
    return _collectionReference.doc(id).set(json, SetOptions(merge: merge));
  }

  Future<T?> get(String id) async {
    final snapshot = await _collectionMappedReference.doc(id).get();
    if (snapshot.exists) {
      return snapshot.data() as T;
    }
    return null;
  }

  Future<List<T>> getAll() async {
    final snapshot = await _collectionMappedReference.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
