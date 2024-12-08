import 'package:flutter/material.dart';

class MyButton extends StatelessWidget{
  final Function()? onTap;
  final Widget? child;

  const MyButton({super.key,required this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
          child: child
        ),
      ),
    );
  }
}


class MyButton2 extends StatelessWidget{
  final Function()? onTap;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;

  const MyButton2({super.key,required this.onTap, this.child, this.padding, this.margin, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
            child: child
        ),
      ),
    );
  }
}