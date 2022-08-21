library riverpod_consumer_router_delegate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/router_delegate_ref.dart';

abstract class ConsumerRouterDelegate<T> extends RouterDelegate<T> {
  late final RouterDelegateRef _ref;
  ConsumerRouterDelegate(Ref ref) {
    _ref = RouterDelegateRef(
      providerContainer: ref.container,
      onDependenciesUpdate: onDependenciesUpdate,
    );
    ref.onDispose(_ref.dispose);
  }

  WidgetRef get ref => _ref;

  void onDependenciesUpdate();

  /// Override this method instead of original `build` method
  Widget builder(BuildContext context);

  /// DO NOT override this method!!!
  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return _ref.build(() => builder(context));
  }
}
