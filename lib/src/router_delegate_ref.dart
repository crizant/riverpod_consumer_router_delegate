import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouterDelegateRef implements WidgetRef {
  final ProviderContainer _container;
  final VoidCallback _onDependenciesUpdate;
  Map<ProviderListenable, ProviderSubscription> _dependencies = {};
  Map<ProviderListenable, ProviderSubscription>? _oldDependencies;
  final List<ProviderSubscription> _listeners = [];
  bool _debugDoingBuild = false;
  bool get debugDoingBuild => _debugDoingBuild;

  RouterDelegateRef({
    required ProviderContainer providerContainer,
    required VoidCallback onDependenciesUpdate,
  })  : _container = providerContainer,
        _onDependenciesUpdate = onDependenciesUpdate;

  @override
  T watch<T>(ProviderListenable<T> target) {
    return _dependencies.putIfAbsent(target, () {
      final oldDependency = _oldDependencies?.remove(target);
      if (oldDependency != null) {
        return oldDependency;
      }
      return _container.listen<T>(
        target,
        (_, __) => _onDependenciesUpdate(),
      );
    }).read() as T;
  }

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    assert(
      debugDoingBuild,
      '`ref.listen` can only be used within the `builder` method of '
      'a ConsumerRouterDelegate',
    );
    final sub = _container.listen<T>(provider, listener, onError: onError);
    _listeners.add(sub);
  }

  @override
  T read<T>(ProviderBase<T> provider) {
    return _container.read(provider);
  }

  @override
  T refresh<T>(ProviderBase<T> provider) {
    return _container.refresh(provider);
  }

  void dispose() {
    for (final dependency in _dependencies.values) {
      dependency.close();
    }
    for (var i = 0; i < _listeners.length; i++) {
      _listeners[i].close();
    }
  }

  Widget build(Widget Function() builder) {
    try {
      assert(
        () {
          _debugDoingBuild = true;
          return true;
        }(),
      );
      _oldDependencies = _dependencies;
      for (var i = 0; i < _listeners.length; i++) {
        _listeners[i].close();
      }
      _listeners.clear();
      _dependencies = {};
      return builder();
    } finally {
      for (final dep in _oldDependencies!.values) {
        dep.close();
      }
      _oldDependencies = null;
      assert(
        () {
          _debugDoingBuild = false;
          return true;
        }(),
      );
    }
  }
}
