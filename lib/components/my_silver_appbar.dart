import 'package:doantn/screens/cart_screen.dart';
import 'package:flutter/material.dart';

class MySliverAppbar extends StatelessWidget {
  final Widget child;
  final Widget title;
  final Widget? cartBadge;

  const MySliverAppbar({super.key, required this.child, required this.title, this.cartBadge});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      expandedHeight: 200,
      collapsedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.amberAccent,
      shadowColor: Colors.amberAccent,
      title: const Text("Cơm tấm Tư Mập"),
      flexibleSpace: FlexibleSpaceBar(
        title: title,
        background: Padding(
          padding: const EdgeInsets.only(bottom: 35.0),
          child: child,
        ),
        centerTitle: true,
        expandedTitleScale: 1,
        titlePadding:
            const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen(),));
              },
              icon: const Icon(Icons.shopping_cart),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: cartBadge,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
