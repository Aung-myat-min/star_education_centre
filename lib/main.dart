import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:star_education_centre/main_page.dart';
import 'package:star_education_centre/pages/attendance_page.dart';
import 'package:star_education_centre/pages/auth/login_page.dart';
import 'package:star_education_centre/pages/courses_page.dart';
import 'package:star_education_centre/pages/home_page.dart';
import 'package:star_education_centre/pages/student_page.dart';

void main() async {
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> routes = {
      '/login': (context) => LoginPage(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Education Centre',
      theme: ThemeData(
        fontFamily: 'BarlowBlack',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      routes: routes,
      initialRoute: '/',
      home: const MainPage(),
    );
  }
}
