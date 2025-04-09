import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/pages/login_page.dart';

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

  Column buildBody(BuildContext context) {
    return Column(
      children: [

        FilledButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(Size.fromWidth(160)),
            backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
          ),
          child: Text(
            style: TextStyle(color: AppColors.cardTextCol),
            'Exit',
          ),
        )
      ],
    );
  }
}
