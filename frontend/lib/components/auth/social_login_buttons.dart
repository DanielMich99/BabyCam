import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onFacebookSignIn;

  const SocialLoginButtons({
    Key? key,
    required this.onGoogleSignIn,
    required this.onFacebookSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
              onPressed: onGoogleSignIn,
              tooltip: 'Sign in with Google',
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
              onPressed: onFacebookSignIn,
              tooltip: 'Sign in with Facebook',
            ),
          ],
        ),
      ],
    );
  }
}
