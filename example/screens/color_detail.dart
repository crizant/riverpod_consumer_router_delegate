import 'package:flutter/material.dart';

class ColorDetail extends StatelessWidget {
  final Color color;

  const ColorDetail({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(color.toString()),
      ),
      body: Container(
        color: color,
      ),
    );
  }
}
