

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.pink],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft
          )
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Splash Screen',
                style: TextStyle(color: Colors.white, fontSize: 35),
            )
          ],
        ),
      ),
    );
  }

}