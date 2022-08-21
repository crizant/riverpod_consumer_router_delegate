import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_consumer_router_delegate/consumer_router_delegate.dart';
import 'utils.dart';

void main() {
  late final ProviderContainer container;
  setUpAll(() {
    container = ProviderContainer();
  });

  testWidgets('throws if listen is used outside of `build`', (tester) async {
    final provider = Provider((_) => 0);

    final RouterDelegateRef ref = RouterDelegateRef(
      providerContainer: container,
      onDependenciesUpdate: () {},
    );

    expect(() => ref.listen(provider, (_, __) {}), throwsAssertionError);
  });

  testWidgets('can use "watch" inside `build`', (tester) async {
    final provider = Provider((ref) => 'hello world');

    final RouterDelegateRef ref = RouterDelegateRef(
      providerContainer: container,
      onDependenciesUpdate: () {},
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ref.build(() {
          final text = ref.watch(provider);
          return Text(text);
        }),
      ),
    );

    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('Stop listening to unused provider', (tester) async {
    final changeNotifier = ChangeNotifier();
    final stateProvider = StateProvider((ref) => 0, name: 'state');
    final notifier0 = TestNotifier();
    final notifier1 = TestNotifier(42);
    final provider0 = StateNotifierProvider<TestNotifier, int>((_) {
      return notifier0;
    }, name: '0');
    final provider1 = StateNotifierProvider<TestNotifier, int>((_) {
      return notifier1;
    }, name: '1');
    var buildCount = 0;
    final RouterDelegateRef ref = RouterDelegateRef(
      providerContainer: container,
      onDependenciesUpdate: () {
        changeNotifier.notifyListeners();
      },
    );

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: changeNotifier,
        builder: (BuildContext context, _) {
          return ref.build(() {
            buildCount++;
            final state = ref.watch(stateProvider.state).state;
            final value =
                state == 0 ? ref.watch(provider0) : ref.watch(provider1);

            return Text(
              '$value',
              textDirection: TextDirection.ltr,
            );
          });
        },
      ),
    );

    container.read(provider0);
    container.read(provider1);
    final familyState0 = container.getAllProviderElements().firstWhere((p) {
      return p.provider == provider0;
    });
    final familyState1 = container.getAllProviderElements().firstWhere((p) {
      return p.provider == provider1;
    });

    expect(buildCount, 1);
    expect(familyState0.hasListeners, true);
    expect(familyState1.hasListeners, false);
    expect(find.text('0'), findsOneWidget);

    notifier0.increment();
    await tester.pump();

    expect(buildCount, 2);
    expect(find.text('1'), findsOneWidget);

    notifier1.increment();
    await tester.pump();

    expect(buildCount, 2);

    // changing the provider that computed is subscribed to
    container.read(stateProvider.state).state = 1;
    await tester.pump();

    expect(buildCount, 3);
    expect(find.text('43'), findsOneWidget);
    expect(familyState1.hasListeners, true);
    expect(familyState0.hasListeners, false);

    notifier1.increment();
    await tester.pump();

    expect(buildCount, 4);
    expect(find.text('44'), findsOneWidget);

    notifier0.increment();
    await tester.pump();

    expect(buildCount, 4);
    expect(find.text('44'), findsOneWidget);
  });

  testWidgets(
      'Consumer removing one of multiple listeners on a provider still listen to the provider',
      (tester) async {
    final changeNotifier = ChangeNotifier();
    final stateProvider = StateProvider((ref) => 0, name: 'state');
    final notifier0 = TestNotifier();
    final notifier1 = TestNotifier(42);
    final provider0 = StateNotifierProvider<TestNotifier, int>((_) {
      return notifier0;
    }, name: '0');
    final provider1 = StateNotifierProvider<TestNotifier, int>((_) {
      return notifier1;
    }, name: '1');
    var buildCount = 0;
    final RouterDelegateRef ref = RouterDelegateRef(
      providerContainer: container,
      onDependenciesUpdate: () {
        changeNotifier.notifyListeners();
      },
    );

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: changeNotifier,
        builder: (BuildContext context, _) {
          return ref.build(() {
            buildCount++;
            final state = ref.watch(stateProvider.state).state;
            final value =
                state == 0 ? ref.watch(provider0) : ref.watch(provider1);

            return Text(
              '${ref.watch(provider0)} $value',
              textDirection: TextDirection.ltr,
            );
          });
        },
      ),
    );

    container.read(provider0);
    container.read(provider1);
    final familyState0 = container.getAllProviderElements().firstWhere((p) {
      return p.provider == provider0;
    });
    final familyState1 = container.getAllProviderElements().firstWhere((p) {
      return p.provider == provider1;
    });

    expect(buildCount, 1);
    expect(familyState0.hasListeners, true);
    expect(familyState1.hasListeners, false);
    expect(find.text('0 0'), findsOneWidget);

    notifier0.increment();
    await tester.pump();

    expect(buildCount, 2);
    expect(find.text('1 1'), findsOneWidget);

    notifier1.increment();
    await tester.pump();

    expect(buildCount, 2);

    // changing the provider that computed is subscribed to
    container.read(stateProvider.state).state = 1;
    await tester.pump();

    expect(buildCount, 3);
    expect(find.text('1 43'), findsOneWidget);
    expect(familyState1.hasListeners, true);
    expect(familyState0.hasListeners, true);

    notifier1.increment();
    await tester.pump();

    expect(buildCount, 4);
    expect(find.text('1 44'), findsOneWidget);

    notifier0.increment();
    await tester.pump();

    expect(buildCount, 5);
    expect(find.text('2 44'), findsOneWidget);
  });

  tearDownAll(() {
    container.dispose();
  });
}
