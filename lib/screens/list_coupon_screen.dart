import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../components/my_button.dart';
import '../components/my_circle_progress_indicator.dart';
import '../data/api/api_service.dart';
import '../data/models/coupon.dart';

class ListCouponScreen extends StatefulWidget {
  const ListCouponScreen({super.key});

  @override
  State<ListCouponScreen> createState() => _ListCouponScreenState();
}

class _ListCouponScreenState extends State<ListCouponScreen> {
  final ApiService apiService = ApiService();
  final logger = Logger();
  Stream<List<Coupon>>? couponsStream;
  NumberFormat formatter = NumberFormat.decimalPattern('vi');
  int? _couponId;
  Coupon? selectedCoupon;

  @override
  void initState() {
    super.initState();
    couponsStream ??= _getCoupons().asBroadcastStream();
  }

  Stream<List<Coupon>> _getCoupons() async* {
    while (true) {
      yield await apiService.fetchDataActiveCoupons();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int passedCouponId = ModalRoute.of(context)?.settings.arguments as int;

    _couponId ??= passedCouponId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Khuyến mãi"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: StreamBuilder<List<Coupon>>(stream: couponsStream, builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: MyCircleProgressIndicator(
                      color: Colors.orange,
                    ));
              } else if (snapshot.hasError) {
                logger.e(snapshot.error.toString());
                return const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                    ]));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Không có khuyến mãi nào"));
              } else {
                List<Coupon> coupons = snapshot.data!;
                logger.d(coupons.toString());
                return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return ListTile(
                        leading: Row(mainAxisSize: MainAxisSize.min ,children: [
                          Radio(value: coupon.couponId, groupValue: _couponId, onChanged: (int? value) {
                            setState(() {
                              _couponId = value!;
                              selectedCoupon = coupon;
                            });
                            logger.i('onchange couponId $_couponId');
                          }),
                          coupon.discountType == 'PERCENTAGE'
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
                        ],),
                        title: Text(
                          coupon.code,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: coupon.discountType == 'PERCENTAGE'
                            ? Text(
                            'Giảm ${formatter.format(coupon.discountValue)}% với đơn giá trị tối thiểu ${formatter.format(coupon.minPurchase)}đ')
                            : Text(
                            'Giảm ${formatter.format(coupon.discountValue)}đ với đơn giá trị tối thiểu ${formatter.format(coupon.minPurchase)}đ'),
                        onTap: () {
                          // Xử lý khi nhấn vào sản phẩm, ví dụ như mở màn hình chi tiết khuyen mãi
                          setState(() {
                            _couponId = coupon.couponId;
                            selectedCoupon = coupon;
                          });
                          logger.i('onchange tap $_couponId');
                        },
                      );
                    });
              }
            },)
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MyButton(
                onTap: () {
                  Navigator.pop(context, selectedCoupon);
                },
                child: const Text(
                  'Đồng ý',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
