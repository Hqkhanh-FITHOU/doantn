import 'package:doantn/components/my_button.dart';
import 'package:doantn/components/my_checkbox.dart';
import 'package:doantn/components/my_circle_progress_indicator.dart';
import 'package:doantn/components/my_text_field.dart';
import 'package:doantn/screens/for_delivery/delivery_home_screen.dart';
import 'package:doantn/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import '../data/api/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;

  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final logger = Logger();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool asDelivery = false;


  @override
  void initState() {
    super.initState();
  }

  void _onCheckboxChanged(bool value) {
    setState(() {
      asDelivery = value;
    });
  }

  bool _invalidateInput(String username) {
    if (username.contains(RegExp(r"\s"))) {
      return true;
    }
    return false;
  }

  //login method
  void login() async {
    if (_invalidateInput(usernameController.text.trim())) {
      setState(() {
        isLoading = true;
      });
      logger.e("invalid input");
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      setState(() {
        logger.i("start authenticate");
        isLoading = true;
      });
      await apiService.login(usernameController.text.trim(), passwordController.text.trim()).timeout(const Duration(seconds: 15));
      String? token = await storage.read(key: 'jwt_token');
      logger.d("authenticate successfully");
      if (asDelivery && _checkRoleDelivery(token!)) {
        logger.i("is delivery");
        setState(() {
          isLoading = false;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeliveryHomeScreen(),
            ),
          );
        });
        await storage.write(key: 'is_login', value: 'true');
        await storage.write(key: 'is_delivery', value: 'true');
        logger.i("login successfully");
      } else if (!asDelivery && _checkRoleCustomer(token!)) {
        logger.i("is customer");
        setState(() {
          isLoading = false;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        });
        await storage.write(key: 'is_login', value: 'true');
        await storage.write(key: 'is_delivery', value: 'false');
        logger.i("login successfully");
      } else {
        logger.i("is admin");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        logger.e("login screen error: $e");
        Fluttertoast.showToast(
            msg: 'Đã có lỗi xảy ra, kiểm tra lại thông tin hoặc kết nối internet', toastLength: Toast.LENGTH_SHORT);
      });
    }
    logger.d("end login method");
  }

  bool _checkRoleCustomer(String token) {
    logger.i("jump to _checkRoleCustomer");
    Map<String, dynamic> jwtDecoded = JwtDecoder.decode(token);
    List<dynamic> roles = jwtDecoded['roles'];
    for (var role in roles) {
      if (role == 'CUSTOMER') {
        return true;
      }
    }
    Fluttertoast.showToast(
        msg: 'Quyền hạn không được hỗ trợ', toastLength: Toast.LENGTH_SHORT);
    return false;
  }

  bool _checkRoleDelivery(String token) {
    logger.i("jump to _checkRoleDelivery");
    Map<String, dynamic> jwtDecoded = JwtDecoder.decode(token);
    List<dynamic> roles = jwtDecoded['roles'];
    for (var role in roles) {
      if (role == 'DELIVERY') {
        return true;
      }
    }
    Fluttertoast.showToast(
        msg: 'Quyền hạn không được hỗ trợ', toastLength: Toast.LENGTH_SHORT);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100),
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
                  height: 30,
                ),
                const Text(
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                    "Tư Mập Xin chào"),
                const SizedBox(
                  height: 25,
                ),
                MyTextField(
                  controller: usernameController,
                  hintText: "Tên đăng nhập hoặc điện thoại",
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
                const SizedBox(
                  height: 15,
                ),
                MyCheckbox(
                  text: "Người giao hàng",
                  isChecked: asDelivery,
                  onChanged: _onCheckboxChanged,
                ),
                const SizedBox(
                  height: 15,
                ),
                MyButton(
                  onTap: (){
                    if (_formKey.currentState!.validate()) {
                      login();
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
                          "Đăng nhập"),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản?"),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Đăng ký ngay",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
