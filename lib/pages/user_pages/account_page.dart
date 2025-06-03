import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/custom_bottombar.dart';
import '../../services/authentication/auth_service.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import '../../services/manager/purchase_manager.dart';

class AccountPage extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = FirebaseAuth.instance.currentUser;
    final purchaseManager = ref.watch(purchaseManagerProvider);
    final lastPurchase = purchaseManager.getList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 20),
                children: [
                  TextSpan(
                    text: 'Indirizzo Email: ',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: user?.email ?? 'Email non disponibile',
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
          const SizedBox(height: 20,),
          lastPurchase == null
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nessun acquisto recente',
              style: TextStyle(color: AppColors.primary, fontSize: 20),
            ),
          )
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: AppColors.cardColor,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(lastPurchase.purchaseDate)}',
                      style: TextStyle(color: AppColors.cardTextCol, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Totale: ${lastPurchase.totalPrice.toStringAsFixed(2)} €',
                      style: TextStyle(color: AppColors.cardTextCol, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Articoli:',
                      style: TextStyle(color: AppColors.cardTextCol, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...lastPurchase.items.map((item) => Text(
                      '- ${item.product.title} (x${item.quantity})',
                      style: TextStyle(color: AppColors.cardTextCol, fontSize: 14),
                    )).toList(),
                  ],
                ),
              )
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
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}