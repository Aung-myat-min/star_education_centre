import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:star_education_centre/main_page.dart';
import 'package:star_education_centre/pages/auth/login_page.dart';
import 'package:star_education_centre/utils/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBq-uFNew0WIKIlVG_i_czHh9oGQS3f-pw",
          appId: "1:918655092924:web:2be56bc5a67503eea1a8b9",
          messagingSenderId: "918655092924",
          projectId: "amm-stareducationcentre"),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Check login status before running the app
  LocalStorageService service = LocalStorageService();
  await service.init();
  bool isLoggedIn = await service.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> routes = {
      '/login': (context) => const LoginPage(),
      '/home': (context) => const MainPage(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Education Centre',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xfff4e7dc),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
        useMaterial3: true,
      ),
      routes: routes,

      // Decide the initial route based on login status
      initialRoute: isLoggedIn
          ? '/home'
          : '/login',
    );
  }
}
