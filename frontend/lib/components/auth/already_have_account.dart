import 'package:flutter/material.dart';

class AlreadyHaveAccount extends StatelessWidget {
  final VoidCallback onSignIn;
  const AlreadyHaveAccount({Key? key, required this.onSignIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: onSignIn,
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
