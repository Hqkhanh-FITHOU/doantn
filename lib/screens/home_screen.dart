
import 'package:doantn/components/my_circle_progress_indicator.dart';
import 'package:doantn/components/my_current_location.dart';
import 'package:doantn/components/my_drawer.dart';
import 'package:doantn/components/my_rounded_image.dart';
import 'package:doantn/components/my_silver_appbar.dart';
import 'package:doantn/components/my_tab_bar.dart';
import 'package:doantn/data/helper/cart_db_helper.dart';
import 'package:doantn/data/provider/cart_provider.dart';
import 'package:doantn/data/models/cart_item.dart';
import 'package:doantn/screens/food_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../data/api/api_service.dart';
import '../data/models/coupon.dart';
import '../data/models/product.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ApiService apiService = ApiService();
  final logger = Logger();
  Stream<List<Product>>? productsStream;
  Stream<List<Coupon>>? couponsStream;
  final CartDatabaseHelper? dbHelper = CartDatabaseHelper();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    couponsStream ??= _getCoupons().asBroadcastStream();
    productsStream ??= _getProducts().asBroadcastStream();

  }

  Stream<List<Product>> _getProducts() async* {
    while (true) {
      yield await apiService.fetchDataProducts();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<List<Coupon>> _getCoupons() async* {
    while (true) {
      yield await apiService.fetchDataActiveCoupons();
      await Future.delayed(const Duration(seconds: 1));
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(
        onLogout: () => Navigator.pop(context),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                MySliverAppbar(
                    cartBadge: Consumer<Cart>(
                      builder: (context, cart, child) {
                        cart.calculateTotalQuantity();
                        int totalQuantity = cart.totalQuantity;
                        return Text(
                          '$totalQuantity',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 8),
                        );
                      },
                    ),
                    title: MyTabBar(
                      tabController: _tabController,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //current location
                        MyCurrentLocation(
                          title: 'Giao hàng ngay',
                          padding: EdgeInsets.only(left: 25, right: 25, bottom: 35, top: 0),
                        )
                      ],
                    ))
              ],
          body: TabBarView(controller: _tabController, children: [
            StreamBuilder<List<Product>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(
                    child: Center(
                        child: MyCircleProgressIndicator(
                          color: Colors.orange,
                        )),
                  );
                } if (snapshot.hasError) {
                  return const SafeArea(
                    child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: AssetImage(
                                    'assets/images/no_internet.png'),
                                width: 130,
                                height: 130,
                              ),
                              SizedBox(height: 12,),
                              Text("Đã có lỗi xảy ra!", style: TextStyle(
                                  fontWeight: FontWeight.bold),),
                              Text("Kiểm tra lại kết nối mạng")
                            ])),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(
                      child: Center(child: Text("Không có món ăn nào")));
                } else {
                  List<Product> products = snapshot.data!;
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            trailing: IconButton(
                                color: Colors.orange,
                                onPressed: () async {
                                  if(product.isServing){
                                    if (await dbHelper!
                                        .isProductInCart(product.productId)) {
                                      logger.w('product already in cart');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            'Món ăn đã có sẵn trong giỏ',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
                                      logger.w(
                                          'add to cart: productId: ${product.productId}');
                                      var cartItem = CartItem(food: product);
                                      dbHelper!.addItemToCart(cartItem);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.lightGreen,
                                          content: Text('Đã thêm món ăn vào giỏ',
                                              style:
                                              TextStyle(color: Colors.white)),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.redAccent,
                                        content: Text(
                                          'Món ăn đã tạm dừng phục vụ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                    Icons.add_shopping_cart_rounded)),
                            leading: product.images.isNotEmpty
                                ? MyRoundedImage(
                                width: 70,
                                height: 60,
                                imageUrl:
                                '${ApiService.baseUrl}uploads/product/${product.images[0].pathString}')
                                : const Row(
                              mainAxisSize: MainAxisSize.min,
                            ),
                            title: Text(product.name, style: const TextStyle(fontSize: 14),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(product.category.name, style: const TextStyle(fontSize: 10),),
                                Text(product.isServing ? 'Đang phục vụ':'Tạm ngừng phục vụ', style: TextStyle(fontSize: 10, color: product.isServing ? Colors.green: Colors.redAccent),),
                                Text('${formatter.format(product.price)}đ', style: const TextStyle(fontSize: 10),)
                            ],),
                            onTap: () {
                              // Xử lý khi nhấn vào sản phẩm, ví dụ như mở màn hình chi tiết sản phẩm
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      FoodDetailScreen(id: product.productId,),
                                      settings: RouteSettings(
                                          arguments: product.productId)));
                            },
                          );
                        }),
                  );
                }
              }
            ),
            StreamBuilder<List<Coupon>>(
              stream: couponsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(
                    child: Center(
                        child: MyCircleProgressIndicator(
                          color: Colors.orange,
                        )),
                  );
                } else if (snapshot.hasError) {
                  return const SafeArea(
                    child: Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min, children: [
                          Image(
                            image: AssetImage('assets/images/no_internet.png'),
                            width: 130,
                            height: 130,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            "Đã có lỗi xảy ra!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Kiểm tra lại kết nối mạng")
                        ]
                        )
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(
                      child: Center(child: Text("Không có khuyến mãi nào")));
                } else {
                  List<Coupon> coupons = snapshot.data!;
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          final coupon = coupons[index];
                          return ListTile(
                            leading: coupon.discountType == 'PERCENTAGE'
                                ? const Image(
                              image: AssetImage(
                                  'assets/images/discount_percent.png'),
                              height: 60,
                            )
                                : const Image(
                              image: AssetImage(
                                  'assets/images/discount_percent.png'),
                              height: 60,
                            ),
                            title: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold),),
                            subtitle: coupon.discountType == 'PERCENTAGE'
                                ? Text(
                                'Giảm ${formatter.format(coupon.discountValue)}% với đơn giá trị tối thiểu ${formatter.format(coupon.minPurchase)}đ')
                                : Text(
                                'Giảm ${formatter.format(coupon.discountValue)}đ với đơn giá trị tối thiểu ${formatter.format(coupon.minPurchase)}đ'),
                            onTap: () {
                              // Xử lý khi nhấn vào sản phẩm, ví dụ như mở màn hình chi tiết khuyen mãi

                            },
                          );
                        }),
                  );
                }
            },)
          ])),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

