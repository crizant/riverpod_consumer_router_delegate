# riverpod_consumer_router_delegate

## Features

This package enables you to use the [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) package with the [flutter navigator 2.0 API](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

Inside your custom router delegate class, you may use `ref.watch()`, `ref.read()`, `ref.listen()` and `ref.refresh()` methods just like in widgets.

## Usage

1. Extend your RouterDelegate with `ConsumerRouterDelegate`:

```dart
class MyRouterDelegate extends ConsumerRouterDelegate<MyRouteConfig>
    with PopNavigatorRouterDelegateMixin<MyRouteConfig>, ChangeNotifier {
  // make sure you pass the `ref` to the `super` constructor
  MyRouterDelegate(Ref ref) : super(ref);
  // ...
}
```

2. Implement the `onDependenciesUpdate()` method, since my router delegate is a `ChangeNotifier`, so the `notifyListeners()` method is available:

```dart
@override
void onDependenciesUpdate() {
  notifyListeners();
}
```

3. Inside your custom router delegate class, do not override the `build` method, write a `builder` method instead:

```dart
Widget builder(BuildContext context) {
  // ..
}
```

You can use `ref.*` methods inside your delegate. Note that the `ref` is not the same one you passed to the `super` constructor.

4. Add a `ChangeNotifierProvider` for your delegate:

```dart
final routerDelegateProvider =
    ChangeNotifierProvider((ref) => MyRouterDelegate(ref));
```

5. Wrap a `ProviderScope` around your `MaterialApp` widget, pass the instance of your router delegate to the `MaterialApp.router` constructor:

```dart
void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerDelegate: ref.watch(routerDelegateProvider),
      // ...
    );
  }
}

```

For the full example, please check the `/example` folder.

## Motivation

The declarative approach of the [flutter navigator 2.0 API](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) is cool, but it doesn't work with `riverpod` directly.

As discussed in [this issue](https://github.com/rrousselGit/riverpod/issues/946), there are some problems when using `riverpod`'s methods (e.g. `ref.watch()`) inside the `build` method of the router delegate directly.

The community suggests adding listeners of all the dependent providers in the constructor of the router delegate. In my opinion, it's a bad idea since it's ugly and error-prone.

Therefore I created this package. Just extend your router delegate with my class, supply the `ref` to the super constructor, and write a `builder` method instead of the `build` method. It does the magic behind the scene, so that you may use the `ref.*` methods just like you did in the widgets, without any worries.

## Additional Information

Issues and pull requests are welcome.
