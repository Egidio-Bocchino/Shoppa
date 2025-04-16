import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/models/product.dart';
import 'package:shoppa/pages/account_page.dart';
import 'package:shoppa/pages/home_page.dart';
import 'package:shoppa/pages/login_page.dart';
import 'package:shoppa/pages/sign_up_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
      //home: HomePage(),
      //home: AccountPage(),
      //home: Product(),
      home: SignUpPage(),
    );
  }
}
