import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestNotifier extends StateNotifier<int> {
  TestNotifier([int initialValue = 0]) : super(initialValue);

  void increment() => state++;

  // ignore: avoid_setters_without_getters
  set value(int value) => state = value;
}
