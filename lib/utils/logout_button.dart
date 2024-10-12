import 'package:flutter/material.dart';
import 'package:star_education_centre/utils/confirmation_box.dart';
import 'package:star_education_centre/utils/local_storage_service.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  Future<void> logout() async {
    bool confirmation = await showConfirmationDialog(
        context, "Confirm Action", "Please confirm to logout!");
    if (confirmation) {
      LocalStorageService service = LocalStorageService();
      service.clearLoginStatus();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: logout,
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.white,
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.redAccent.withOpacity(0.2),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded border
            ),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(
              color: Colors.redAccent, // Border color redAccent
              width: 1, // Border width
            ),
          ),
        ),
      ),
    );
  }
}
