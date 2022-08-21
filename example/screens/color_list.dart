import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_locator.dart';

class ColorList extends ConsumerWidget {
  const ColorList({Key? key}) : super(key: key);

  static final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
  ];

  void onPressed(WidgetRef ref, Color color) {
    ref.read(activeColorProvider.notifier).state = color;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Colors'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _colors.map((color) {
          return Expanded(
            child: ColorItem(
              color: color,
              onPressed: (color) => onPressed(ref, color),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ColorItem extends StatelessWidget {
  final Color color;
  final void Function(Color) onPressed;

  const ColorItem({
    Key? key,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: () => onPressed(color),
        child: const SizedBox(
          height: 45.0,
        ),
      ),
    );
  }
}
