import 'package:flutter/material.dart';
import 'package:shoppa/pages/home_page.dart';
import '../core/config/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: buildLoginPage(context),
    );
  }

  SingleChildScrollView buildLoginPage(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/logo/Shoppa_logo.png'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppColors.cardTextCol),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cardColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cardColor),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppColors.cardTextCol),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cardColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cardColor),
                  ),
                ),
                obscureText: false,
              ),
            ),
            SizedBox(height: 30),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(Size.fromWidth(160)),
                backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
              ),
              child: Text(
                style: TextStyle(color: AppColors.cardTextCol),
                'Login',
              ),
            ),
            SizedBox(height: 10),
            FilledButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
              ),
              child: Text(
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.cardTextCol),
                'Create Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}