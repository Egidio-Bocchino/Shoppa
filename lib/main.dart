import 'package:flutter/material.dart';
import 'package:shoppa/pages/account_page.dart';
import 'package:shoppa/pages/home_page.dart';
import 'package:shoppa/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
      home: AccountPage(),
    );
  }
}
