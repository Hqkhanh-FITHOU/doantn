import 'package:doantn/auth/login_or_register.dart';
import 'package:doantn/components/my_drawer_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../data/api/api_service.dart';
import '../data/models/user.dart';
import '../screens/setting_screen.dart';

class MyDrawer2 extends StatelessWidget {
  final storage = const FlutterSecureStorage();
  final logger = Logger();
  final Function()? onLogout;


  MyDrawer2({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Image(
              image: AssetImage('assets/icon/logo_comtam2.png'),
              width: 80,
              height: 80,
            ),
          ),
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
            text: "Cài đặt",
            icon: Icons.settings,
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
