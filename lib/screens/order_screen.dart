import 'package:doantn/data/enums/order_status.dart';
import 'package:doantn/data/models/order.dart';
import 'package:doantn/screens/detail_order_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../components/my_circle_progress_indicator.dart';
import '../data/api/api_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ApiService apiService = ApiService();
  final logger = Logger();
  Stream<List<Order>>? comingOrderStream;
  Stream<List<Order>>? completedOrderStream;
  Stream<List<Order>>? canceledOrderStream;
  NumberFormat formatter = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    comingOrderStream = _stream1().asBroadcastStream();
    completedOrderStream = _stream2().asBroadcastStream();
    canceledOrderStream = _stream3().asBroadcastStream();
  }


  Stream<List<Order>> _stream1() async* {
    while (true) {
      yield await apiService.fetchComingOrder();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<List<Order>> _stream2() async* {
    while (true) {
      yield await apiService.fetchCompleteOrder();
      await Future.delayed(const Duration(seconds: 1));
    } // Đảm bảo Future hoàn thành
  }

  Stream<List<Order>> _stream3() async* {
    while (true) {
      yield await apiService.fetchCanceledOrder();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<int> getQuantity(int orderId) async {
    int q = await apiService.getOrderQuantity(orderId);
    return q;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Đơn hàng'),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.list_alt_rounded, color: Colors.orange,), text: 'Đang đến',),
              Tab(icon: Icon(Icons.checklist_outlined, color: Colors.orange), text: 'Hoàn thành'),
              Tab(icon: Icon(Icons.cancel_rounded, color: Colors.orange), text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<Order>>(
              stream: comingOrderStream,
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
                            width: 130,
                            height: 130,
                          ),
                          SizedBox(height: 12,),
                          Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Kiểm tra lại kết nối mạng")
                        ])),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                } else {
                  List<Order> orders = snapshot.data!;
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const DetailOrderScreen(),
                                        settings: RouteSettings(
                                            arguments: order.orderId)
                                    ));
                                if(!mounted) {
                                  return;
                                }
                              },
                              leading: const Icon(Icons.list_alt_rounded, color: Colors.amber, size: 50,),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      '#${order.orderId}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 2,),
                                    Text(
                                      '\t ${order.orderStatus == OrderStatus.PENDING ? 'Chờ các nhận' : (order.orderStatus == OrderStatus.ON_PROGRESS ? 'Đang xử lý' : (order.orderStatus == OrderStatus.WILLING_DELIVERY ? 'Sẵn sàng giao' : 'Đang giao'))}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: order.orderStatus == OrderStatus.PENDING ? Colors.amber : (order.orderStatus == OrderStatus.ON_PROGRESS ? Colors.blueAccent : (order.orderStatus == OrderStatus.WILLING_DELIVERY ? Colors.greenAccent : Colors.teal))
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${order.createDate!.day < 10 ? '0${order.createDate!.day}' : order.createDate!.day}-${order.createDate?.month}-${order.createDate?.year}  ${order.createDate!.hour < 10 ? '0${order.createDate!.hour}' : order.createDate!.hour}:${order.createDate!.minute < 10 ? '0${order.createDate!.minute}' : order.createDate!.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.black54
                                        ),
                                      ),
                                    ),
                                  ],),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                      const Icon(Icons.location_on, color: Colors.orange, size: 18,),
                                      Expanded(
                                        child: Text(
                                          softWrap: true,
                                          order.receiverAddress,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ],),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(children: [
                                      Text(
                                        '${order.totalQuantity} món',
                                        style: const TextStyle(
                                            fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          '${formatter.format(order.totalPayment)}đ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ],),
                                  )

                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }
              },
            ),
            StreamBuilder<List<Order>>(
              stream: completedOrderStream,
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
                            width: 130,
                            height: 130,
                          ),
                          SizedBox(height: 12,),
                          Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Kiểm tra lại kết nối mạng")
                        ])),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                } else {
                  List<Order> orders = snapshot.data!;
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const DetailOrderScreen(),
                                        settings: RouteSettings(
                                            arguments: order.orderId)
                                    ));
                                if(!mounted) {
                                  return;
                                }
                              },
                              leading: const Icon(Icons.list_alt_rounded, color: Colors.amber, size: 50,),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      '#${order.orderId}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 4,),
                                    const Text(
                                      'Hoàn thành',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.green
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${order.createDate!.day < 10 ? '0${order.createDate!.day}' : order.createDate!.day}-${order.createDate?.month}-${order.createDate?.year}  ${order.createDate!.hour < 10 ? '0${order.createDate!.hour}' : order.createDate!.hour}:${order.createDate!.minute < 10 ? '0${order.createDate!.minute}' : order.createDate!.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.black54
                                        ),
                                      ),
                                    ),
                                  ],),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.orange, size: 18,),
                                        Expanded(
                                          child: Text(
                                            softWrap: true,
                                            order.receiverAddress,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12
                                            ),
                                          ),
                                        ),
                                      ],),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(children: [
                                      Text(
                                        '${order.totalQuantity} món',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          '${formatter.format(order.totalPayment)}đ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ],),
                                  )

                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }
              },
            ),
            StreamBuilder<List<Order>>(
              stream: canceledOrderStream,
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
                            width: 130,
                            height: 130,
                          ),
                          SizedBox(height: 12,),
                          Text("Đã có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Kiểm tra lại kết nối mạng")
                        ])),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(child: Center(child: Text("Không có đơn hàng nào")));
                } else {
                  List<Order> orders = snapshot.data!;
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const DetailOrderScreen(),
                                        settings: RouteSettings(
                                            arguments: order.orderId)
                                    ));
                                if(!mounted) {
                                  return;
                                }
                              },
                              leading: const Icon(Icons.list_alt_rounded, color: Colors.amber, size: 50,),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      '#${order.orderId}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '\t ${order.orderStatus == OrderStatus.CANCELED ? 'Đã hủy' : ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.red
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        textAlign: TextAlign.end,
                                        '${order.createDate!.day < 10 ? '0${order.createDate!.day}' : order.createDate!.day}-${order.createDate?.month}-${order.createDate?.year}  ${order.createDate!.hour < 10 ? '0${order.createDate!.hour}' : order.createDate!.hour}:${order.createDate!.minute < 10 ? '0${order.createDate!.minute}' : order.createDate!.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.black54
                                        ),
                                      ),
                                    ),
                                  ],),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.orange, size: 18,),
                                        Expanded(
                                          child: Text(
                                            softWrap: true,
                                            order.receiverAddress,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12
                                            ),
                                          ),
                                        ),
                                      ],),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(children: [
                                      Text(
                                        '${order.totalQuantity} món',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          '${formatter.format(order.totalPayment)}đ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ],),
                                  )

                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
