import 'package:flutter/material.dart';
import 'model.dart';

class ColorRouteInformationParser
    extends RouteInformationParser<ColorRouteConfig> {
  @override
  Future<ColorRouteConfig> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return ColorRouteConfig.home();
    }

    // Handle '/veggie/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'color') {
        final String remaining = uri.pathSegments[1];
        int? value = int.tryParse(remaining, radix: 16);
        if (value != null) {
          return ColorRouteConfig.detail(
            Color(value),
          );
        }
      }
      return ColorRouteConfig.unknown();
    }

    // Handle unknown routes
    return ColorRouteConfig.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(ColorRouteConfig configuration) {
    if (configuration.route == ColorRoute.unknown) {
      return const RouteInformation(location: '/404');
    }
    if (configuration.route == ColorRoute.home) {
      return const RouteInformation(location: '/');
    }
    if (configuration.route == ColorRoute.detail) {
      return RouteInformation(
        location: '/color/${configuration.color!.value.toRadixString(16)}',
      );
    }
    return null;
  }
}
