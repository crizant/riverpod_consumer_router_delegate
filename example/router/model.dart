import 'package:flutter/material.dart';

enum ColorRoute {
  home,
  detail,
  unknown,
}

class ColorRouteConfig {
  final ColorRoute route;
  final Color? color;
  final bool isUnknown;

  ColorRouteConfig.home()
      : route = ColorRoute.home,
        color = null,
        isUnknown = false;

  ColorRouteConfig.detail(this.color)
      : route = ColorRoute.detail,
        isUnknown = false;

  ColorRouteConfig.unknown()
      : route = ColorRoute.unknown,
        color = null,
        isUnknown = true;
}
