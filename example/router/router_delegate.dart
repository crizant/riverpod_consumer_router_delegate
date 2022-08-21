import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_consumer_router_delegate/consumer_router_delegate.dart';
import '../screens/color_detail.dart';
import '../screens/color_list.dart';
import '../service_locator.dart';
import 'model.dart';

class ColorRouterDelegate extends ConsumerRouterDelegate<ColorRouteConfig>
    with PopNavigatorRouterDelegateMixin<ColorRouteConfig>, ChangeNotifier {
  static ColorRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is ColorRouterDelegate, 'Delegate type must match');
    return delegate as ColorRouterDelegate;
  }

  ColorRouterDelegate(Ref ref) : super(ref);

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  ColorRouteConfig get currentConfiguration {
    final activeColor = ref.read(activeColorProvider);
    if (activeColor != null) {
      return ColorRouteConfig.detail(activeColor);
    }
    return ColorRouteConfig.home();
  }

  @override
  Future<void> setInitialRoutePath(ColorRouteConfig configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(ColorRouteConfig configuration) {
    if (configuration.route == ColorRoute.detail) {
      ref.read(activeColorProvider.notifier).state = configuration.color;
    }
    return SynchronousFuture(null);
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (route.settings.name == ColorRoute.detail.name) {
      ref.read(activeColorProvider.notifier).state = null;
    }
    return route.didPop(result);
  }

  @override
  void onDependenciesUpdate() {
    notifyListeners();
  }

  @override
  Widget builder(BuildContext context) {
    final activeColor = ref.watch(activeColorProvider);
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: [
        MaterialPage(
          name: ColorRoute.home.name,
          child: const ColorList(),
        ),
        if (activeColor != null)
          MaterialPage(
            name: ColorRoute.detail.name,
            child: ColorDetail(color: activeColor),
          ),
      ],
    );
  }
}
