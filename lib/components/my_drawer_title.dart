import 'package:flutter/material.dart';

class MyDrawerTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Function()? onTap;
  
  const MyDrawerTitle({super.key, required this.text,required this.icon,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 25),
      child: ListTile(
        title: Text(
          text.toUpperCase(),
          style: const TextStyle(color: Colors.black54),
        ),
        leading: Icon(icon, color: Colors.black54,),
        onTap: onTap,
      ),
    );
  }
}
