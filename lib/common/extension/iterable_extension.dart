extension IterableNum<T extends num> on Iterable<T> {
  T get sum {
    if (isEmpty) return (T == int ? 0 : 0.0) as T;
    return reduce((a, b) => (a + b) as T);
  }
}

extension IterableNumBy<T> on Iterable<T> {
  num sumBy(num Function(T element) selector) {
    return map(selector).sum;
  }
}
