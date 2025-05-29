import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/pages/products_pages/home_page.dart';
import 'package:shoppa/pages/user_pages/sign_up_page.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widget/custom_email_box.dart';
import '../../core/widget/custom_password_box.dart';
import '../../services/authentication/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
              const SizedBox(height: 50,),
               _emailBox(),

               const SizedBox(height: 15,),

               _passwordBox(),

               const SizedBox(height: 10),

               Text(
                 _errorMessage,
                 style: const TextStyle(color: Colors.red),
               ),

               const SizedBox(height: 15),

               loginButton(context),

               const SizedBox(height: 10),

               signUpButton(context),
             ],
            ),
          ),
        ),
      )
    );
  }

  SizedBox _emailBox() {
    return SizedBox(
     width: 300,
     child: CustomEmailBox(
       controller: _emailController,

       labelText: 'Email',

       validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci la tua email';
        }
        if (!value.contains('@')) {
          return 'Inserisci un indirizzo email valido';
        }
        return null;
       },
     ),
    );
  }

  SizedBox _passwordBox() {
    return SizedBox(
      width: 300,
      child: CustomPasswordBox(
        controller: _passwordController,

        labelText: 'Password',

        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Inserisci la tua password';
          }
          if (value.length < 6) {
            return 'La password deve avere almeno 6 caratteri';
          }
          return null;
        },
      ),
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
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size.fromWidth(160)),
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
        if (_formKey.currentState!.validate()) {
          await _signIn();
        }
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

  Future<void> _signIn() async {
    setState(() {
      _errorMessage = '';
    });

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}