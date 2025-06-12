import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/custom_email_box.dart';
import '../../core/widget/custom_password_box.dart';
import '../../services/authentication/auth_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildSignInText(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register Account",
                  style: TextStyle(
                    color: AppColors.cardTextCol,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 100),

                _emailBox(),

                const SizedBox(height: 30),

                _passwordBox(),

                const SizedBox(height: 10),
                Text(
                  _errorMessage,
                  key: const Key('signup_error_message'),
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 30),
                _buildSignUpButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _passwordBox() {
    return SizedBox(
      width: 300,
      child: CustomPasswordBox(
        key: const Key('signup_password_field'),
        controller: _passwordController,
        labelText: 'Password',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Inserisci la tua password';
          }
          if (value.length < 6) {
            return 'La password deve avere \n almeno 6 caratteri';
          }
          if (!value.contains(RegExp(r'[A-Z]'))) {
            return 'La password deve contenere \n almeno una lettera maiuscola';
          }
          if (!value.contains(RegExp(r'[a-z]'))) {
            return 'La password deve contenere \n almeno una lettera minuscola';
          }
          if (!value.contains(RegExp(r'[0-9]'))) {
            return 'La password deve contenere \n almeno un numero';
          }
          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            return 'La password deve contenere \n almeno un carattere speciale';
          }
          return null;
        },
      ),
    );
  }

  SizedBox _emailBox() {
    return SizedBox(
      width: 300,
      child: CustomEmailBox(
        key: const Key('signup_email_field'),
        controller: _emailController,
        labelText: 'Email',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Per favore, inserisci la tua email';
          }
          if (!value.contains('@')) {
            return 'Per favore, inserisci un\'email valida';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignUpButton() {
    return FilledButton(
      key: const Key('create_account_button'),
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size.fromWidth(160)),
        backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          await _register();
        }
      },
      child: Text(
        'Sign Up',
        style: TextStyle(color: AppColors.cardTextCol),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.primary,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      title: const Image(
        image: AssetImage('assets/logo/Shoppa_logo.png'),
        width: 100,
        height: 100,
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 30),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: AppColors.cardTextCol,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: "Log In",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
    });
    try {
      await authService.value.createAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );
      popPage(context);
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
          errorMessage = 'Errore di registrazione: ${e.message}';
          break;
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Si è verificato un errore inatteso: $e';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void popPage(BuildContext context) {
    Navigator.of(context).pop();
  }
}