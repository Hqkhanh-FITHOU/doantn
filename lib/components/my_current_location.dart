import 'package:doantn/data/provider/address_provider.dart';
import 'package:doantn/screens/address_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCurrentLocation extends StatefulWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  const MyCurrentLocation({super.key, required this.title, required this.padding});

  @override
  State<MyCurrentLocation> createState() => _MyCurrentLocationState();
}

class _MyCurrentLocationState extends State<MyCurrentLocation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        provider.loadAddresses();
        final checkerAddress =  provider.getCheckedAddress().address;
        return Padding(
          padding: widget.padding,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen(),)),
            child: Card(
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(color: Colors.black26),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.black54,),
                        //address
                        Expanded(
                          child: Text(
                            checkerAddress.isNotEmpty ? checkerAddress : 'Chưa chọn nơi nhận hàng',
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.black54,),
                          ),
                        ),

                        //drop down menu
                        // Icon(Icons.keyboard_arrow_down_rounded)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  openLocationSearchBox(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Vị trí của bạn"),
              content: const TextField(
                decoration: InputDecoration(hintText: "Nhập địa chỉ"),
              ),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                MaterialButton(
                  color: Colors.orange,
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));
  }
}
