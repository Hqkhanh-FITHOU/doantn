import 'package:doantn/auth/login_or_register.dart';
import 'package:doantn/components/my_button.dart';
import 'package:doantn/components/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../components/my_circle_progress_indicator.dart';
import '../data/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;

  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();

  bool isLoading = false;

  void register() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (_invalidateInput(usernameController.text.trim())) {
        logger.e("invalid input");
        setState(() {
          isLoading = false;
        });
        return;
      }
      await apiService.register(
          fullnameController.text.trim(),
          phoneController.text.trim(),
          emailController.text.trim(),
          usernameController.text.trim(),
          passwordController.text.trim()
      ).timeout(const Duration(seconds: 15));
      setState(() {
        isLoading = false;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginOrRegister(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        logger.e("register screen error: $e");
        Fluttertoast.showToast(
            msg: 'Đã có lỗi xảy ra, kiểm tra lại thông tin hoặc kết nối internet', toastLength: Toast.LENGTH_SHORT);
      });

    }
    logger.d("end register method");
  }

  bool _invalidateInput(String username) {
    if (username.contains(RegExp(r"\s"))) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/icon/logo_comtam2.png'),
                  width: 130,
                  height: 130,
                ),
                const Text("Cơm tấm Tư Mập"),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                    "Đăng ký"),
                const SizedBox(
                  height: 25,
                ),
                MyTextField(
                  controller: fullnameController,
                  hintText: "Họ tên",
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
                  controller: phoneController,
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
                  controller: emailController,
                  hintText: "email",
                  oscureText: false,
                  type: TextInputType.emailAddress,
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
                  controller: usernameController,
                  hintText: "Tên đăng nhập",
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
                  controller: passwordController,
                  hintText: "Mật khẩu",
                  oscureText: true,
                  type: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập dữ liệu';
                    }
                    return null;
                  },
                ),
                //MyCheckbox(text: "Người giao hàng", isChecked: _isChecked),
                const SizedBox(
                  height: 15,
                ),
                MyTextField(
                  controller: passwordConfirmController,
                  hintText: "Xác nhận mật khẩu",
                  oscureText: true,
                  type: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập dữ liệu';
                    }
                    if(passwordController.text != passwordConfirmController.text){
                      return 'Mật khẩu xác nhận không đúng';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                MyButton(
                  onTap: (){
                    if(_formKey.currentState!.validate()){
                      register();
                    }
                  },
                  child: isLoading
                      ? const MyCircleProgressIndicator(
                          wight: 23,
                          height: 23,
                          color: Colors.white,
                        )
                      : const Text(
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          "Đăng ký"),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản?"),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Đăng nhập",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
