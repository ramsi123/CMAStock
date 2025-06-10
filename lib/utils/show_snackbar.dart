import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context,
  String title,
) {
  Flushbar(
    messageText: Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade400,
      ),
    ),
    icon: Icon(
      Icons.check_circle,
      color: Colors.pink.shade400,
    ),
    shouldIconPulse: false,
    duration: const Duration(milliseconds: 3000),
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: Colors.white,
    borderColor: Colors.pink.shade400,
  ).show(context);
}
