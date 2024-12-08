import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transparent_image/transparent_image.dart';
import '../components/my_circle_progress_indicator.dart';
import '../data/api/api_service.dart';
import '../data/helper/cart_db_helper.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class FoodDetailScreen extends StatefulWidget {
  final int id;
  const FoodDetailScreen({super.key, required this.id});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final ApiService apiService = ApiService();
  final logger = Logger();
  final CartDatabaseHelper? dbHelper = CartDatabaseHelper();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');
  Stream<Product>? productStream;
  late int id;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    productStream = _streamData().asBroadcastStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  Stream<Product> _streamData() async* {
    while (true) {
      yield await apiService.getProduct(id);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chi tiết món ăn'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<Product?>(
          stream: productStream,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const SafeArea(
                child: Center(
                    child: MyCircleProgressIndicator(
                      color: Colors.orange,
                    )),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: snapshot.data?.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return FadeInImage.memoryNetwork(
                          image: '${ApiService.baseUrl}uploads/product/${snapshot.data!.images[index].pathString}',
                          placeholder: kTransparentImage,
                          fit: BoxFit.cover,
                        );
                      },),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        Text(snapshot.data!.isServing ? 'Đang phục vụ':'Tạm ngừng phục vụ', style: TextStyle(fontSize: 14, color: snapshot.data!.isServing ? Colors.green: Colors.redAccent),),
                        Text(
                          snapshot.data!.category.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      snapshot.data!.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${formatter.format(snapshot.data?.price)}đ',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () async {
                            if ( await dbHelper!.isProductInCart (snapshot.data!.productId)) {
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
                                  'add to cart: productId: ${snapshot.data?.productId}');
                              var cartItem = CartItem(food: snapshot.data!);
                              dbHelper!.addItemToCart(cartItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.lightGreen,
                                  content: Text('Đã thêm món ăn vào giỏ',
                                      style: TextStyle(color: Colors.white)),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          color: Colors.orange,
                        )
                      ],
                    ),
                  ),
                  const Divider(indent: 13, endIndent: 15,),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text(
                      'Đánh giá ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 13,),
                        Image(
                          image: AssetImage('assets/images/rating_food.png'),
                          width: 90,
                          height: 90,
                        ),
                        SizedBox(height: 13,),
                        Text('Chưa có đánh giá nào')
                    ],),)
                ],
              );
            }
          },
        )
      ),
    );
  }
}
