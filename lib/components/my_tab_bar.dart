import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  final TabController tabController;

  const MyTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
        labelColor: Colors.orange,
        indicatorColor: Colors.orange,
        controller: tabController,
        tabs: const [
          Tab(
            text: 'Thực đơn',
            icon: Icon(
              Icons.restaurant_menu,
              color: Colors.orange,
              semanticLabel: "",
            ),
          ),
          Tab(
            text: 'Khuyến mãi',
            icon: Icon(
              Icons.percent,
              color: Colors.orange,
            ),
          )
        ]);
  }
}
