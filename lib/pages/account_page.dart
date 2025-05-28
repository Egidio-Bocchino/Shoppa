import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/pages/login_page.dart';
import '../core/theme/app_colors.dart';
import '../core/widget/custom_bottombar.dart';
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
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Expanded(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: RichText(
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
            ),
            const SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ultimi acquisti',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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