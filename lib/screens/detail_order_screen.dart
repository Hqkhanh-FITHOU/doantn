import 'package:doantn/components/my_button.dart';
import 'package:doantn/data/enums/order_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../components/my_circle_progress_indicator.dart';
import '../components/my_rounded_image.dart';
import '../data/api/api_service.dart';
import '../data/models/order.dart';
import '../data/models/order_item2.dart';
import '../data/models/payment.dart';
import '../data/models/user.dart';

class DetailOrderScreen extends StatefulWidget {
  const DetailOrderScreen({super.key});

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  final ApiService apiService = ApiService();
  final logger = Logger();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');
  bool init = false;
  bool loading = false;
  late int orderId;
  late Future<User>? future1;
  late Future<List<OrderItem2>>? future2;
  late Future<Order>? future3;
  late Future<Payment>? future4;
  final TextEditingController cancelReasonController = TextEditingController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger.i('initialed = $init');
    if(init){
      logger.i('futures are initialed');
      return;
    }
    orderId = ModalRoute.of(context)!.settings.arguments as int;
    future1 = apiService.getUserByOrderId(orderId);
    future2 = apiService.fectOrderItemsWithOrderId(orderId);
    future3 = apiService.getOrderById(orderId);
    future4 = apiService.getPaymentByOrderId(orderId);
    init = true;
  }

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Đơn hàng'), backgroundColor: Colors.white, centerTitle: true,),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.numbers,
                              color: Colors.amber,
                              size: 18,
                            ),
                            Text(
                              '$orderId',
                              style: const TextStyle(fontSize: 13, color: Colors.amber),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),),
            Card(
              color: Colors.amberAccent,
              child: Column(
                children: [
                  FutureBuilder(
                    future: future1,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const SafeArea(
                          child: Center(
                              child: MyCircleProgressIndicator(
                                color: Colors.orange,
                              )),
                        );
                      } else {
                        User? user = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text('Người đặt', style: TextStyle(fontSize: 12),),
                              ],
                            ),
                            const SizedBox(height: 8,),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${user?.fullname}', style: const TextStyle(color: Colors.black, fontSize: 12),),
                                Text('${user?.phone}', style: const TextStyle(fontSize: 12, color: Colors.black,),),
                              ],
                            ),
                          ],),
                        );
                      }

                    },
                  )
                ],
              ),),
            Card(
              color: Colors.white,
              child: FutureBuilder(
                future: future2,
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
                          child: Column(mainAxisSize: MainAxisSize.min,children: [
                            Image(
                              image: AssetImage('assets/images/no_internet.png'),
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 12,),
                            Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("Kiểm tra lại kết nối mạng")
                          ])),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                  } else {
                    logger.i('coming has data');
                    List<OrderItem2> orderItems = snapshot.data!;
                    return SizedBox(
                      height: orderItems.length * 65,
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            final orderItem = orderItems[index];
                            return ListTile(
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    MyRoundedImage(
                                      imageUrl:
                                      '${ApiService.baseUrl}uploads/product/${orderItem.product.images[0].pathString}',
                                      height: 40,
                                      width: 50,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 7),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(orderItem.product.name),
                                          Text('${formatter.format(orderItem.priceAtOrderTime)}đ'),
                                        ],),
                                    ),
                                    Expanded(child: Text('x${orderItem.quantity}', textAlign: TextAlign.end,))
                                  ],),
                                ],
                              ),
                            );
                          }),
                    );
                  }
                },),
            ),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  FutureBuilder(
                    future: future3,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const SafeArea(
                          child: Center(
                              child: MyCircleProgressIndicator(
                                color: Colors.orange,
                              )),
                        );
                      } else {
                        Order? order = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text('Ghi chú', style: TextStyle(fontSize: 12),),
                              ],
                            ),
                            const SizedBox(height: 8,),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(order!.note == null ? 'Không có ghi chú' : '${order.note}', style: const TextStyle(color: Colors.black, fontSize: 12),),
                              ],
                            ),
                          ],),
                        );
                      }

                    },
                  )
                ],
              ),),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: FutureBuilder(
                  future: future3,
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
                            child: Column(mainAxisSize: MainAxisSize.min,children: [
                              Image(
                                image: AssetImage('assets/images/no_internet.png'),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 12,),
                              Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("Kiểm tra lại kết nối mạng")
                            ])),
                      );
                    } else if (!snapshot.hasData) {
                      return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                    } else {
                      Order? order = snapshot.data;
                      return Column(children: [
                        const Row(
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
                            Text('${formatter.format(order!.totalAmount)} đ', style: const TextStyle(fontSize: 12, color: Colors.black54,),),
                          ],
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giảm giá', style: TextStyle(color: Colors.black54, fontSize: 12),),
                            Text('${formatter.format(order.totalDiscount)} đ', style: const TextStyle(fontSize: 12, color: Colors.black54,),),
                          ],
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán',),
                            Text('${formatter.format(order.totalPayment)} đ', style: const TextStyle(color: Colors.orange),),
                          ],
                        ),
                        const SizedBox(height: 10,),
                      ],);
                    }
                  },
                ),
              ),
            ),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: FutureBuilder(
                  future: future3,
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
                            child: Column(mainAxisSize: MainAxisSize.min,children: [
                              Image(
                                image: AssetImage('assets/images/no_internet.png'),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 12,),
                              Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("Kiểm tra lại kết nối mạng")
                            ])),
                      );
                    } else if (!snapshot.hasData) {
                      return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                    } else {
                      Order? order = snapshot.data;
                      return Column(children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text('Thông tin nhận hàng', style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        const SizedBox(height: 8,),
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            order!.receiverAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(height: 8,),
                      ],);
                    }
                  },
                ),
              ),
            ),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: FutureBuilder(
                  future: future4,
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
                            child: Column(mainAxisSize: MainAxisSize.min,children: [
                              Image(
                                image: AssetImage('assets/images/no_internet.png'),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 12,),
                              Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("Kiểm tra lại kết nối mạng")
                            ])),
                      );
                    } else if (!snapshot.hasData) {
                      return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                    } else {
                      Payment? payment = snapshot.data;
                      return Column(children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text('Tình trạng thanh toán', style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    payment!.paymentMethod ==
                                        'CASH_ON_DELIVERY'
                                        ? 'Thanh toán khi nhận hàng'
                                        : 'Thanh toán VnPay',
                                    style: const TextStyle(fontSize: 12)),
                                Text(
                                  payment.paymentStatus == 'PENDING'
                                      ? 'Chưa thanh toán'
                                      : 'Đã thanh toán',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )
                              ],
                            ),
                            Image(
                              image: payment.paymentStatus == 'PENDING' ? AssetImage('assets/images/unpaid.png') : AssetImage('assets/images/paid.png'),
                              width: 40,
                              height: 40,
                            )
                          ],
                        ),
                        const SizedBox(height: 8,),
                      ],);
                    }
                  },
                ),
              ),
            ),
          ],),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
          child: FutureBuilder(
            future: future3,
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
                    child: Column(mainAxisSize: MainAxisSize.min,children: [
                      Image(
                      image: AssetImage('assets/images/no_internet.png'),
                      width: 50,
                      height: 50,
                      ),
                      SizedBox(height: 12,),
                      Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                      Text("Kiểm tra lại kết nối mạng")
                      ])),
                );
              } else if (!snapshot.hasData) {
                return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
              } else {
                Order? order = snapshot.data;
                if(order!.orderStatus == OrderStatus.PENDING){
                  return SizedBox(height: 50,
                    child: MyButton2(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text("Xác nhận hủy"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Bạn có chắc muốn hủy đặt hàng', textAlign: TextAlign.center,),
                                  const SizedBox(height: 6,),
                                  TextFormField(
                                    controller: cancelReasonController,
                                    autofocus: false,
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey), // Màu đường viền khi không focus
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.amber), // Màu đường viền khi focus
                                      ),
                                      hintText: 'Lý do hủy đơn',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 11,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 11),
                                  )
                              ]),
                              buttonPadding: const EdgeInsets.all(4),
                              icon: const Icon(Icons.notification_important_rounded, size: 50, color: Colors.amberAccent,),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyButton2(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        color: Colors.black12,
                                        onTap: () => Navigator.pop(context),
                                        child: const Text("Hủy", style: TextStyle(color: Colors.black54),),
                                      ),
                                    ),
                                    Expanded(
                                      child: MyButton2(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        color: Colors.orange,
                                        onTap: () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          bool ok = await apiService.confirmCancel(orderId, cancelReasonController.text);
                                          if(ok){
                                            setState(() {
                                              loading = false;
                                              Navigator.pop(context, ok);
                                              Navigator.pop(context, ok);
                                            });
                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                          }
                                        },
                                        child: loading ? const MyCircleProgressIndicator(color: Colors.white, wight: 20, height: 20,) : const Text(
                                          "Xác nhận",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],)
                              ],
                            ));
                      },
                      color: Colors.redAccent,
                      child: const Text(
                        'Hủy đơn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
