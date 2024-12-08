import 'package:doantn/auth/login_or_register.dart';
import 'package:doantn/components/my_drawer_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../data/api/api_service.dart';
import '../data/models/user.dart';
import '../screens/order_screen.dart';
import '../screens/setting_screen.dart';
import 'my_circle_progress_indicator.dart';

class MyDrawer extends StatelessWidget {
  final storage = const FlutterSecureStorage();
  final logger = Logger();
  final Function()? onLogout;
  final ApiService apiService = ApiService();
  late Future<User> userFuture = apiService.getUder();

  MyDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 20),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 55,
                        width: 55,
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/user.png'),
                          radius: 50,
                        ),
                      ),
                      const SizedBox(width: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                          Text(user.email, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),),
                          Text(user.phone, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),)
                        ],),
                    ],
                  );
                }
              },
            )
            )
          ,
          const Padding(
            padding: EdgeInsets.all(25),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          MyDrawerTitle(
            text: "Trang chủ",
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),
          MyDrawerTitle(
            text: "Đơn hàng",
            icon: Icons.list_alt_rounded,
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderScreen(),
                  )
              );
            },
          ),
          MyDrawerTitle(
            text: "Tài khoản",
            icon: Icons.account_circle,
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                  context, 
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                  )
              );
            },
          ),
          MyDrawerTitle(
            text: "Đăng xuất",
            icon: Icons.logout,
            onTap: ()  async {
              Navigator.pop(context);
              onLogout!();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginOrRegister(),
                  )
              );
              await storage.write(key: 'is_login', value: 'false');
              await storage.write(key: 'jwt_token', value: null);
            },
          ),
        ],
      ),
    );
  }
}
