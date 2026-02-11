import 'dart:async';
import 'package:rxdart/rxdart.dart';

class Refetcher<T> {
  final Future<T> Function() _fetchFunction;
  final Duration _interval;

  final _subject = BehaviorSubject<T>();
  Timer? _timer;

  Refetcher({
    required Future<T> Function() fetchFunction,
    Duration interval = const Duration(seconds: 5),
    bool automaticStart = true,
  }) : _fetchFunction = fetchFunction,
       _interval = interval {
    if (automaticStart) {
      start();
    }
  }

  Stream<T> get stream => _subject.stream;

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(_interval, (_) => _fetch());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refetch() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _fetchFunction();
      _subject.add(data);
    } catch (e, stackTrace) {
      _subject.addError(e, stackTrace);
    }
  }

  void dispose() {
    stop();
    _subject.close();
  }
}
