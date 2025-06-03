import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/theme/app_colors.dart';
import 'package:shoppa/services/authentication/auth_manager.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';

class SplashPage extends ConsumerStatefulWidget{
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async{
    await Future.delayed(const Duration(seconds: 3));

    try{
      await ref.read(productsStreamProvider.future);
    }catch(e){
      print('Errore durante l\'avvio: $e');
    }

    if(mounted){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const AuthManager(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
            'assets/logo/Shoppa_logo.png',
            height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ]
        ),
      )
    );
  }
}