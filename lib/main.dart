import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Education Centre',
      theme: ThemeData(
        fontFamily: 'BarlowBlack',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      home: StudentPage(),
    );
  }
}
