import 'package:doantn/components/my_button.dart';
import 'package:doantn/data/enums/payment_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentType? _receivedPaymentType;

  @override
  Widget build(BuildContext context) {
    final PaymentType? passedPaymentType = ModalRoute.of(context)?.settings.arguments as PaymentType?;

    if (passedPaymentType != null && _receivedPaymentType == null) {
      // Gán giá trị enum nhận được
      _receivedPaymentType = passedPaymentType;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Phương thức thanh toán"),
        centerTitle: true,
      ),
      body: Column(children: [
        ListTile(
          title: const Text('Thanh toán khi nhận hàng'),
          leading: Radio<PaymentType>(
            value: PaymentType.CASH_ON_DELIVERY,
            groupValue: _receivedPaymentType,
            onChanged: (PaymentType? value) {
              setState(() {
                _receivedPaymentType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('VnPay'),
          leading: Radio<PaymentType>(
            value: PaymentType.VNPAY,
            groupValue: _receivedPaymentType,
            onChanged: (PaymentType? value) {
              setState(() {
                _receivedPaymentType = value;
              });
            },
          ),
        ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MyButton(
                onTap: () {
                  Navigator.pop(context, _receivedPaymentType);
                },
                child: const Text('Đồng ý', style: TextStyle(color: Colors.white),),),
            ),
          )
      ],),
    );
  }
}
