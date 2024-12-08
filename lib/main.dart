import 'package:doantn/auth/login_or_register.dart';
import 'package:doantn/components/my_circle_progress_indicator.dart';
import 'package:doantn/data/models/login_infor.dart';
import 'package:doantn/data/provider/cart_provider.dart';
import 'package:doantn/screens/for_delivery/delivery_home_screen.dart';
import 'package:doantn/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/provider/address_provider.dart';

final logger = Logger();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notification clicked: ${response.payload}");
    },
  );

  //todo: run app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Cart()),
      ChangeNotifierProvider(create: (_) => AddressProvider()),
      //ChangeNotifierProvider(create: (_) => ApiService())
    ],
    child: MyApp(),
  ));

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  logger.i('User granted permission: ${settings.authorizationStatus}');
  final fcmToken = await FirebaseMessaging.instance.getToken();
  logger.e('Device Token: $fcmToken');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data['title']}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification!.title}');
      showNotification(message);
    }
  });
}

Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', // Unique channel ID
    'channel_name', // Channel name visible to users
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.notification.hashCode, // Notification ID
    message.notification?.title, // Notification title
    message.notification?.body, // Notification body
    notificationDetails,
    payload: 'Notification Payload', // Optional data for clicks
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  final storage = const FlutterSecureStorage();
  final logger = Logger();

  MyApp({super.key});



  Future<LoginInfor> _isLogin() async {
    String? value1 = await storage.read(key: 'is_login') ?? 'false';
    String? value2 = await storage.read(key: 'is_delivery') ?? 'false';
    logger.d("is_login storage? $value1 \n is_delivery storage? $value2");

    String? token = await storage.read(key: 'jwt_token') ?? 'empty';
    logger.d("is_login with token $token");
    return LoginInfor(token, value1 == 'true', _checkRoleDelivery(token) && value2 == 'true');
  }

  bool _checkRoleDelivery(String token)  {
    logger.i("jump to _checkRoleDelivery");
    if(token == 'empty') {
      return false;
    }
    Map<String, dynamic> jwtDecoded = JwtDecoder.decode(token);
    List<dynamic> roles = jwtDecoded['roles'];
    for (var role in roles) {
      if (role == 'DELIVERY') {
        return true;
      }
    }
    return false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: _isLogin(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error checking login status: ${snapshot.error}');
              return const Center(
                  child: Text('Lỗi')); // Handle error gracefully
            }

            if (snapshot.hasData) {
              final isLoggedIn = snapshot.data!.isLogin;
              final isDelivery = snapshot.data!.isDivevery;
              logger.d("has been login? $isLoggedIn");
              logger.d(isLoggedIn ? "go to home" : "go to login/register");
              if(isLoggedIn){
                logger.d(isDelivery ? "go to delivery home" : "go to customer home");
                return isDelivery ? const DeliveryHomeScreen() : const HomeScreen();
              } else {
                return const LoginOrRegister();
              }

            }

            // Show loading indicator while data is being fetched:
            return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                    child: MyCircleProgressIndicator(
                  color: Colors.orange,
                )));
          },
        ));
  }
}
