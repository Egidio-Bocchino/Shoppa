import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/pages/home_page.dart';
import 'package:shoppa/pages/sign_up_page.dart';
import '../core/config/theme/app_colors.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
            SizedBox(height: 50),
            _buildEmailTextField(),
            SizedBox(height: 15),
            _buildPasswordTextField(),
            Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
            ),
            SizedBox(height: 15),
            loginButton(context),
            SizedBox(height: 10),
            signUpButton(context),
           ],
          ),
        ),
      )
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: false,
      toolbarHeight: 200,
      title: Center(
        child: Image(
          image: AssetImage('assets/logo/Shoppa_logo.png'),
          width: 150,
          height: 150,
        ),
      ),
    );
  }

  FilledButton signUpButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      },
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(Size.fromWidth(160)),
        backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
      ),
      child: Text(
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.cardTextCol),
        'Create Account',
      ),
    );
  }

  FilledButton loginButton(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        await _signIn();
      },
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(Size.fromWidth(160)),
        backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
      ),
      child: Text(
        style: TextStyle(color: AppColors.cardTextCol),
        'Login',
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          width: 300,
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: AppColors.cardTextCol),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: AppColors.cardTextCol),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _emailController,
            style: TextStyle(color: AppColors.cardTextCol),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: AppColors.cardTextCol),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    try {
      await authService.value.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      pushPage(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'La password è troppo debole.';
          break;
        case 'email-already-in-use':
          errorMessage = 'L\'indirizzo email è già in uso.';
          break;
        case 'invalid-email':
          errorMessage = 'L\'indirizzo email non è valido.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'L\'operazione non è consentita.';
          break;
        default:
          errorMessage = 'Password o Email errate';
          break;
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  void pushPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

}