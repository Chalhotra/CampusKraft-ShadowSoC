import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ig_clone/pages/cart_provider.dart';
import 'package:ig_clone/pages/employee_pages/emp_home.dart';
import 'package:ig_clone/pages/notification_settings.dart';

import 'package:ig_clone/pages/user_login_page.dart';
import 'package:ig_clone/pages/main.dart';

import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyDb8-YZnzJucD2NUllWZAEdeaamhQeI9M8',
      appId: "1:182874385983:web:3033661966f1bda257d28a",
      messagingSenderId: "182874385983",
      projectId: "instagram-clone-b9819",
      authDomain: "instagram-clone-b9819.firebaseapp.com",
      storageBucket: "instagram-clone-b9819.appspot.com",
    ));
    await NotificationServices().initNotifications();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationServices().initNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartProvider>(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                if (FirebaseAuth.instance.currentUser!.email!
                        .substring(9, 20) ==
                    'campuskraft') {
                  return const ShoppingApp();
                } else if (FirebaseAuth.instance.currentUser!.email!
                        .substring(9, 17) ==
                    'employee') {
                  return const EmployeeHome();
                }
              } else if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            return const LoginPage();
          },
        ),
        theme: ThemeData.light(
          useMaterial3: true,
        ),
      ),
    );
  }
}
