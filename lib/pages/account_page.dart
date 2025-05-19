import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/pages/login_page.dart';
import '../services/authentication/auth_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.value.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print("Errore durante il logout: ${e.message}");
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await authService.value.deleteAccount();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print("Errore durante la cancellazione dell'account: ${e.message}");
    }
  }

  void _resetPassword(BuildContext context) {}


  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      body: Expanded(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/logo/Logo_app2.png'),
            ),
            const SizedBox(height: 50),
            Center(
              child:
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 20),
                  children: [
                    TextSpan(
                      text: 'Nome Utente: ',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: user?.displayName ?? 'Nome',
                      style: TextStyle(color: AppColors.cardTextCol),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 20),
                children: [
                  TextSpan(
                    text: 'Indirizzo Email: ',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: user?.email ?? 'Email',
                    style: TextStyle(color: AppColors.cardTextCol),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FilledButton(
                onPressed: () {
                  _signOut(context);
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size.fromWidth(160)),
                  backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
                ),
                child: Text(
                  'Log out',
                  style: TextStyle(color: AppColors.cardTextCol),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FilledButton(
                onPressed: () {
                  _resetPassword(context);
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size.fromWidth(160)),
                  backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
                ),
                child: Text(
                  'Reset password',
                  style: TextStyle(color: AppColors.cardTextCol),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FilledButton(
                onPressed: () {
                  _deleteAccount(context);
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size.fromWidth(160)),
                  backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
                ),
                child: Text(
                  'Delete account',
                  style: TextStyle(color: AppColors.cardTextCol),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}