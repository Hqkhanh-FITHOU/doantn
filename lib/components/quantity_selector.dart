import 'package:doantn/data/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Product food;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({super.key, required this.quantity, required this.food, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(50)
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(
              Icons.remove,
              size: 18,
            ),
          ),

          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8),
              child: SizedBox(
                width: 25,
                child: Center(
                    child: Text('$quantity')),
              )),

          GestureDetector(
            onTap: onIncrement,
            child: const Icon(
              Icons.add,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
