import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/router_delegate.dart';

final activeColorProvider = StateProvider<Color?>((ref) => null);

final routerDelegateProvider =
    ChangeNotifierProvider((ref) => ColorRouterDelegate(ref));
