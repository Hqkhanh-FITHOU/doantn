import 'package:doantn/components/my_button.dart';
import 'package:doantn/components/my_current_location.dart';
import 'package:doantn/data/enums/order_status.dart';
import 'package:doantn/data/enums/payment_status.dart';
import 'package:doantn/data/enums/payment_type.dart';
import 'package:doantn/data/models/address.dart';
import 'package:doantn/data/models/coupon.dart';
import 'package:doantn/data/provider/cart_provider.dart';
import 'package:doantn/screens/home_screen.dart';
import 'package:doantn/screens/list_coupon_screen.dart';
import 'package:doantn/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../components/my_circle_progress_indicator.dart';
import '../components/my_rounded_image.dart';
import '../data/api/api_service.dart';
import '../data/models/order.dart';
import '../data/provider/address_provider.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final logger = Logger();
  final ApiService apiService = ApiService();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');
  final TextEditingController noteController = TextEditingController();
  PaymentType _paymentType = PaymentType.CASH_ON_DELIVERY;
  Coupon? _coupon;
  late String paymentMethodText;
  String _couponCodeText = '';
  int couponId = -1;
  double totalDiscount = 0;
  double totalAmount = 0;
  double totalPayment = 0;
  bool isLoading = false;

  void initPaymentMethod(){
    switch(_paymentType){
      case PaymentType.CREDIT_CARD:
        paymentMethodText = 'Thẻ tín dụng';
      case PaymentType.CASH_ON_DELIVERY:
        paymentMethodText = 'Thanh toán khi nhận hàng';
      case PaymentType.VNPAY:
        paymentMethodText = 'VnPay';
    }
  }

  @override
  void initState() {
    super.initState();
    initPaymentMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        body: Consumer<Cart>(
          builder: (context, app, child) {
            app.loadFormDb();
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const MyCurrentLocation(
                    title: 'Địa chỉ nhận hàng',
                    padding:
                        EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
                  ),
                  FutureBuilder(
                    future: app.getData(),
                    builder: (context, snapshot) => Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Card(
                        color: Colors.white,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                            const Padding(
                                padding: EdgeInsets.only(left: 10, top: 10),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.restaurant_menu, color: Colors.amber, size: 18,),
                                      SizedBox(width: 7,),
                                      Text('Món ăn', style: TextStyle(fontSize: 12),)
                                    ])),
                            ListView.builder(
                            shrinkWrap: true, // Cho phép ListView bao bọc chiều cao nội dung
                            primary: false,
                            itemCount: app.cart.length,
                            itemBuilder: (context, index) {
                              final cartItem = app.cart[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 18, right: 18, top: 0, bottom: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        cartItem.food.images.isNotEmpty
                                            ? MyRoundedImage(
                                                height: 50,
                                                width: 60,
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
                                                '${formatter.format(cartItem.food.price)} đ',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                  '${formatter.format(cartItem.quantity * cartItem.food.price)} đ'),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(right: 10),
                                            child: Text('x${cartItem.quantity}')),
                                        index == 0
                                            ? const SizedBox(
                                                height: 0,
                                              )
                                            : const SizedBox(
                                                height: 0,
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.list_alt, color: Colors.amber, size: 18,),
                                const SizedBox(width: 7,),
                                const Text('Lời nhắc',style: TextStyle(fontSize: 12),),
                                const Spacer(),
                                SizedBox(
                                  width: 74,
                                  child: TextFormField(
                                    controller: noteController,
                                    autofocus: false,
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Để lại lời nhắn',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 11,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                final result = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListCouponScreen(),
                                        settings: RouteSettings(
                                          arguments: couponId,
                                        )));
                                if (!context.mounted) return;
                                _coupon = await result as Coupon;
                                setState(() {
                                  if(_coupon != null) {
                                    couponId = _coupon!.couponId;
              
                                    if(app.getTotalPrice() >= _coupon!.minPurchase){
                                      totalDiscount = _coupon!.discountType == 'PERCENTAGE' ? app.getTotalPrice()*_coupon!.discountValue/100 : _coupon!.discountValue;
                                      _couponCodeText = _coupon!.code;
                                    } else {
                                      totalDiscount = 0;
                                      _couponCodeText = '${_coupon!.code} \n không đủ điều kiện áp dụng';
                                    }
                                  }
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.discount_outlined,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  const Text('Khuyến mãi', style: TextStyle(fontSize: 12),),
                                  const Spacer(),
                                  SizedBox(
                                      width: 150,
                                      child: Text(
                                        _couponCodeText,
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.black54),
                                        textAlign: TextAlign.end,
                                      )),
                                  const Icon(
                                    Icons.navigate_next_rounded,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
              
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
              
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentMethodScreen(),
                                      settings: RouteSettings(
                                        arguments: _paymentType,
                                      ),
                                    ),);
                                if (!context.mounted) return;
                                _paymentType = result as PaymentType;
                                setState(() {
                                  initPaymentMethod();
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.monetization_on_outlined,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  const Text('Phương thức thanh toán', style: TextStyle(fontSize: 12),),
                                  const Spacer(),
                                  SizedBox(
                                    width: 80,
                                      child: Text(
                                        paymentMethodText,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                        textAlign: TextAlign.end,
                                  )),
                                  const Icon(
                                    Icons.navigate_next_rounded,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                              
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
              
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.library_books_sharp,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text('Chi tiết thanh toán', style: TextStyle(fontSize: 12),),
                              ],
                            ),
                            const SizedBox(height: 8,),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng tiền hàng', style: TextStyle(color: Colors.black54, fontSize: 12),),
                                Text('${formatter.format(app.getTotalPrice())} đ', style: const TextStyle(fontSize: 12, color: Colors.black54,),),
                              ],
                            ),
                            const SizedBox(height: 4,),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Giảm giá', style: TextStyle(color: Colors.black54, fontSize: 12),),
                                Text('${formatter.format(totalDiscount)} đ', style: const TextStyle(fontSize: 12, color: Colors.black54,),),
                              ],
                            ),
                            const SizedBox(height: 4,),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng thanh toán',),
                                Text('${formatter.format(app.getTotalPrice() - totalDiscount)} đ', style: const TextStyle(color: Colors.orange),),
                              ],
                            ),
                            const SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: true,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min, children: [
                              const Text("Tổng thanh toán", style: TextStyle(fontSize: 12, color: Colors.black54),),
                              Text('${formatter.format(app.getTotalPrice() - totalDiscount)} đ', style: const TextStyle(fontSize: 15, color: Colors.orange, fontWeight: FontWeight.bold),),
                            ],),
                            SizedBox(
                                width: 200,
                                child: Consumer<AddressProvider>(
                                  builder: (context, addresses, child) => MyButton(
                                    onTap: () async {
                                      try {
                                        setState(() {
                                          isLoading = true;
                                          logger.d('start checkout');
                                        });
                                        Address address = addresses.getCheckedAddress();
                                        if(address.address == ''){
                                          isLoading = false;
                                          Fluttertoast.showToast(
                                              msg: 'Chưa chọn thông tin nhận hàng', toastLength: Toast.LENGTH_SHORT);
                                          return;
                                        }
                                        final uid = await apiService.getUserId();
                                        logger.w('uid: $uid');
                                        Order order = Order(
                                            0, //order id
                                            uid, //uid
                                            null, // delivery
                                            app.getTotalPrice(), //totalAmount
                                            totalDiscount, //totalDiscount
                                            app.getTotalPrice() - totalDiscount,//totalPayment
                                            noteController.text, //note
                                            OrderStatus.PENDING, //order status
                                            address.toString(), //receiver address
                                            _paymentType, //payment method
                                            PaymentStatus.PENDING, //payment status: paid or not
                                            null,
                                            null
                                        );
              
                                        final orderId = await apiService.makeOrder(order);
                                        logger.w('orderId: $orderId');
                                        for (var item in app.cart) {
                                           apiService.addOrderItems(
                                              orderId,
                                              item.food.productId,
                                              item.quantity,
                                              item.food.price);
                                        }
                                        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
                                          'channel_id', // Unique channel ID
                                          'channel_name', // Channel name visible to users
                                          importance: Importance.high,
                                          priority: Priority.high,
                                          showWhen: true,
                                        );

                                        const NotificationDetails notificationDetails =
                                        NotificationDetails(android: androidDetails);
                                        setState(() {
                                          isLoading = false;
                                          logger.d('checkout ok!');
                                          app.clearCart();
                                          flutterLocalNotificationsPlugin.show(
                                            0, // Notification ID
                                            'Đặt hàng', // Notification title
                                            'Đơn đặt hàng của bạn đã được tạo', // Notification body
                                            notificationDetails,
                                          );
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                                (route) => false, // Xóa tất cả các route
                                          );
                                        });
                                      }catch (e) {
                                        logger.e('checkout error $e');
                                        setState(() {
                                          isLoading = false;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              content: Text('Đã có lỗi xảy ra!',
                                                  style:
                                                  TextStyle(color: Colors.white)),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        });
                                      }
                                    },
                                    child: !isLoading ? const Text(
                                      "Xác nhận",
                                      style: TextStyle(color: Colors.white),
                                    ) : const MyCircleProgressIndicator(
                                      wight: 23,
                                      height: 23,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
            );
          },
        ),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          const SliverAppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text("Xác nhận đơn hàng"),
          )
        ],
      ),
    );
  }
}
