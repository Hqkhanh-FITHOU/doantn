import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTabBar2 extends StatelessWidget {
  final TabController tabController;

  const MyTabBar2({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
        labelColor: Colors.orange,
        indicatorColor: Colors.orange,
        controller: tabController,
        tabs: const [
          Tab(
            text: 'Đơn cần giao',
            icon: Icon(
              Icons.paste_rounded,
              color: Colors.orange,
              semanticLabel: "Đơn chờ giao",
            ),
          ),
          Tab(
            text: 'Đang giao',
            icon: Icon(
              Icons.delivery_dining_rounded,
              color: Colors.orange,
            ),
          )
        ]);
  }
}
