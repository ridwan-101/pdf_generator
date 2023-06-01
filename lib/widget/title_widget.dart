import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          size: 100,
          color: Colors.white,
        ),
        const SizedBox(
          height: 17,
        ),
        Text(
          text,
          style: const TextStyle(
              fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }
}
