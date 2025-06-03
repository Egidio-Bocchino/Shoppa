import 'package:flutter/material.dart';
import '../../pages/products_pages/home_page.dart';
import '../../pages/user_pages/login_page.dart';
import 'auth_service.dart';

class AuthManager extends StatelessWidget{
  const AuthManager({
    super.key,
    this.pageIfNotConnected
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child){
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const CircularProgressIndicator.adaptive();
            } else if (snapshot.hasData) {
              widget = HomePage();
            } else {
              widget = pageIfNotConnected ?? LoginPage();
            }
            return widget;
          },
        );
      }
    );
  }
}