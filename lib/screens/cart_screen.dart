import 'package:doantn/components/my_button.dart';
import 'package:doantn/components/my_rounded_image.dart';
import 'package:doantn/components/quantity_selector.dart';
import 'package:doantn/data/provider/cart_provider.dart';
import 'package:doantn/screens/check_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../data/api/api_service.dart';
import '../data/helper/cart_db_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService apiService = ApiService();
  final CartDatabaseHelper dbHelper = CartDatabaseHelper();
  bool isEmpty = false;
  final logger = Logger();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, app, child) {
        app.loadFormDb();
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    app.clearCart();
                  },
                  icon: const Icon(Icons.delete))
            ],
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text("Giỏ hàng"),
          ),
          body: Column(children: [
            FutureBuilder(
                future: app.getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Expanded(
                      child: Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                  Image(
                                    image: AssetImage('assets/images/no_internet.png'),
                                    width: 130,
                                    height: 130,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text("Đã có lỗi xảy ra!"),
                                  Text("Kiểm tra lại kết nối mạng.")
                      ])),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Expanded(
                      child: Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                  Image(
                                    image: AssetImage('assets/images/empty_cart.png'),
                                    width: 130,
                                    height: 130,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "Trống trơn!",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("Chưa có gì trong giỏ hàng")
                      ])),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: app.cart.length,
                        itemBuilder: (context, index) {
                          final cartItem = app.cart[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 18, right: 18, top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                index > 0
                                    ? const Divider(
                                        indent: 10,
                                        endIndent: 10,
                                        color: Colors.black26,
                                      )
                                    : const Column(
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    cartItem.food.images.isNotEmpty
                                        ? MyRoundedImage(
                                            width: 60,
                                            height: 50,
                                            imageUrl:
                                                '${ApiService.baseUrl}uploads/product/${cartItem.food.images[0].pathString}')
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                          ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cartItem.food.name),
                                          Text(
                                              '${formatter.format(cartItem.food.price)}đ',
                                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                          Text(
                                              '${formatter.format(cartItem.quantity * cartItem.food.price)}đ'),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    QuantitySelector(
                                        quantity: cartItem.quantity,
                                        food: cartItem.food,
                                        onIncrement: () {
                                          app.updateQuantity(
                                              cartItem.food.productId,
                                              cartItem.quantity + 1);
                                          logger.d('onIncrement');
                                        },
                                        onDecrement: () {
                                          if(cartItem.quantity <= 1){
                                            app.deleteCartItem(cartItem.food.productId);
                                          } else {
                                            app.updateQuantity(
                                                cartItem.food.productId,
                                                cartItem.quantity - 1);
                                          }
                                          logger.d('onDecrement');
                                        })
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Text(
                              '${formatter.format(app.getTotalPrice())} đ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MyButton(
                        child: const Text(
                          "Đặt hàng",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          if (app.getTotalPrice() > 0.0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckOutScreen(),
                                ));
                          }
                        }),
                  ),
                ],
              ),
            )
          ]),
        );
      },
    );
  }
}
