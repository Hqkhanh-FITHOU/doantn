import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../data/models/address.dart';
import '../data/provider/address_provider.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receiverNameController;
  late TextEditingController _receiverPhoneController;
  late TextEditingController _receiverAddressDetailController;
  late int addressId;
  String? _addressType = 'Nhà';
  final logger = Logger();
  late Address _address;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressDetailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addressId = ModalRoute.of(context)?.settings.arguments as int;
    _address = context.read<AddressProvider>().getAddress(addressId);
    logger.d('get data address: $_address - ${_address.addressType}');
    _receiverNameController = TextEditingController(text: _address.name);
    _receiverPhoneController = TextEditingController(text: _address.phone);
    _receiverAddressDetailController = TextEditingController(text: _address.address);
    _addressType ??= _address.addressType;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Sửa địa chỉ"),
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
                      _address.addressType = value!;
                      setState(() {
                        _addressType = value;
                        _address.addressType = value;
                        logger.d('_addressType: ${_address.addressType}');
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
                      // Thêm địa chỉ vào danh sách
                      Address address = Address(
                          name: _receiverNameController.text,
                          phone: _receiverPhoneController.text,
                          address: _receiverAddressDetailController.text,
                          addressType: _addressType!,
                          isChecked: _address.isChecked);

                      logger.d('updating address: $addressId - ${address.name} - ${address.addressType} \n $address');
                      context.read<AddressProvider>().updateAddress(addressId, address);

                      // Lưu thay đổi vào AddressProvider
                      Navigator.pop(context);
                      // Điều hướng về màn hình trước đó sau khi thêm thành công
                    }
                  },
                  child: const Text(
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      "Lưu"),
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
