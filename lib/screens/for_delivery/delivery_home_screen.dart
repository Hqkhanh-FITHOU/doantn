import 'package:doantn/components/my_silver_appbar2.dart';
import 'package:doantn/components/my_tab_bar2.dart';
import 'package:doantn/screens/for_delivery/delivery_detail_order_confirm_screen.dart';
import 'package:doantn/screens/for_delivery/delivery_detail_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../components/my_circle_progress_indicator.dart';
import '../../components/my_drawer2.dart';
import '../../data/api/api_service.dart';
import '../../data/models/order.dart';
import '../../data/models/user.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late TabController _tabController;
  final ApiService apiService = ApiService();
  final logger = Logger();
  NumberFormat formatter = NumberFormat.decimalPattern('vi');
  late Future<User> userFuture;
  Stream<List<Order>>? willingOrderStream;
  Stream<List<Order>>? deliveringOrderStream;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userFuture = apiService.getUder();
    willingOrderStream = _stream1().asBroadcastStream();
    deliveringOrderStream = _stream2().asBroadcastStream();
  }

  Stream<List<Order>> _stream1() async* {
    while (true) {
      yield await apiService.fetchWillingOrder();
      await Future.delayed(const Duration(seconds: 1));
    } // Đảm bảo Future hoàn thành
  }

  Stream<List<Order>> _stream2() async* {
    while (true) {
      yield await apiService.fetchDeliveringOrder();
      await Future.delayed(const Duration(seconds: 1));
    } // Đảm bảo Future hoàn thành
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
      drawer: MyDrawer2(
        onLogout: () => Navigator.pop(context),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            MySliverAppbar2(
                cartBadge: null,
                title: MyTabBar2(
                  tabController: _tabController,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
                          child: FutureBuilder(
                            future: userFuture,
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
                              } else {
                                User user = snapshot.data!;
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(user.fullname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                        Text(user.phone)
                                      ],),
                                    const SizedBox(width: 12,),
                                    const SizedBox(
                                      height: 55,
                                      width: 55,
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/user.png'),
                                        radius: 50,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        )
                      ],
                ))
          ],
          body: TabBarView(controller: _tabController, children: [
            StreamBuilder<List<Order>>(stream: willingOrderStream, builder: (context, snapshot) {
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
                return const SingleChildScrollView(child: SizedBox(height: 500 ,child: Center(child: Text("Không có đơn hàng nào"))));
              } else {
                logger.i('coming has data');
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
                            leading: const Icon(Icons.list_alt_rounded, color: Colors.amberAccent, size: 50,),
                            onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DeliveryDetailOrderScreen(),
                                        settings: RouteSettings(
                                            arguments: order.orderId)));
                              },
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
                                  const Text(
                                    '\t Sẵn sàng giao',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.greenAccent
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
            },),
            StreamBuilder<List<Order>>(stream: deliveringOrderStream, builder: (context, snapshot) {
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
                return const SingleChildScrollView(child: SizedBox(height: 500,child: Center(child: Text("Không có đơn hàng nào"))));
              } else {
                logger.i('coming has data');
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
                            leading: const Icon(Icons.list_alt_rounded, color: Colors.amber, size: 50,),
                            onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DeliveryDetailOrderConfirmScreen(),
                                        settings: RouteSettings(
                                            arguments: order.orderId)
                                    ));
                                if(!mounted) {
                                  return;
                                }

                              },
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
                                  const Text(
                                    '\t Đang giao',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.teal
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
            },),
          ])),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
