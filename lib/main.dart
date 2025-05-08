import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /*
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
        ),
        textTheme: TextTheme(
          ///TODO impostare un tema unico per tutta l'applicazione
        ),
      ),
      */

      home: LoginPage(),
    );
  }
}
