import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/pages/login_page.dart';

import '../services/auth_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      body: buildBody(context),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Expanded buildBody(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/logo/Logo_app2.png'),
            /// TODO inserire immagine profilo
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Nome Account',
              style: TextStyle(color: AppColors.cardTextCol, fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Email',
            style: TextStyle(color: AppColors.cardTextCol, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Indirizzo spedizione',
            style: TextStyle(color: AppColors.cardTextCol, fontSize: 20),
          ),
          const Spacer(), // Spacer per occupare lo spazio vuoto
          Padding( // Padding per distanziare il bottone dal bordo inferiore
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
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
        ],
      ),
    );
  }

  void logout() async{
    try{
      await authService.value.signOut();
    }on FirebaseAuthException catch(e){
      print(e.message);
    }
  }
}
