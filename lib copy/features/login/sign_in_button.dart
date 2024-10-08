import 'package:flutter/material.dart';

Widget buildSignInButton({required VoidCallback onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: const Text('SIGN IN WITH GOOGLE'),
  );
}