import 'package:flutter/material.dart';

class MyCircleProgressIndicator extends StatelessWidget {
  final double? wight;
  final double? height;
  final Color? color;

  const MyCircleProgressIndicator({super.key, this.wight, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: wight,
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }
}
