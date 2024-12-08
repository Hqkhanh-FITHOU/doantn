import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../data/models/address.dart';
import '../data/provider/address_provider.dart';

class AddAddressScreen extends StatefulWidget {

  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _receiverAddressDetailController = TextEditingController();
  String _addressType = 'Nhà';
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Thêm địa chỉ"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyTextField(
                  controller: _receiverNameController,
                  hintText: "Tên người nhận",
                  oscureText: false,
                  type: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập dữ liệu';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                MyTextField(
                  controller: _receiverPhoneController,
                  hintText: "Điện thoại",
                  oscureText: false,
                  type: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập dữ liệu';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                MyTextField(
                  controller: _receiverAddressDetailController,
                  hintText: "Địa chỉ",
                  oscureText: false,
                  type: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập dữ liệu';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: DropdownButtonFormField<String>(
                    value: _addressType,
                    decoration: const InputDecoration(
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent)
                      ),
                      focusedErrorBorder:  OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent)
                      ),
                      enabledBorder:  OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54)
                      ),
                      focusedBorder:  OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54)
                      ),
                      hintStyle:  TextStyle(color: Colors.black38),
                    ),
                    items: ['Nhà', 'Công ty', 'Khác'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _addressType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 15,
                ),
                MyButton(
                  onTap: (){
                    if (_formKey.currentState!.validate()) {
                      final newAddress = Address(
                        name: _receiverNameController.text,
                        phone: _receiverPhoneController.text,
                        address: _receiverAddressDetailController.text,
                        addressType: _addressType,
                        isChecked: false,
                      );

                      // Thêm địa chỉ vào danh sách
                      context.read<AddressProvider>().addAddress(newAddress);

                      // Điều hướng về màn hình trước đó sau khi thêm thành công
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      "Thêm"),
                ),
                const SizedBox(
                  height: 30,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
