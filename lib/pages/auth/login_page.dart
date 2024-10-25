import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/utils/custom_text_field.dart';
import 'package:star_education_centre/utils/local_storage_service.dart';
import 'package:star_education_centre/utils/status_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (_formKey.currentState!.validate()) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_emailController.text == loginEmail &&
            _passwordController.text == loginPassword) {
          statusSnackBar(context, SnackBarType.success, "Login Successful");
          onLoginSuccess();
        } else {
          statusSnackBar(context, SnackBarType.fail, "Wrong Email or Password");
        }
      });
    }
  }

  Future<void> onLoginSuccess() async {
    LocalStorageService storageService = LocalStorageService();
    await storageService.saveLoginStatus(true);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login Form!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Star Education Centre",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      child: CustomTextField(
                        controller: _emailController,
                        hintText: "Email",
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null; // Input is valid
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: CustomTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null; // Input is valid
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: login,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.blue.shade300),
                      ),
                      child: const Text(
                        "Login!",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  const phoneNumber = 'tel:+0123456';
                  if (await canLaunch(phoneNumber)) {
                    await launch(phoneNumber);
                  } else {
                    throw 'Could not launch $phoneNumber';
                  }
                },
                child: const Text(
                  "Please contact +0123456 for help if there are any issues.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
