import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

void statusSnackBar(
    BuildContext context, SnackBarType snackBarType, String label) {
  IconSnackBar.show(
    context,
    snackBarType: snackBarType,
    maxLines: 1,
    label: label,
  );
}
