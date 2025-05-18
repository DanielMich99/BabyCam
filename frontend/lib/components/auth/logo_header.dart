import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.baby_changing_station, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text(
          'Welcome to',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'BabyCam',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
