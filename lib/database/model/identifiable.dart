abstract interface class Identifiable {
  String get id;
}

abstract class IdentifiableBase implements Identifiable {
  @override
  final String id;

  const IdentifiableBase({required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Identifiable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
